import AppKit
import AVFoundation
import CoreMedia
import Foundation

enum FrameExtractError: Error, CustomStringConvertible {
  case invalidArguments
  case missingFrame(String)
  case encodeFailure(String)

  var description: String {
    switch self {
    case .invalidArguments:
      return "Usage: xcrun swift scripts/extract_first_frames.swift <input.mp4> <output.jpg> [<input.mp4> <output.jpg> ...]"
    case .missingFrame(let path):
      return "Could not extract a frame from \(path)"
    case .encodeFailure(let path):
      return "Could not encode a JPEG preview for \(path)"
    }
  }
}

func writeFirstFrame(from inputPath: String, to outputPath: String) throws {
  let inputURL = URL(fileURLWithPath: inputPath)
  let asset = AVURLAsset(url: inputURL)
  let generator = AVAssetImageGenerator(asset: asset)
  generator.appliesPreferredTrackTransform = true
  generator.maximumSize = CGSize(width: 1600, height: 1600)

  let semaphore = DispatchSemaphore(value: 0)
  var generatedImage: CGImage?
  var generationError: Error?

  generator.generateCGImageAsynchronously(for: .zero) { image, _, error in
    generatedImage = image
    generationError = error
    semaphore.signal()
  }

  semaphore.wait()

  if let generationError {
    throw generationError
  }

  guard let cgImage = generatedImage else {
    throw FrameExtractError.missingFrame(inputPath)
  }

  let bitmap = NSBitmapImageRep(cgImage: cgImage)

  guard let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else {
    throw FrameExtractError.encodeFailure(inputPath)
  }

  let outputURL = URL(fileURLWithPath: outputPath)
  try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try data.write(to: outputURL)
}

let arguments = Array(CommandLine.arguments.dropFirst())

guard !arguments.isEmpty, arguments.count.isMultiple(of: 2) else {
  throw FrameExtractError.invalidArguments
}

for pairIndex in stride(from: 0, to: arguments.count, by: 2) {
  let inputPath = arguments[pairIndex]
  let outputPath = arguments[pairIndex + 1]
  try writeFirstFrame(from: inputPath, to: outputPath)
  FileHandle.standardOutput.write(Data("\(outputPath)\n".utf8))
}
