import Foundation
import Vision
import CoreImage
import AppKit

func cutout(inputPath: String, outputPath: String) {
  let url = URL(fileURLWithPath: inputPath)
  guard let ciImage = CIImage(contentsOf: url) else {
    fputs("Failed to load: \(inputPath)\n", stderr)
    exit(1)
  }

  let req = VNGenerateForegroundInstanceMaskRequest()
  let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
  try! handler.perform([req])
  guard let obs = req.results?.first else {
    fputs("No subject found: \(inputPath)\n", stderr)
    exit(2)
  }

  // Generate high-res alpha mask pixel buffer
  let maskPB = try! obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
  var maskCI = CIImage(cvPixelBuffer: maskPB)

  // Erode mask slightly (~1.2px) to eliminate white-background halo/fringing
  if let erode = CIFilter(name: "CIMorphologyMinimum") {
    erode.setValue(maskCI, forKey: kCIInputImageKey)
    erode.setValue(1.5, forKey: kCIInputRadiusKey)
    if let eroded = erode.outputImage {
      maskCI = eroded
    }
  }

  // Soften 0.6px edge for smooth anti-aliasing without white glow
  if let blur = CIFilter(name: "CIGaussianBlur") {
    blur.setValue(maskCI, forKey: kCIInputImageKey)
    blur.setValue(0.6, forKey: kCIInputRadiusKey)
    if let blurred = blur.outputImage {
      maskCI = blurred.cropped(to: ciImage.extent)
    }
  }

  let transparentBG = CIImage(color: CIColor(red: 0, green: 0, blue: 0, alpha: 0)).cropped(to: ciImage.extent)
  guard let blend = CIFilter(name: "CIBlendWithMask") else { exit(3) }
  blend.setValue(ciImage, forKey: kCIInputImageKey)
  blend.setValue(transparentBG, forKey: kCIInputBackgroundImageKey)
  blend.setValue(maskCI, forKey: kCIInputMaskImageKey)

  guard let outCI = blend.outputImage else { exit(4) }
  let ctx = CIContext()
  let cg = ctx.createCGImage(outCI, from: ciImage.extent)!
  let rep = NSBitmapImageRep(cgImage: cg)
  let png = rep.representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: outputPath))
  print("Clean cutout:", outputPath)
}

if CommandLine.arguments.count < 3 {
  print("Usage: swift cutout.swift <input> <output>")
  exit(1)
}
cutout(inputPath: CommandLine.arguments[1], outputPath: CommandLine.arguments[2])
