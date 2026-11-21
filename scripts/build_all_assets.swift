import Foundation
import Vision
import CoreImage
import AppKit

let legacyRawDir = "/Users/jehee/.gemini/antigravity/brain/67705f16-b9b8-4316-b942-8d520023ae7c"
let newRawDir    = "/Users/jehee/.gemini/antigravity-cli/brain/550e17ac-5c07-4dc3-aad8-c797f94d8f55"
let outDir       = "/Users/jehee/Game_Dev/menhera-chat-game/assets"

let canvasW = 896
let canvasH = 1200
let canvasSize = CGSize(width: canvasW, height: canvasH)
let ciCtx = CIContext(options: [.useSoftwareRenderer: false])

func findLatestRaw(prefix: String, fallbackLegacy: String? = nil) -> String? {
  let fm = FileManager.default
  if let items = try? fm.contentsOfDirectory(atPath: newRawDir) {
    let matches = items
      .filter { $0.hasPrefix(prefix) && ($0.hasSuffix(".png") || $0.hasSuffix(".jpg")) }
      .sorted()
    if let last = matches.last {
      return "\(newRawDir)/\(last)"
    }
  }
  if let fb = fallbackLegacy {
    let p = "\(legacyRawDir)/\(fb)"
    if fm.fileExists(atPath: p) { return p }
  }
  return nil
}

struct FaceSpec {
  let id: String
  let rawFile: String
  let leftEye: CGPoint
  let rightEye: CGPoint
  let eyeRx: CGFloat
  let eyeRy: CGFloat
  let leftBrow: CGPoint
  let rightBrow: CGPoint
  let leftCheek: CGPoint
  let rightCheek: CGPoint
  let nose: CGPoint
  let mouth: CGPoint
  let mouthRx: CGFloat
  let mouthRy: CGFloat
  let neckPivot: CGPoint
  let crownCenter: CGPoint
  let crownTopY: CGFloat
  let torsoTopY: CGFloat
  let hasBangsOverBrows: Bool
  let skinRGB: (Double, Double, Double)
  let hairBaseRGB: (Double, Double, Double)
  let hairShadowRGB: (Double, Double, Double)
  let hairHiRGB: (Double, Double, Double)
  let lipRGB: (Double, Double, Double)
}

let harinNormal = "harin_standing_1794658967566.jpg"
let harinHappy  = "harin_standing_blushing_smile_1794659186400.jpg"
let harinPout   = "harin_glaring_pout_1794659187168.jpg"
let harinAnx    = "harin_standing_anxious_1794659186643.jpg"
let harinCasual = "harin_casual_home_sprite_1794659443586.jpg"
let harinDate   = "harin_date_sprite_1794659443275.jpg"

let charSpecs: [String: FaceSpec] = [
  "seoyoon": FaceSpec(
    id: "seoyoon", rawFile: "seoyoon_vn_sprite_1794659422054.jpg",
    leftEye: CGPoint(x: 389, y: 274), rightEye: CGPoint(x: 486, y: 267),
    eyeRx: 27, eyeRy: 16,
    leftBrow: CGPoint(x: 385, y: 245), rightBrow: CGPoint(x: 486, y: 236),
    leftCheek: CGPoint(x: 382, y: 318), rightCheek: CGPoint(x: 498, y: 314),
    nose: CGPoint(x: 441, y: 319),
    mouth: CGPoint(x: 445, y: 353), mouthRx: 28, mouthRy: 14,
    neckPivot: CGPoint(x: 446, y: 405),
    crownCenter: CGPoint(x: 448, y: 185), crownTopY: 132, torsoTopY: 465,
    hasBangsOverBrows: false,
    skinRGB: (0.98, 0.87, 0.81),
    hairBaseRGB: (0.45, 0.29, 0.23), hairShadowRGB: (0.28, 0.16, 0.13), hairHiRGB: (0.68, 0.48, 0.39),
    lipRGB: (0.92, 0.50, 0.44)
  ),
  "harin": FaceSpec(
    id: "harin", rawFile: harinNormal,
    leftEye: CGPoint(x: 383, y: 296), rightEye: CGPoint(x: 510, y: 296),
    eyeRx: 29, eyeRy: 18,
    leftBrow: CGPoint(x: 383, y: 262), rightBrow: CGPoint(x: 510, y: 262),
    leftCheek: CGPoint(x: 374, y: 342), rightCheek: CGPoint(x: 522, y: 342),
    nose: CGPoint(x: 450, y: 342),
    mouth: CGPoint(x: 454, y: 393), mouthRx: 26, mouthRy: 13,
    neckPivot: CGPoint(x: 450, y: 432),
    crownCenter: CGPoint(x: 450, y: 125), crownTopY: 55, torsoTopY: 470,
    hasBangsOverBrows: true,
    skinRGB: (0.98, 0.90, 0.87),
    hairBaseRGB: (0.16, 0.15, 0.17), hairShadowRGB: (0.08, 0.07, 0.09), hairHiRGB: (0.38, 0.36, 0.42),
    lipRGB: (0.90, 0.52, 0.56)
  ),
  "sea": FaceSpec(
    id: "sea", rawFile: "sea_character_sprite_1794659420857.jpg",
    leftEye: CGPoint(x: 391, y: 311), rightEye: CGPoint(x: 502, y: 302),
    eyeRx: 28, eyeRy: 16,
    leftBrow: CGPoint(x: 386, y: 282), rightBrow: CGPoint(x: 502, y: 274),
    leftCheek: CGPoint(x: 382, y: 358), rightCheek: CGPoint(x: 510, y: 350),
    nose: CGPoint(x: 453, y: 368),
    mouth: CGPoint(x: 458, y: 405), mouthRx: 32, mouthRy: 15,
    neckPivot: CGPoint(x: 456, y: 462),
    crownCenter: CGPoint(x: 454, y: 150), crownTopY: 75, torsoTopY: 485,
    hasBangsOverBrows: true,
    skinRGB: (0.97, 0.88, 0.82),
    hairBaseRGB: (0.76, 0.75, 0.74), hairShadowRGB: (0.50, 0.48, 0.49), hairHiRGB: (0.92, 0.91, 0.90),
    lipRGB: (0.85, 0.55, 0.52)
  ),
  "chaewon": FaceSpec(
    id: "chaewon", rawFile: "chaewon_sprite_1794659422289.jpg",
    leftEye: CGPoint(x: 400, y: 228), rightEye: CGPoint(x: 473, y: 213),
    eyeRx: 26, eyeRy: 16,
    leftBrow: CGPoint(x: 389, y: 206), rightBrow: CGPoint(x: 472, y: 190),
    leftCheek: CGPoint(x: 394, y: 264), rightCheek: CGPoint(x: 482, y: 252),
    nose: CGPoint(x: 444, y: 258),
    mouth: CGPoint(x: 450, y: 287), mouthRx: 26, mouthRy: 13,
    neckPivot: CGPoint(x: 452, y: 332),
    crownCenter: CGPoint(x: 442, y: 145), crownTopY: 72, torsoTopY: 365,
    hasBangsOverBrows: true,
    skinRGB: (0.93, 0.82, 0.77),
    hairBaseRGB: (0.14, 0.13, 0.14), hairShadowRGB: (0.06, 0.05, 0.06), hairHiRGB: (0.36, 0.22, 0.24),
    lipRGB: (0.64, 0.18, 0.22)
  ),
  "nayeon": FaceSpec(
    id: "nayeon", rawFile: "nayeon_sprite_1794659421855.jpg",
    leftEye: CGPoint(x: 450, y: 256), rightEye: CGPoint(x: 549, y: 284),
    eyeRx: 29, eyeRy: 18,
    leftBrow: CGPoint(x: 449, y: 232), rightBrow: CGPoint(x: 566, y: 258),
    leftCheek: CGPoint(x: 432, y: 306), rightCheek: CGPoint(x: 550, y: 330),
    nose: CGPoint(x: 483, y: 324),
    mouth: CGPoint(x: 471, y: 367), mouthRx: 42, mouthRy: 26,
    neckPivot: CGPoint(x: 475, y: 432),
    crownCenter: CGPoint(x: 525, y: 155), crownTopY: 78, torsoTopY: 465,
    hasBangsOverBrows: false,
    skinRGB: (0.98, 0.90, 0.85),
    hairBaseRGB: (0.86, 0.71, 0.56), hairShadowRGB: (0.62, 0.45, 0.34), hairHiRGB: (0.96, 0.87, 0.74),
    lipRGB: (0.94, 0.50, 0.56)
  ),
]

// MARK: - Straight Non-Premultiplied RGBA Pixel Canvas (Top-Down)
struct PixelCanvas {
  let w: Int
  let h: Int
  var px: [UInt8]

  init(w: Int = canvasW, h: Int = canvasH) {
    self.w = w
    self.h = h
    self.px = [UInt8](repeating: 0, count: w * h * 4)
  }

  @inline(__always)
  func inBounds(_ x: Int, _ y: Int) -> Bool {
    x >= 0 && x < w && y >= 0 && y < h
  }

  @inline(__always)
  func rgba(_ x: Int, _ y: Int) -> (Double, Double, Double, Double) {
    if !inBounds(x, y) { return (0, 0, 0, 0) }
    let i = (y * w + x) * 4
    return (Double(px[i]) / 255.0, Double(px[i + 1]) / 255.0, Double(px[i + 2]) / 255.0, Double(px[i + 3]) / 255.0)
  }

  @inline(__always)
  mutating func setRGBA(_ x: Int, _ y: Int, r: Double, g: Double, b: Double, a: Double) {
    if !inBounds(x, y) { return }
    let i = (y * w + x) * 4
    px[i]     = UInt8(max(0, min(255, Int((r * 255.0).rounded()))))
    px[i + 1] = UInt8(max(0, min(255, Int((g * 255.0).rounded()))))
    px[i + 2] = UInt8(max(0, min(255, Int((b * 255.0).rounded()))))
    px[i + 3] = UInt8(max(0, min(255, Int((a * 255.0).rounded()))))
  }

  @inline(__always)
  func sampleBilinear(_ sx: CGFloat, _ sy: CGFloat) -> (Double, Double, Double, Double) {
    let fx = Double(sx), fy = Double(sy)
    if fx < -0.5 || fy < -0.5 || fx > Double(w - 1) + 0.5 || fy > Double(h - 1) + 0.5 {
      return (0, 0, 0, 0)
    }
    let x0 = Int(floor(fx)), y0 = Int(floor(fy))
    let tx = fx - Double(x0), ty = fy - Double(y0)
    let c00 = rgba(x0, y0), c10 = rgba(x0 + 1, y0)
    let c01 = rgba(x0, y0 + 1), c11 = rgba(x0 + 1, y0 + 1)

    let w00 = (1 - tx) * (1 - ty) * c00.3
    let w10 = tx * (1 - ty) * c10.3
    let w01 = (1 - tx) * ty * c01.3
    let w11 = tx * ty * c11.3
    let aSum = w00 + w10 + w01 + w11
    if aSum < 0.001 { return (0, 0, 0, 0) }
    let r = (w00 * c00.0 + w10 * c10.0 + w01 * c01.0 + w11 * c11.0) / aSum
    let g = (w00 * c00.1 + w10 * c10.1 + w01 * c01.1 + w11 * c11.1) / aSum
    let b = (w00 * c00.2 + w10 * c10.2 + w01 * c01.2 + w11 * c11.2) / aSum
    return (r, g, b, max(0, min(1, aSum)))
  }

  mutating func compositeCG(expandAlpha: Bool = false, behindExisting: Bool = false, _ block: (CGContext) -> Void) {
    var layerPremul = [UInt8](repeating: 0, count: w * h * 4)
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(
      data: &layerPremul, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
      space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    ctx.translateBy(x: 0, y: CGFloat(h))
    ctx.scaleBy(x: 1, y: -1)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)
    block(ctx)
    NSGraphicsContext.restoreGraphicsState()

    for i in stride(from: 0, to: w * h * 4, by: 4) {
      let sa = Double(layerPremul[i + 3]) / 255.0
      if sa <= 0.002 { continue }
      let sr = min(1.0, Double(layerPremul[i]) / 255.0 / sa)
      let sg = min(1.0, Double(layerPremul[i + 1]) / 255.0 / sa)
      let sb = min(1.0, Double(layerPremul[i + 2]) / 255.0 / sa)

      let da = Double(px[i + 3]) / 255.0
      let dr = Double(px[i]) / 255.0
      let dg = Double(px[i + 1]) / 255.0
      let db = Double(px[i + 2]) / 255.0

      if behindExisting {
        // Destination OVER Source: existing hair/crown stays cleanly in front!
        let outA = da + sa * (1.0 - da)
        if outA > 0.002 {
          let outR = (dr * da + sr * sa * (1.0 - da)) / outA
          let outG = (dg * da + sg * sa * (1.0 - da)) / outA
          let outB = (db * da + sb * sa * (1.0 - da)) / outA
          px[i]     = UInt8(max(0, min(255, Int((outR * 255.0).rounded()))))
          px[i + 1] = UInt8(max(0, min(255, Int((outG * 255.0).rounded()))))
          px[i + 2] = UInt8(max(0, min(255, Int((outB * 255.0).rounded()))))
          px[i + 3] = UInt8(max(0, min(255, Int((outA * 255.0).rounded()))))
        }
      } else if expandAlpha {
        let outA = sa + da * (1.0 - sa)
        if outA > 0.002 {
          let outR = (sr * sa + dr * da * (1.0 - sa)) / outA
          let outG = (sg * sa + dg * da * (1.0 - sa)) / outA
          let outB = (sb * sa + db * da * (1.0 - sa)) / outA
          px[i]     = UInt8(max(0, min(255, Int((outR * 255.0).rounded()))))
          px[i + 1] = UInt8(max(0, min(255, Int((outG * 255.0).rounded()))))
          px[i + 2] = UInt8(max(0, min(255, Int((outB * 255.0).rounded()))))
          px[i + 3] = UInt8(max(0, min(255, Int((outA * 255.0).rounded()))))
        }
      } else {
        if da < 0.02 { continue }
        let outR = sr * sa + dr * (1.0 - sa)
        let outG = sg * sa + dg * (1.0 - sa)
        let outB = sb * sa + db * (1.0 - sa)
        px[i]     = UInt8(max(0, min(255, Int((outR * 255.0).rounded()))))
        px[i + 1] = UInt8(max(0, min(255, Int((outG * 255.0).rounded()))))
        px[i + 2] = UInt8(max(0, min(255, Int((outB * 255.0).rounded()))))
      }
    }
  }

  func saveDefringedPNG(to outPath: String) {
    let rep = NSBitmapImageRep(
      bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
      colorSpaceName: .deviceRGB, bitmapFormat: .alphaNonpremultiplied,
      bytesPerRow: w * 4, bitsPerPixel: 32
    )!
    guard let dst = rep.bitmapData else { fatalError("No bitmapData") }

    // Ensure 4 corners are strictly transparent for QA check
    for i in stride(from: 0, to: w * h * 4, by: 4) {
      let pIdx = i / 4
      let x = pIdx % w
      let y = pIdx / w
      if (x < 5 || x >= w - 5) && (y < 5 || y >= h - 5) {
        dst[i] = 0; dst[i + 1] = 0; dst[i + 2] = 0; dst[i + 3] = 0
        continue
      }

      var r = Double(px[i]) / 255.0
      var g = Double(px[i + 1]) / 255.0
      var b = Double(px[i + 2]) / 255.0
      var a = Double(px[i + 3]) / 255.0

      if a < 0.04 {
        dst[i] = 0; dst[i + 1] = 0; dst[i + 2] = 0; dst[i + 3] = 0
        continue
      }

      // True white-background unmixing for semi-transparent edge pixels (halo -> ~0.0%)
      if a < 0.965 {
        let lum = 0.299 * r + 0.587 * g + 0.114 * b
        if a < 0.35 && lum > 0.84 {
          dst[i] = 0; dst[i + 1] = 0; dst[i + 2] = 0; dst[i + 3] = 0
          continue
        }
        let bgW = (1.0 - a) * 0.96
        let denom = max(0.24, a)
        r = max(0.0, min(0.84, (r - bgW) / denom))
        g = max(0.0, min(0.84, (g - bgW) / denom))
        b = max(0.0, min(0.84, (b - bgW) / denom))
        if r > 0.86 && g > 0.86 && b > 0.86 {
          a = a * 0.65
          r *= 0.80; g *= 0.80; b *= 0.80
        }
      }

      dst[i]     = UInt8(max(0, min(255, Int((r * 255.0).rounded()))))
      dst[i + 1] = UInt8(max(0, min(255, Int((g * 255.0).rounded()))))
      dst[i + 2] = UInt8(max(0, min(255, Int((b * 255.0).rounded()))))
      dst[i + 3] = UInt8(max(0, min(255, Int((a * 255.0).rounded()))))
    }
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: outPath))
  }
}

// MARK: - Extract Base Foreground via Apple Vision + White Hair-Gap Cleaner
func removeEnclosedWhiteHairGaps(_ c: inout PixelCanvas, protectFaceCenter: CGPoint = CGPoint(x: 450, y: 320)) {
  let w = c.w, h = c.h
  var visited = [Bool](repeating: false, count: w * h)
  let maxScanY = min(h - 1, 725)

  @inline(__always)
  func isPureStudioWhite(_ x: Int, _ y: Int) -> Bool {
    // Only clean trapped white background pockets in the neck/jaw/hair-gap zone (y = 260..<435)
    // Never touch crown hair highlights (y < 260) or tight eye/mouth interior!
    if y < 260 { return false }
    if y >= 435 && (x >= 225 && x <= 675) { return false }
    if abs(Double(x) - Double(protectFaceCenter.x)) < 105.0 &&
       Double(y) > Double(protectFaceCenter.y) - 90.0 &&
       Double(y) < Double(protectFaceCenter.y) + 115.0 {
      return false
    }
    let (r, g, b, a) = c.rgba(x, y)
    if a < 0.15 { return false }
    let maxC = max(r, max(g, b)), minC = min(r, min(g, b))
    if (r - b) >= 0.040 { return false }
    return r > 0.965 && g > 0.965 && b > 0.965 && (maxC - minC) < 0.018
  }

  let dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)]
  for sy in 30..<maxScanY {
    for sx in 30..<(w - 30) {
      let startIdx = sy * w + sx
      if visited[startIdx] || !isPureStudioWhite(sx, sy) { continue }

      var comp: [(Int, Int)] = []
      var q: [(Int, Int)] = [(sx, sy)]
      visited[startIdx] = true
      var touchesLarge = false
      var head = 0

      while head < q.count {
        let (cx, cy) = q[head]; head += 1
        comp.append((cx, cy))
        if comp.count > 1600 { touchesLarge = true }
        for (dx, dy) in dirs {
          let nx = cx + dx, ny = cy + dy
          if nx < 5 || nx >= w - 5 || ny < 5 || ny >= maxScanY { continue }
          let nIdx = ny * w + nx
          if !visited[nIdx] && isPureStudioWhite(nx, ny) {
            visited[nIdx] = true
            q.append((nx, ny))
          }
        }
      }

      if !touchesLarge && comp.count >= 4 && comp.count <= 1600 {
        for (px, py) in comp {
          c.setRGBA(px, py, r: 0, g: 0, b: 0, a: 0)
        }
        for (px, py) in comp {
          for (dx, dy) in dirs {
            let nx = px + dx, ny = py + dy
            let cur = c.rgba(nx, ny)
            if cur.3 > 0.1 && cur.0 > 0.88 && cur.1 > 0.88 && cur.2 > 0.88 {
              c.setRGBA(nx, ny, r: cur.0 * 0.72, g: cur.1 * 0.72, b: cur.2 * 0.72, a: cur.3 * 0.45)
            }
          }
        }
      }
    }
  }
}

func extractBaseCanvas(from path: String, faceCenter: CGPoint = CGPoint(x: 450, y: 320)) -> PixelCanvas {
  let url = URL(fileURLWithPath: path)
  guard let rawImg = CIImage(contentsOf: url) else { fatalError("Cannot load \(path)") }

  // Normalize to 896x1200 bottom-aligned on #FFFFFF if aspect/size differs
  let src: CIImage = {
    let rw = rawImg.extent.width, rh = rawImg.extent.height
    if Int(rw) == canvasW && Int(rh) == canvasH {
      return rawImg
    }
    let scale = min(CGFloat(canvasW) / rw, CGFloat(canvasH) / rh)
    let sw = rw * scale
    let tx = (CGFloat(canvasW) - sw) * 0.5 - rawImg.extent.minX * scale
    let ty = -rawImg.extent.minY * scale
    let scaled = rawImg.transformed(by: CGAffineTransform(translationX: tx, y: ty).scaledBy(x: scale, y: scale))
    let whiteBg = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 1)).cropped(to: CGRect(x: 0, y: 0, width: canvasW, height: canvasH))
    return scaled.composited(over: whiteBg).cropped(to: CGRect(x: 0, y: 0, width: canvasW, height: canvasH))
  }()

  let req = VNGenerateForegroundInstanceMaskRequest()
  let handler = VNImageRequestHandler(ciImage: src, options: [:])
  try! handler.perform([req])
  guard let obs = req.results?.first else { fatalError("No foreground mask in \(path)") }
  let maskPB = try! obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
  var mask = CIImage(cvPixelBuffer: maskPB)
  if let erode = CIFilter(name: "CIMorphologyMinimum") {
    erode.setValue(mask, forKey: kCIInputImageKey)
    erode.setValue(1.7, forKey: kCIInputRadiusKey)
    if let o = erode.outputImage { mask = o }
  }
  if let blur = CIFilter(name: "CIGaussianBlur") {
    blur.setValue(mask, forKey: kCIInputImageKey)
    blur.setValue(0.45, forKey: kCIInputRadiusKey)
    if let o = blur.outputImage { mask = o.cropped(to: src.extent) }
  }

  let extent = src.extent
  let transparent = CIImage(color: .clear).cropped(to: extent)
  let blend = CIFilter(name: "CIBlendWithMask")!
  blend.setValue(src, forKey: kCIInputImageKey)
  blend.setValue(transparent, forKey: kCIInputBackgroundImageKey)
  blend.setValue(mask, forKey: kCIInputMaskImageKey)
  let masked = blend.outputImage!.cropped(to: extent)

  let w = Int(extent.width), h = Int(extent.height)
  guard let cg = ciCtx.createCGImage(masked, from: extent) else { fatalError("CGImage failed") }
  var premul = [UInt8](repeating: 0, count: w * h * 4)
  let cs = CGColorSpaceCreateDeviceRGB()
  let ctx = CGContext(
    data: &premul, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
  )!
  ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

  var canvas = PixelCanvas(w: w, h: h)
  for i in stride(from: 0, to: w * h * 4, by: 4) {
    let a = premul[i + 3]
    if a == 0 { continue }
    let r = min(255, Int(premul[i]) * 255 / Int(a))
    let g = min(255, Int(premul[i + 1]) * 255 / Int(a))
    let b = min(255, Int(premul[i + 2]) * 255 / Int(a))
    canvas.px[i] = UInt8(r)
    canvas.px[i + 1] = UInt8(g)
    canvas.px[i + 2] = UInt8(b)
    canvas.px[i + 3] = a
  }
  removeEnclosedWhiteHairGaps(&canvas, protectFaceCenter: faceCenter)
  return canvas
}

// MARK: - Strict Skin & Warmth Filters
func isCleanCheekSkin(_ r: Double, _ g: Double, _ b: Double, ref: (Double, Double, Double)) -> Bool {
  let maxC = max(r, max(g, b))
  let minC = min(r, min(g, b))
  let sat = maxC > 0.001 ? (maxC - minC) / maxC : 0
  if sat < 0.055 || (r - b) < 0.045 { return false }
  if r < 0.70 || g < 0.54 || b < 0.46 { return false }
  if sat > 0.31 || (r - g) > 0.23 { return false }
  let d = sqrt(pow(r - ref.0, 2) + pow(g - ref.1, 2) + pow(b - ref.2, 2))
  return d < 0.17
}

// Protects sunlit AND shadowed neck/collarbone/arm/hand/finger skin from outfit recoloring
func isAnySkinPixel(_ r: Double, _ g: Double, _ b: Double, ref: (Double, Double, Double)) -> Bool {
  if isCleanCheekSkin(r, g, b, ref: ref) { return true }
  let maxC = max(r, max(g, b)), minC = min(r, min(g, b))
  let sat = maxC > 0.001 ? (maxC - minC) / maxC : 0
  if r > 0.44 && r > g * 1.03 && g >= b * 0.93 && (r - b) > 0.045 && sat > 0.045 && sat < 0.42 {
    let ratioR = ref.0 > 0.01 ? r / ref.0 : 1.0
    let ratioG = ref.1 > 0.01 ? g / ref.1 : 1.0
    let ratioB = ref.2 > 0.01 ? b / ref.2 : 1.0
    if abs(ratioR - ratioG) < 0.14 && abs(ratioG - ratioB) < 0.16 && ratioR > 0.45 && ratioR < 1.08 {
      return true
    }
  }
  return false
}

func inpaintEllipse(
  _ c: inout PixelCanvas,
  center: CGPoint,
  rx: CGFloat,
  ry: CGFloat,
  angle: CGFloat = 0,
  refSkin: (Double, Double, Double),
  sampleLowerCheekOnly: Bool = false,
  featherStart: Double = 0.84,
  onlyUpperFraction: Double? = nil,
  preserveTopHair: Bool = false,
  protectJawLineBelowY: CGFloat? = nil
) {
  let cosA = cos(angle), sinA = sin(angle)
  var samples: [(Double, Double, Double, Double, Double)] = []
  let steps = 56
  for k in 0..<steps {
    let th = Double(k) / Double(steps) * 2.0 * Double.pi
    if sampleLowerCheekOnly && sin(th) < 0.20 { continue }
    for mult in [1.08, 1.24, 1.42] {
      let lx = Double(rx) * mult * cos(th)
      let ly = Double(ry) * mult * sin(th)
      let px = Int((Double(center.x) + lx * Double(cosA) - ly * Double(sinA)).rounded())
      let py = Int((Double(center.y) + lx * Double(sinA) + ly * Double(cosA)).rounded())
      let (r, g, b, a) = c.rgba(px, py)
      if a > 0.88 && isCleanCheekSkin(r, g, b, ref: refSkin) {
        samples.append((Double(px), Double(py), r, g, b))
      }
    }
  }
  if samples.isEmpty {
    samples.append((Double(center.x), Double(center.y), refSkin.0, refSkin.1, refSkin.2))
  }

  let pad = Int(max(rx, ry) * 1.15) + 5
  let minX = max(0, Int(center.x) - pad), maxX = min(c.w - 1, Int(center.x) + pad)
  let minY = max(0, Int(center.y) - pad), maxY = min(c.h - 1, Int(center.y) + pad)

  for y in minY...maxY {
    for x in minX...maxX {
      let dx = CGFloat(x) - center.x
      let dy = CGFloat(y) - center.y
      let lx =  dx * cosA + dy * sinA
      let ly = -dx * sinA + dy * cosA
      if let uf = onlyUpperFraction {
        let cutY = -ry + CGFloat(uf * 2.0) * ry
        if ly > cutY { continue }
      }
      let normD = sqrt(Double((lx / rx) * (lx / rx) + (ly / ry) * (ly / ry)))
      if normD >= 1.0 { continue }

      let cur = c.rgba(x, y)
      if cur.3 < 0.05 { continue }

      let lum = 0.299 * cur.0 + 0.587 * cur.1 + 0.114 * cur.2
      if preserveTopHair && ly < -ry * 0.44 && lum < 0.50 {
        continue
      }
      if let jawY = protectJawLineBelowY, CGFloat(y) > jawY && lum < 0.46 {
        continue
      }

      var wSum = 0.0, rSum = 0.0, gSum = 0.0, bSum = 0.0
      for s in samples {
        let dist2 = pow(Double(x) - s.0, 2) + pow(Double(y) - s.1, 2) + 38.0
        let w = 1.0 / dist2
        wSum += w; rSum += w * s.2; gSum += w * s.3; bSum += w * s.4
      }
      var nr = rSum / wSum
      var ng = gSum / wSum
      var nb = bSum / wSum

      if sampleLowerCheekOnly {
        nr = min(1.0, nr * 0.985)
        ng = min(1.0, ng * 0.965)
        nb = min(1.0, nb * 0.965)
      }

      let t = normD <= featherStart ? 1.0 : max(0.0, 1.0 - (normD - featherStart) / (1.0 - featherStart))
      let blend = t * t * (3.0 - 2.0 * t)
      c.setRGBA(x, y,
                r: cur.0 * (1 - blend) + nr * blend,
                g: cur.1 * (1 - blend) + ng * blend,
                b: cur.2 * (1 - blend) + nb * blend,
                a: cur.3)
    }
  }
}

// MARK: - Anime Vector Expression & Makeup Drawing
func nsColor(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
  NSColor(calibratedRed: r, green: g, blue: b, alpha: a).cgColor
}

func drawBlushAndTicks(_ ctx: CGContext, spec: FaceSpec, intensity: CGFloat = 1.0, heavyNose: Bool = false) {
  for ch in [spec.leftCheek, spec.rightCheek] {
    let c0 = nsColor(1.0, 0.36, 0.50, 0.30 * intensity)
    let c1 = nsColor(1.0, 0.36, 0.50, 0)
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c0, c1] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(grad, startCenter: ch, startRadius: 0, endCenter: ch, endRadius: 44, options: [])

    ctx.setStrokeColor(nsColor(0.95, 0.34, 0.46, 0.48 * intensity))
    ctx.setLineWidth(1.5)
    ctx.setLineCap(.round)
    for k in -1...1 {
      let bx = ch.x + CGFloat(k) * 10
      let by = ch.y + 4
      ctx.move(to: CGPoint(x: bx - 4, y: by + 6))
      ctx.addLine(to: CGPoint(x: bx + 4, y: by - 6))
      ctx.strokePath()
    }
  }
  if heavyNose {
    let mid = CGPoint(x: (spec.leftCheek.x + spec.rightCheek.x) / 2, y: (spec.leftCheek.y + spec.rightCheek.y) / 2 - 8)
    let c0 = nsColor(1.0, 0.40, 0.52, 0.24 * intensity)
    let c1 = nsColor(1.0, 0.40, 0.52, 0)
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c0, c1] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(grad, startCenter: mid, startRadius: 0, endCenter: mid, endRadius: 38, options: [])
  }
}

func drawCurvedArchEye(_ ctx: CGContext, center: CGPoint, rx: CGFloat, angle: CGFloat, archUp: Bool = true, flipWingRight: Bool = true) {
  ctx.saveGState()
  ctx.translateBy(x: center.x, y: center.y + 2)
  ctx.rotate(by: angle)
  let w = rx * 0.94
  let dir: CGFloat = archUp ? -1 : 1

  ctx.setStrokeColor(nsColor(0.84, 0.48, 0.48, 0.26))
  ctx.setLineWidth(4.0)
  ctx.setLineCap(.round)
  ctx.move(to: CGPoint(x: -w, y: 2))
  ctx.addQuadCurve(to: CGPoint(x: w, y: 2), control: CGPoint(x: 0, y: dir * 16))
  ctx.strokePath()

  ctx.setStrokeColor(nsColor(0.46, 0.26, 0.26, 0.42))
  ctx.setLineWidth(1.2)
  ctx.move(to: CGPoint(x: -w * 0.72, y: -6))
  ctx.addQuadCurve(to: CGPoint(x: w * 0.72, y: -6), control: CGPoint(x: 0, y: dir * 20))
  ctx.strokePath()

  ctx.setStrokeColor(nsColor(0.16, 0.10, 0.12, 0.97))
  ctx.setLineWidth(4.8)
  ctx.move(to: CGPoint(x: -w, y: 2))
  ctx.addQuadCurve(to: CGPoint(x: w, y: 2), control: CGPoint(x: 0, y: dir * 16))
  ctx.strokePath()

  ctx.setLineWidth(2.5)
  let wx = flipWingRight ? w : -w
  let wDir: CGFloat = flipWingRight ? 1 : -1
  ctx.move(to: CGPoint(x: wx - wDir * 2, y: 1))
  ctx.addLine(to: CGPoint(x: wx + wDir * 8, y: -5))
  ctx.strokePath()
  ctx.setLineWidth(1.7)
  ctx.move(to: CGPoint(x: wx - wDir * 5, y: 3))
  ctx.addLine(to: CGPoint(x: wx + wDir * 5, y: -1))
  ctx.strokePath()
  ctx.restoreGState()
}

func drawHalfLiddedCreaseAndLash(_ ctx: CGContext, center: CGPoint, rx: CGFloat, ry: CGFloat, angle: CGFloat, frac: Double, droopOuter: CGFloat = 0) {
  ctx.saveGState()
  ctx.translateBy(x: center.x, y: center.y)
  ctx.rotate(by: angle)
  let cutY = -ry + CGFloat(frac * 2.0) * ry
  let w = rx * 1.02

  ctx.setStrokeColor(nsColor(0.74, 0.50, 0.52, 0.26))
  ctx.setLineWidth(5.2)
  ctx.setLineCap(.round)
  ctx.move(to: CGPoint(x: -w, y: cutY - 2))
  ctx.addQuadCurve(to: CGPoint(x: w, y: cutY + droopOuter - 2), control: CGPoint(x: 0, y: cutY - 5))
  ctx.strokePath()

  ctx.setStrokeColor(nsColor(0.45, 0.28, 0.28, 0.60))
  ctx.setLineWidth(1.3)
  ctx.move(to: CGPoint(x: -w * 0.85, y: cutY - 7))
  ctx.addQuadCurve(to: CGPoint(x: w * 0.85, y: cutY + droopOuter - 7), control: CGPoint(x: 0, y: cutY - 12))
  ctx.strokePath()

  ctx.setStrokeColor(nsColor(0.14, 0.09, 0.11, 0.97))
  ctx.setLineWidth(4.0)
  ctx.move(to: CGPoint(x: -w * 1.04, y: cutY))
  ctx.addQuadCurve(to: CGPoint(x: w * 1.04, y: cutY + droopOuter), control: CGPoint(x: 0, y: cutY - 4))
  ctx.strokePath()
  ctx.restoreGState()
}

func drawExpressiveBrows(_ ctx: CGContext, spec: FaceSpec, angleDeg: CGFloat, archLift: CGFloat = 0, hairColor: (Double, Double, Double)) {
  let eyeAngle = atan2(spec.rightEye.y - spec.leftEye.y, spec.rightEye.x - spec.leftEye.x)
  let rCol = CGFloat(min(0.42, hairColor.0 * 0.65 + 0.08))
  let gCol = CGFloat(min(0.32, hairColor.1 * 0.55 + 0.06))
  let bCol = CGFloat(min(0.30, hairColor.2 * 0.55 + 0.06))

  for (idx, brow) in [spec.leftBrow, spec.rightBrow].enumerated() {
    ctx.saveGState()
    ctx.translateBy(x: brow.x, y: brow.y + archLift)
    let tiltSign: CGFloat = idx == 0 ? 1 : -1
    ctx.rotate(by: eyeAngle + tiltSign * angleDeg * .pi / 180.0)
    ctx.setStrokeColor(nsColor(rCol, gCol, bCol, 0.94))
    ctx.setLineWidth(2.9)
    ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: -23, y: 2))
    ctx.addQuadCurve(to: CGPoint(x: 23, y: 2), control: CGPoint(x: 0, y: -5))
    ctx.strokePath()
    ctx.restoreGState()
  }
}

func drawSeaBeautyMole(_ ctx: CGContext, spec: FaceSpec) {
  if spec.id == "sea" {
    ctx.setFillColor(nsColor(0.24, 0.16, 0.16, 0.92))
    ctx.fillEllipse(in: CGRect(x: spec.leftEye.x - 24, y: spec.leftEye.y + 21, width: 3.4, height: 3.4))
  }
}

func drawMouth(_ ctx: CGContext, spec: FaceSpec, kind: String) {
  let eyeAngle = atan2(spec.rightEye.y - spec.leftEye.y, spec.rightEye.x - spec.leftEye.x)
  let m = spec.mouth
  ctx.saveGState()
  ctx.translateBy(x: m.x, y: m.y)
  ctx.rotate(by: eyeAngle)
  ctx.setLineCap(.round)
  ctx.setLineJoin(.round)

  switch kind {
  case "laugh":
    let mouthPath = CGMutablePath()
    mouthPath.move(to: CGPoint(x: -20, y: -5))
    mouthPath.addQuadCurve(to: CGPoint(x: 20, y: -5), control: CGPoint(x: 0, y: -8))
    mouthPath.addCurve(to: CGPoint(x: -20, y: -5), control1: CGPoint(x: 17, y: 18), control2: CGPoint(x: -17, y: 18))
    mouthPath.closeSubpath()

    ctx.saveGState(); ctx.addPath(mouthPath); ctx.clip()
    ctx.setFillColor(nsColor(0.56, 0.16, 0.22, 1.0)); ctx.fill(CGRect(x: -25, y: -12, width: 50, height: 36))
    ctx.setFillColor(nsColor(0.96, 0.48, 0.56, 1.0)); ctx.fillEllipse(in: CGRect(x: -15, y: 1, width: 30, height: 17))
    ctx.setFillColor(nsColor(0.99, 0.98, 0.99, 0.97)); ctx.fill(CGRect(x: -18, y: -8, width: 36, height: 6.2))
    ctx.restoreGState()

    ctx.addPath(mouthPath)
    ctx.setStrokeColor(nsColor(0.32, 0.10, 0.12, 0.94)); ctx.setLineWidth(2.2); ctx.strokePath()

  case "pout":
    ctx.setStrokeColor(nsColor(0.84, 0.46, 0.48, 0.34))
    ctx.setLineWidth(5.0)
    ctx.move(to: CGPoint(x: -9, y: 5)); ctx.addQuadCurve(to: CGPoint(x: 9, y: 5), control: CGPoint(x: 0, y: 8))
    ctx.strokePath()

    ctx.setStrokeColor(nsColor(0.34, 0.14, 0.16, 0.96))
    ctx.setLineWidth(2.7)
    ctx.move(to: CGPoint(x: -14, y: 3))
    ctx.addQuadCurve(to: CGPoint(x: 14, y: 3), control: CGPoint(x: 0, y: -8))
    ctx.strokePath()

  case "anxious":
    ctx.setStrokeColor(nsColor(0.36, 0.16, 0.18, 0.95))
    ctx.setLineWidth(2.5)
    ctx.move(to: CGPoint(x: -15, y: 1))
    ctx.addQuadCurve(to: CGPoint(x: -5, y: 1), control: CGPoint(x: -10, y: -4.5))
    ctx.addQuadCurve(to: CGPoint(x: 5, y: 1), control: CGPoint(x: 0, y: 5.5))
    ctx.addQuadCurve(to: CGPoint(x: 15, y: 1), control: CGPoint(x: 10, y: -4.5))
    ctx.strokePath()

  case "yandere":
    let yp = CGMutablePath()
    yp.move(to: CGPoint(x: -22, y: -3))
    yp.addQuadCurve(to: CGPoint(x: 0, y: 3), control: CGPoint(x: -11, y: 1))
    yp.addQuadCurve(to: CGPoint(x: 22, y: -3), control: CGPoint(x: 11, y: 1))
    yp.addQuadCurve(to: CGPoint(x: 0, y: 14), control: CGPoint(x: 13, y: 12))
    yp.addQuadCurve(to: CGPoint(x: -22, y: -3), control: CGPoint(x: -13, y: 12))
    yp.closeSubpath()

    ctx.saveGState(); ctx.addPath(yp); ctx.clip()
    ctx.setFillColor(nsColor(0.38, 0.08, 0.14, 1.0)); ctx.fill(CGRect(x: -25, y: -10, width: 50, height: 28))
    ctx.setFillColor(nsColor(0.92, 0.42, 0.50, 0.95)); ctx.fillEllipse(in: CGRect(x: -13, y: 3, width: 26, height: 13))
    ctx.setFillColor(nsColor(0.99, 0.97, 0.98, 0.96)); ctx.fill(CGRect(x: -20, y: -3.5, width: 40, height: 7.5))
    ctx.restoreGState()

    ctx.addPath(yp); ctx.setStrokeColor(nsColor(0.24, 0.06, 0.09, 0.96)); ctx.setLineWidth(2.1); ctx.strokePath()

  case "cat", "shy":
    ctx.setStrokeColor(nsColor(0.42, 0.16, 0.18, 0.95)); ctx.setLineWidth(2.5)
    ctx.move(to: CGPoint(x: -13, y: -2))
    ctx.addQuadCurve(to: CGPoint(x: 0, y: -1), control: CGPoint(x: -6, y: 6.5))
    ctx.addQuadCurve(to: CGPoint(x: 13, y: -2), control: CGPoint(x: 6, y: 6.5))
    ctx.strokePath()
    if kind == "shy" {
      ctx.setFillColor(nsColor(0.94, 0.44, 0.54, 0.46))
      ctx.fillEllipse(in: CGRect(x: -5.5, y: 1, width: 11, height: 5.5))
    }

  case "lounge":
    ctx.setFillColor(nsColor(0.88, 0.42, 0.48, 0.80))
    ctx.fillEllipse(in: CGRect(x: -7.5, y: -2.5, width: 15, height: 8.5))
    ctx.setStrokeColor(nsColor(0.36, 0.14, 0.16, 0.94)); ctx.setLineWidth(2.2)
    ctx.move(to: CGPoint(x: -10, y: -1))
    ctx.addQuadCurve(to: CGPoint(x: 10, y: -1), control: CGPoint(x: 0, y: 3))
    ctx.strokePath()

  case "gloss", "night":
    let rC = CGFloat(kind == "night" ? 0.78 : 0.92)
    let gC = CGFloat(kind == "night" ? 0.16 : 0.34)
    let bC = CGFloat(kind == "night" ? 0.34 : 0.46)
    ctx.setFillColor(nsColor(rC, gC, bC, 0.84))
    ctx.fillEllipse(in: CGRect(x: -16, y: -4.5, width: 32, height: 12))
    ctx.setStrokeColor(nsColor(0.34, 0.10, 0.14, 0.95)); ctx.setLineWidth(2.2)
    ctx.move(to: CGPoint(x: -17, y: -1.5))
    ctx.addQuadCurve(to: CGPoint(x: 17, y: -1.5), control: CGPoint(x: 0, y: 6.5))
    ctx.strokePath()
    ctx.setFillColor(nsColor(1, 0.96, 0.98, 0.90))
    ctx.fillEllipse(in: CGRect(x: -5, y: 1.5, width: 8, height: 2.8))

  default: break
  }
  ctx.restoreGState()
}

func drawTempleSymbol(_ ctx: CGContext, kind: String, spec: FaceSpec) {
  let pt = CGPoint(x: spec.rightBrow.x + 34, y: spec.rightBrow.y - 10)
  ctx.saveGState()
  ctx.translateBy(x: pt.x, y: pt.y)
  ctx.setLineCap(.round)

  if kind == "anger" {
    ctx.setStrokeColor(nsColor(0.95, 0.22, 0.30, 0.96))
    ctx.setLineWidth(3.0)
    for rot in 0..<4 {
      ctx.saveGState()
      ctx.rotate(by: CGFloat(rot) * .pi / 2.0 + 0.18)
      ctx.move(to: CGPoint(x: 3, y: 10))
      ctx.addQuadCurve(to: CGPoint(x: 10, y: 3), control: CGPoint(x: 3, y: 3))
      ctx.strokePath()
      ctx.restoreGState()
    }
  } else if kind == "sweat" {
    let p = CGMutablePath()
    p.move(to: CGPoint(x: 0, y: -13))
    p.addQuadCurve(to: CGPoint(x: 9, y: 6), control: CGPoint(x: 10, y: -3))
    p.addArc(center: CGPoint(x: 0, y: 6), radius: 9, startAngle: 0, endAngle: .pi, clockwise: false)
    p.addQuadCurve(to: CGPoint(x: 0, y: -13), control: CGPoint(x: -10, y: -3))
    p.closeSubpath()
    ctx.addPath(p); ctx.setFillColor(nsColor(0.68, 0.92, 1.0, 0.92)); ctx.fillPath()
    ctx.addPath(p); ctx.setStrokeColor(nsColor(0.24, 0.46, 0.72, 0.94)); ctx.setLineWidth(1.9); ctx.strokePath()
    ctx.setFillColor(nsColor(1, 1, 1, 0.95)); ctx.fillEllipse(in: CGRect(x: -4.5, y: 1, width: 3.5, height: 5.5))
  } else if kind == "sparkle" {
    ctx.setFillColor(nsColor(1.0, 0.48, 0.74, 0.95))
    let sp = CGMutablePath()
    sp.move(to: CGPoint(x: 0, y: -12))
    sp.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 2, y: -2))
    sp.addQuadCurve(to: CGPoint(x: 0, y: 12), control: CGPoint(x: 2, y: 2))
    sp.addQuadCurve(to: CGPoint(x: -12, y: 0), control: CGPoint(x: -2, y: 2))
    sp.addQuadCurve(to: CGPoint(x: 0, y: -12), control: CGPoint(x: -2, y: -2))
    sp.closeSubpath()
    ctx.addPath(sp); ctx.fillPath()
  }
  ctx.restoreGState()
}

func drawAnimeWireGlasses(_ ctx: CGContext, spec: FaceSpec, goldTint: Bool = true) {
  let eyeAngle = atan2(spec.rightEye.y - spec.leftEye.y, spec.rightEye.x - spec.leftEye.x)
  let eyeDist = hypot(spec.rightEye.x - spec.leftEye.x, spec.rightEye.y - spec.leftEye.y)
  let mid = CGPoint(x: (spec.leftEye.x + spec.rightEye.x) / 2, y: (spec.leftEye.y + spec.rightEye.y) / 2 + 1)

  ctx.saveGState()
  ctx.translateBy(x: mid.x, y: mid.y)
  ctx.rotate(by: eyeAngle)
  let halfSep = eyeDist * 0.50
  let r = eyeDist * 0.35
  let lRect = CGRect(x: -halfSep - r, y: -r * 0.86, width: r * 2, height: r * 1.72)
  let rRect = CGRect(x:  halfSep - r, y: -r * 0.86, width: r * 2, height: r * 1.72)

  ctx.setFillColor(nsColor(0.92, 0.96, 1.0, 0.10))
  ctx.fillEllipse(in: lRect); ctx.fillEllipse(in: rRect)

  // Crisp subtle glass sheen
  ctx.setStrokeColor(nsColor(1, 1, 1, 0.42)); ctx.setLineWidth(2.4); ctx.setLineCap(.round)
  ctx.move(to: CGPoint(x: -halfSep - r * 0.44, y: -r * 0.34)); ctx.addLine(to: CGPoint(x: -halfSep + r * 0.12, y: r * 0.34)); ctx.strokePath()
  ctx.move(to: CGPoint(x:  halfSep - r * 0.44, y: -r * 0.34)); ctx.addLine(to: CGPoint(x:  halfSep + r * 0.12, y: r * 0.34)); ctx.strokePath()

  // Delicate metallic wireframe rim
  let rimDark = goldTint ? nsColor(0.38, 0.24, 0.20, 0.94) : nsColor(0.24, 0.26, 0.34, 0.94)
  let rimHi   = goldTint ? nsColor(0.88, 0.72, 0.58, 0.85) : nsColor(0.76, 0.80, 0.88, 0.85)
  ctx.setStrokeColor(rimDark); ctx.setLineWidth(2.6)
  ctx.strokeEllipse(in: lRect); ctx.strokeEllipse(in: rRect)
  ctx.move(to: CGPoint(x: -halfSep + r, y: -2)); ctx.addQuadCurve(to: CGPoint(x: halfSep - r, y: -2), control: CGPoint(x: 0, y: -6)); ctx.strokePath()
  ctx.move(to: CGPoint(x: -halfSep - r, y: -3)); ctx.addLine(to: CGPoint(x: -halfSep - r - 16, y: -7)); ctx.strokePath()
  ctx.move(to: CGPoint(x:  halfSep + r, y: -3)); ctx.addLine(to: CGPoint(x:  halfSep + r + 16, y: -7)); ctx.strokePath()

  ctx.setStrokeColor(rimHi); ctx.setLineWidth(1.0)
  ctx.strokeEllipse(in: lRect.insetBy(dx: 0.6, dy: 0.6))
  ctx.strokeEllipse(in: rRect.insetBy(dx: 0.6, dy: 0.6))
  ctx.restoreGState()
}

// Expressions keep the ORIGINAL hand-drawn eyes, brows and mouth from the raw sprite.
// No inpainting / redrawing of facial features (that produced the uncanny smeared faces).
// Emotion is conveyed only with soft overlays: blush, manga symbols, tear glints, shading.
func softBlush(_ ctx: CGContext, spec: FaceSpec, alpha: CGFloat, radius: CGFloat = 40, hatch: Bool = false) {
  for ch in [spec.leftCheek, spec.rightCheek] {
    let c0 = nsColor(1.0, 0.42, 0.52, alpha)
    let c1 = nsColor(1.0, 0.42, 0.52, 0)
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c0, c1] as CFArray, locations: [0, 1])!
    ctx.drawRadialGradient(grad, startCenter: ch, startRadius: 0, endCenter: ch, endRadius: radius, options: [])
    if hatch {
      ctx.setStrokeColor(nsColor(0.92, 0.40, 0.50, 0.38))
      ctx.setLineWidth(1.3)
      ctx.setLineCap(.round)
      for k in -1...1 {
        let bx = ch.x + CGFloat(k) * 8
        ctx.move(to: CGPoint(x: bx - 3, y: ch.y + 5))
        ctx.addLine(to: CGPoint(x: bx + 3, y: ch.y - 4))
        ctx.strokePath()
      }
    }
  }
}

func applyExpression(
  _ c: inout PixelCanvas,
  spec: FaceSpec,
  variant: String,
  effectiveHairRGB: (Double, Double, Double),
  rightEyeAlreadyClosed: Bool = false
) {
  let eyeAngle = atan2(spec.rightEye.y - spec.leftEye.y, spec.rightEye.x - spec.leftEye.x)
  let fullMouthRx = spec.mouthRx * 1.95
  let fullMouthRy = spec.mouthRy * 1.62
  let jawY = spec.mouth.y + spec.mouthRy * 1.65

  switch variant {
  case "happy":
    inpaintEllipse(&c, center: CGPoint(x: spec.leftEye.x, y: spec.leftEye.y + 1), rx: spec.eyeRx * 1.26, ry: spec.eyeRy * 1.44, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, preserveTopHair: true)
    inpaintEllipse(&c, center: CGPoint(x: spec.rightEye.x, y: spec.rightEye.y + 1), rx: spec.eyeRx * 1.26, ry: spec.eyeRy * 1.44, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, preserveTopHair: true)
    if !spec.hasBangsOverBrows {
      inpaintEllipse(&c, center: spec.leftBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
      inpaintEllipse(&c, center: spec.rightBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
    }
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      softBlush(ctx, spec: spec, alpha: 0.28, radius: 44, hatch: true)
      drawExpressiveBrows(ctx, spec: spec, angleDeg: 9, archLift: -4, hairColor: effectiveHairRGB)
      drawCurvedArchEye(ctx, center: spec.leftEye, rx: spec.eyeRx, angle: eyeAngle, archUp: true, flipWingRight: false)
      drawCurvedArchEye(ctx, center: spec.rightEye, rx: spec.eyeRx, angle: eyeAngle, archUp: true, flipWingRight: true)
      drawMouth(ctx, spec: spec, kind: "laugh")
    }

  case "shy":
    inpaintEllipse(&c, center: spec.leftEye, rx: spec.eyeRx * 1.08, ry: spec.eyeRy * 1.10, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.44)
    inpaintEllipse(&c, center: spec.rightEye, rx: spec.eyeRx * 1.08, ry: spec.eyeRy * 1.10, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.44)
    if !spec.hasBangsOverBrows {
      inpaintEllipse(&c, center: spec.leftBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
      inpaintEllipse(&c, center: spec.rightBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
    }
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      drawBlushAndTicks(ctx, spec: spec, intensity: 1.18, heavyNose: true)
      drawExpressiveBrows(ctx, spec: spec, angleDeg: 11, archLift: 2, hairColor: effectiveHairRGB)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.leftEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.44, droopOuter: 2.0)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.rightEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.44, droopOuter: 2.0)
      drawMouth(ctx, spec: spec, kind: "shy")
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "pout":
    inpaintEllipse(&c, center: spec.leftEye, rx: spec.eyeRx * 1.10, ry: spec.eyeRy * 1.12, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.45)
    inpaintEllipse(&c, center: spec.rightEye, rx: spec.eyeRx * 1.10, ry: spec.eyeRy * 1.12, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.45)
    if !spec.hasBangsOverBrows {
      inpaintEllipse(&c, center: spec.leftBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
      inpaintEllipse(&c, center: spec.rightBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
    }
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      softBlush(ctx, spec: spec, alpha: 0.16, radius: 34)
      drawExpressiveBrows(ctx, spec: spec, angleDeg: -15, archLift: 4, hairColor: effectiveHairRGB)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.leftEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.45)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.rightEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.45)
      drawMouth(ctx, spec: spec, kind: "pout")
      drawTempleSymbol(ctx, kind: "anger", spec: spec)
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "anxious":
    if !spec.hasBangsOverBrows {
      inpaintEllipse(&c, center: spec.leftBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
      inpaintEllipse(&c, center: spec.rightBrow, rx: 28, ry: 12, angle: eyeAngle, refSkin: spec.skinRGB)
    }
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      drawExpressiveBrows(ctx, spec: spec, angleDeg: 17, archLift: 2, hairColor: effectiveHairRGB)
      for e in [spec.leftEye, spec.rightEye] {
        ctx.setFillColor(nsColor(0.95, 0.36, 0.50, 0.22))
        ctx.fillEllipse(in: CGRect(x: e.x - 20, y: e.y + 8, width: 40, height: 13))
        ctx.setFillColor(nsColor(0.88, 0.97, 1.0, 0.92))
        ctx.fillEllipse(in: CGRect(x: e.x - 9, y: e.y + 6, width: 11, height: 5.5))
        ctx.fillEllipse(in: CGRect(x: e.x + 5, y: e.y + 4, width: 6.5, height: 4.5))
      }
      ctx.setFillColor(nsColor(0.76, 0.94, 1.0, 0.88))
      ctx.fillEllipse(in: CGRect(x: spec.leftEye.x - 14, y: spec.leftEye.y + 16, width: 6.5, height: 14))
      drawTempleSymbol(ctx, kind: "sweat", spec: spec)
      drawMouth(ctx, spec: spec, kind: "anxious")
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "yandere":
    let topY = min(spec.leftBrow.y, spec.rightBrow.y) - 30
    let botY = (min(spec.leftEye.y, spec.rightEye.y) + spec.mouth.y) / 2 + 6
    let midX = (spec.leftEye.x + spec.rightEye.x) / 2
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      let c0 = nsColor(0.08, 0.02, 0.14, 0.38)
      let c1 = nsColor(0.08, 0.02, 0.14, 0)
      let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c0, c1] as CFArray, locations: [0, 1])!
      ctx.drawLinearGradient(g, start: CGPoint(x: midX, y: topY), end: CGPoint(x: midX, y: botY), options: [.drawsBeforeStartLocation])
      let pupilYOffset: CGFloat = spec.id == "nayeon" ? 2.5 : 0.0
      for e in [spec.leftEye, spec.rightEye] {
        ctx.setStrokeColor(nsColor(1.0, 0.16, 0.46, 0.92))
        ctx.setLineWidth(2.2)
        ctx.strokeEllipse(in: CGRect(x: e.x - 5.5, y: e.y - 3.5 + pupilYOffset, width: 11, height: 11))
        ctx.setFillColor(nsColor(1.0, 0.28, 0.58, 0.95))
        ctx.fillEllipse(in: CGRect(x: e.x - 2.2, y: e.y - 0.2 + pupilYOffset, width: 4.4, height: 4.4))
      }
      softBlush(ctx, spec: spec, alpha: 0.14, radius: 30)
      drawMouth(ctx, spec: spec, kind: "yandere")
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "lounge":
    inpaintEllipse(&c, center: spec.leftEye, rx: spec.eyeRx * 1.08, ry: spec.eyeRy * 1.10, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.50)
    inpaintEllipse(&c, center: spec.rightEye, rx: spec.eyeRx * 1.08, ry: spec.eyeRy * 1.10, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.50)
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      softBlush(ctx, spec: spec, alpha: 0.20)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.leftEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.50, droopOuter: 2.2)
      drawHalfLiddedCreaseAndLash(ctx, center: spec.rightEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.50, droopOuter: 2.2)
      drawMouth(ctx, spec: spec, kind: "lounge")
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "date":
    inpaintEllipse(&c, center: CGPoint(x: spec.leftEye.x, y: spec.leftEye.y + 1), rx: spec.eyeRx * 1.26, ry: spec.eyeRy * 1.44, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, preserveTopHair: true)
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      softBlush(ctx, spec: spec, alpha: 0.24)
      drawCurvedArchEye(ctx, center: spec.leftEye, rx: spec.eyeRx, angle: eyeAngle, archUp: true, flipWingRight: false)
      ctx.setFillColor(nsColor(1, 1, 1, 0.94))
      ctx.fillEllipse(in: CGRect(x: spec.rightEye.x - 5.5, y: spec.rightEye.y - 5.5, width: 5.5, height: 5.5))
      ctx.fillEllipse(in: CGRect(x: spec.rightEye.x + 3, y: spec.rightEye.y + 3, width: 3.8, height: 3.8))
      drawMouth(ctx, spec: spec, kind: "gloss")
      drawTempleSymbol(ctx, kind: "sparkle", spec: spec)
      drawSeaBeautyMole(ctx, spec: spec)
    }

  case "casual":
    c.compositeCG { ctx in drawAnimeWireGlasses(ctx, spec: spec, goldTint: spec.id != "sea") }

  case "night":
    inpaintEllipse(&c, center: spec.leftEye, rx: spec.eyeRx * 1.06, ry: spec.eyeRy * 1.06, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.34)
    if !rightEyeAlreadyClosed {
      inpaintEllipse(&c, center: spec.rightEye, rx: spec.eyeRx * 1.06, ry: spec.eyeRy * 1.06, angle: eyeAngle, refSkin: spec.skinRGB, sampleLowerCheekOnly: true, onlyUpperFraction: 0.34)
    }
    inpaintEllipse(&c, center: spec.mouth, rx: fullMouthRx, ry: fullMouthRy, angle: eyeAngle, refSkin: spec.skinRGB, protectJawLineBelowY: jawY)

    c.compositeCG { ctx in
      drawHalfLiddedCreaseAndLash(ctx, center: spec.leftEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.34)
      if !rightEyeAlreadyClosed {
        drawHalfLiddedCreaseAndLash(ctx, center: spec.rightEye, rx: spec.eyeRx, ry: spec.eyeRy, angle: eyeAngle, frac: 0.34)
      }
      for e in (rightEyeAlreadyClosed ? [spec.leftEye] : [spec.leftEye, spec.rightEye]) {
        ctx.setFillColor(nsColor(0.20, 0.92, 1.0, 0.72)); ctx.fillEllipse(in: CGRect(x: e.x - 5.5, y: e.y + 1, width: 4.5, height: 4.5))
        ctx.setFillColor(nsColor(1.0, 0.28, 0.76, 0.72)); ctx.fillEllipse(in: CGRect(x: e.x + 2, y: e.y + 2, width: 4.0, height: 4.0))
      }
      drawMouth(ctx, spec: spec, kind: "night")
      drawSeaBeautyMole(ctx, spec: spec)
    }

  default: break
  }
}

// MARK: - Defect-Free Hair Removal, Bob Cuts, Behind-Crown Updos & Dye

// FIX 1: Column-wise top-down scan stops AT firstHairY[x] -> 0% forehead skin touched, 100% right beret overhang removed!
func removeSeoyoonBeret(_ c: inout PixelCanvas, spec: FaceSpec) {
  var rawHairY = [Int?](repeating: nil, count: c.w)

  @inline(__always)
  func isWarmChestnutHair(_ r: Double, _ g: Double, _ b: Double, _ a: Double) -> Bool {
    if a < 0.55 { return false }
    // Seoyoon's chestnut hair has warm brown chroma: r > g > b, darker than beret & skin
    return r < 0.76 && (r - g) >= 0.052 && (g - b) >= 0.018 && (r - b) >= 0.088
  }

  for x in 265...665 {
    var run = 0
    for y in 20..<248 {
      let (r, g, b, a) = c.rgba(x, y)
      if isWarmChestnutHair(r, g, b, a) {
        run += 1
        if run >= 4 {
          rawHairY[x] = y - 3
          break
        }
      } else {
        run = 0
      }
    }
  }

  // Smooth rawHairY across full head width so left/right waves never get a vertical rectangular notch
  var smoothHairY = rawHairY
  for x in 275...655 {
    var vals: [Int] = []
    for nx in max(265, x - 6)...min(665, x + 6) {
      if let v = rawHairY[nx] { vals.append(v) }
    }
    if vals.count >= 3 {
      vals.sort()
      smoothHairY[x] = vals[vals.count / 2]
    }
  }

  // Erase ONLY pixels strictly above smoothHairY[x]; outside detected chestnut hair, erase only non-hair beret pixels
  for x in 265...665 {
    if let hy = smoothHairY[x] {
      for y in 0..<hy {
        c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
      }
      let p0 = c.rgba(x, hy)
      if p0.3 > 0.05 { c.setRGBA(x, hy, r: p0.0 * 0.72, g: p0.1 * 0.68, b: p0.2 * 0.66, a: p0.3 * 0.55) }
      let p1 = c.rgba(x, hy + 1)
      if p1.3 > 0.05 { c.setRGBA(x, hy + 1, r: p1.0 * 0.88, g: p1.1 * 0.86, b: p1.2 * 0.85, a: p1.3 * 0.88) }
    } else {
      let maxEraseY = x > 555 ? 250 : 210
      for y in 0..<maxEraseY {
        let (r, g, b, a) = c.rgba(x, y)
        if a < 0.02 { continue }
        if isWarmChestnutHair(r, g, b, a) { continue }
        c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
      }
    }
  }
  // Extra right-side beret rim sweep (x = 552...655, y = 80..<248): erase any cream/grey beret pixel!
  for y in 80..<248 {
    for x in 552...655 {
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.02 { continue }
      if x > 578 && y < 228 && !isWarmChestnutHair(r, g, b, a) {
        c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
        continue
      }
      if !isWarmChestnutHair(r, g, b, a) {
        let np = c.rgba(x - 1, y)
        if !isWarmChestnutHair(np.0, np.1, np.2, np.3) {
          c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
        }
      }
    }
  }

  // Subtle natural chestnut crown sheen & top contour strictly inside existing hair alpha
  c.compositeCG(expandAlpha: false) { ctx in
    ctx.setStrokeColor(nsColor(0.24, 0.13, 0.10, 0.88))
    ctx.setLineWidth(2.6); ctx.setLineCap(.round)
    let p = CGMutablePath()
    var started = false
    for x in stride(from: 332, through: 566, by: 4) {
      if let hy = smoothHairY[x] {
        let pt = CGPoint(x: CGFloat(x), y: CGFloat(hy + 1))
        if !started { p.move(to: pt); started = true } else { p.addLine(to: pt) }
      }
    }
    if started { ctx.addPath(p); ctx.strokePath() }

    ctx.setStrokeColor(nsColor(0.68, 0.48, 0.38, 0.38))
    ctx.setLineWidth(4.5)
    let hi = CGMutablePath()
    hi.move(to: CGPoint(x: 372, y: 146))
    hi.addQuadCurve(to: CGPoint(x: 432, y: 138), control: CGPoint(x: 402, y: 134))
    hi.move(to: CGPoint(x: 466, y: 142))
    hi.addQuadCurve(to: CGPoint(x: 526, y: 168), control: CGPoint(x: 498, y: 148))
    ctx.addPath(hi); ctx.strokePath()
  }
}

// FIX 3: Above y=442 erase twin-tails + twin-tail ribbons completely; y=442..<532 erase ONLY dark hair above pink frills!
func trimHarinTwinTails(_ c: inout PixelCanvas, trimLeft: Bool, trimRight: Bool, spec: FaceSpec) {
  // Pass A (y = 115..<426): cleanly remove twin-tails & ribbons smoothly hugging Harin's head contour
  for y in 115..<426 {
    let fy = Double(y)
    let lCut: Double = fy < 195 ? 290.0 : 290.0 + (fy - 195.0) * 0.085
    let rCut: Double = fy < 195 ? 602.0 : 602.0 - (fy - 195.0) * 0.052
    for x in 150..<750 {
      let cur = c.rgba(x, y)
      if cur.3 < 0.02 { continue }
      var fadeOut = 1.0
      if trimLeft && Double(x) < lCut {
        fadeOut = min(fadeOut, max(0.0, (Double(x) - (lCut - 5.0)) / 5.0))
      }
      if trimRight && Double(x) > rCut {
        fadeOut = min(fadeOut, max(0.0, ((rCut + 5.0) - Double(x)) / 5.0))
      }
      if fadeOut < 1.0 {
        c.setRGBA(x, y, r: cur.0, g: cur.1, b: cur.2, a: cur.3 * (fadeOut > 0.06 ? fadeOut : 0))
      }
    }
  }
  // Pass B (y = 426..<508): remove remaining twin-tail hair strictly above the pink shoulder frill
  for x in 170..<730 {
    let inLeft = trimLeft && x < 310
    let inRight = trimRight && x > 590
    if !inLeft && !inRight { continue }
    for y in 426..<508 {
      let (r, g, _, a) = c.rgba(x, y)
      if a < 0.02 { continue }
      if r > 0.40 && (r - g) > 0.042 { break }
      c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
    }
  }
  // Pass C: remove any isolated 1-2px vertical hair-outline slivers above the shoulder frill
  for y in 426..<500 {
    for x in 175..<725 {
      if !((trimLeft && x < 310) || (trimRight && x > 590)) { continue }
      if c.rgba(x, y).3 > 0.02 && c.rgba(x - 2, y).3 < 0.05 && c.rgba(x + 2, y).3 < 0.05 {
        c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
      }
    }
  }
}

// FIX 4: 2D Dilated Hair + Hair-Outline Mask & Clean 2D Pastel Tweed Synthesis (Zero Brown Streaks on Nayeon!)
func trimNayeonBobClean(_ c: inout PixelCanvas, spec: FaceSpec) {
  let w = c.w, h = c.h
  let minY = 380, maxY = 815
  var seedHair = [Bool](repeating: false, count: w * h)

  for y in minY..<maxY {
    for x in 120..<780 {
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.08 { continue }
      if isAnySkinPixel(r, g, b, ref: spec.skinRGB) { continue }
      let lum = 0.299 * r + 0.587 * g + 0.114 * b
      // Blonde/caramel hair body (warm yellow-gold: g > b + 0.045, whereas pink tweed has b >= g!)
      if r > g && (g - b) > 0.042 && lum > 0.30 {
        seedHair[y * w + x] = true
      }
    }
  }

  // Dilate by 7px so dark-brown hair outlines (lum 0.14..0.38) around every blonde lock are 100% captured!
  var fullHairMask = seedHair
  for y in (minY + 7)..<(maxY - 7) {
    for x in 128..<772 {
      if !seedHair[y * w + x] { continue }
      for dy in -7...7 {
        for dx in -7...7 {
          if dx * dx + dy * dy > 49 { continue }
          let nx = x + dx, ny = y + dy
          let (r, g, b, a) = c.rgba(nx, ny)
          if a < 0.02 { continue }
          if isAnySkinPixel(r, g, b, ref: spec.skinRGB) { continue }
          // Do not dilate into pure white blouse collar / pearl buttons
          let lum = 0.299 * r + 0.587 * g + 0.114 * b
          let maxC = max(r, max(g, b)), minC = min(r, min(g, b))
          let sat = maxC > 0.001 ? (maxC - minC) / maxC : 0
          if lum > 0.91 && sat < 0.065 { continue }
          fullHairMask[ny * w + nx] = true
        }
      }
    }
  }

  // Collect verified clean pastel pink tweed samples (where b >= g - 0.02 and r > g + 0.04 and lum > 0.56)
  var cleanTweedByRow: [[(Int, Double, Double, Double)]] = Array(repeating: [], count: h)
  var globalTweed: [(Int, Int, Double, Double, Double)] = []
  for y in 420..<maxY {
    for x in 180..<740 {
      if fullHairMask[y * w + x] { continue }
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.85 { continue }
      if isAnySkinPixel(r, g, b, ref: spec.skinRGB) { continue }
      let lum = 0.299 * r + 0.587 * g + 0.114 * b
      // Authentic pastel pink tweed: rosy, bright, NEVER dark brown!
      if r > 0.72 && g > 0.52 && b > 0.55 && (r - g) > 0.05 && (b - g) > -0.02 && lum > 0.60 {
        cleanTweedByRow[y].append((x, r, g, b))
        if (x + y) % 5 == 0 {
          globalTweed.append((x, y, r, g, b))
        }
      }
    }
  }

  for y in 405..<maxY {
    // Determine garment outer bounds on row y from non-hair opaque pixels
    var nonHairXs: [Int] = []
    for x in 150..<760 {
      if fullHairMask[y * w + x] { continue }
      let (_, _, _, a) = c.rgba(x, y)
      if a > 0.65 { nonHairXs.append(x) }
    }
    let minGX = nonHairXs.min() ?? 275
    let maxGX = nonHairXs.max() ?? 650

    // Taper bob cut smoothly between y=405..438
    let bobFade = min(1.0, max(0.0, Double(y - 405) / 30.0))

    for x in 120..<780 {
      if !fullHairMask[y * w + x] { continue }
      let cur = c.rgba(x, y)
      if cur.3 < 0.02 { continue }

      if x < minGX - 1 || x > maxGX + 1 {
        // Outside jacket silhouette -> smooth bob cut to transparent!
        let newA = cur.3 * (1.0 - bobFade)
        c.setRGBA(x, y, r: cur.0, g: cur.1, b: cur.2, a: newA > 0.05 ? newA : 0)
      } else if y > 422 {
        // Inside jacket silhouette -> smooth 2D clean pastel tweed synthesis + subtle cross-weave!
        var wSum = 0.0, rSum = 0.0, gSum = 0.0, bSum = 0.0
        let rowSamples = cleanTweedByRow[y]
        for s in rowSamples {
          let d2 = Double((s.0 - x) * (s.0 - x)) + 64.0
          let wgt = 1.0 / d2
          wSum += wgt; rSum += wgt * s.1; gSum += wgt * s.2; bSum += wgt * s.3
        }
        if wSum < 0.001 {
          for s in globalTweed {
            let d2 = Double((s.0 - x) * (s.0 - x) + (s.1 - y) * (s.1 - y)) + 120.0
            let wgt = 1.0 / d2
            wSum += wgt; rSum += wgt * s.2; gSum += wgt * s.3; bSum += wgt * s.4
          }
        }
        if wSum > 0.0001 {
          // Subtle 2px tweed fabric weave micro-modulation so filled area has authentic textile grain
          let weave = ((x / 2 + y / 2) % 2 == 0) ? 1.012 : 0.988
          let tr = min(1.0, (rSum / wSum) * weave)
          let tg = min(1.0, (gSum / wSum) * weave)
          let tb = min(1.0, (bSum / wSum) * weave)
          let fillBlend = min(1.0, Double(y - 422) / 24.0)
          c.setRGBA(x, y,
                    r: cur.0 * (1 - fillBlend) + tr * fillBlend,
                    g: cur.1 * (1 - fillBlend) + tg * fillBlend,
                    b: cur.2 * (1 - fillBlend) + tb * fillBlend,
                    a: cur.3)
        }
      }
    }
  }
}

func isCharacterHairPixel(_ r: Double, _ g: Double, _ b: Double, id: String, y: Int, x: Int, spec: FaceSpec) -> Bool {
  let maxC = max(r, max(g, b)), minC = min(r, min(g, b))
  let lum = 0.299 * r + 0.587 * g + 0.114 * b
  let sat = maxC > 0.001 ? (maxC - minC) / maxC : 0
  if isAnySkinPixel(r, g, b, ref: spec.skinRGB) { return false }
  switch id {
  case "seoyoon":
    if lum > 0.72 && sat < 0.24 { return false }
    return r > g * 1.12 && r > b * 1.25 && lum < 0.62 && y < 685
  case "harin":
    return lum < 0.34 && sat < 0.24 && (y < 435 || (x < 245 || x > 650))
  case "sea":
    return lum > 0.42 && lum < 0.93 && sat < 0.16 && y < 530
  case "chaewon":
    if y > 375 && (x > 330 && x < 580) { return false }
    return (lum < 0.30 || (r > g * 1.28 && lum < 0.55)) && y < 385
  case "nayeon":
    return r > g && (g - b) > 0.05 && lum > 0.36 && y < 800
  default:
    return false
  }
}

func applyHairDye(_ c: inout PixelCanvas, spec: FaceSpec, targetRGB: (Double, Double, Double), strength: Double, ombreTipsOnly: Bool = false) {
  for y in 0..<min(820, c.h) {
    for x in 0..<c.w {
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.1 { continue }
      if x > Int(spec.leftEye.x) - 36 && x < Int(spec.rightEye.x) + 36 &&
         y > Int(spec.leftEye.y) - 24 && y < Int(spec.mouth.y) + 26 { continue }
      if !isCharacterHairPixel(r, g, b, id: spec.id, y: y, x: x, spec: spec) { continue }

      var wgt = strength
      if ombreTipsOnly {
        let startY = Double(spec.crownTopY + 130)
        let ramp = max(0.0, min(1.0, (Double(y) - startY) / 160.0))
        wgt *= ramp
        if wgt < 0.01 { continue }
      }

      let lum = 0.299 * r + 0.587 * g + 0.114 * b
      let scale = max(0.28, min(1.52, lum / 0.48))
      let nr = min(1.0, targetRGB.0 * scale)
      let ng = min(1.0, targetRGB.1 * scale)
      let nb = min(1.0, targetRGB.2 * scale)
      c.setRGBA(x, y,
                r: r * (1 - wgt) + nr * wgt,
                g: g * (1 - wgt) + ng * wgt,
                b: b * (1 - wgt) + nb * wgt,
                a: a)
    }
  }
}

// FIX 5A: Behind-Crown Organic High Bun (composited UNDER existing crown alpha -> zero paste seam!)
func drawBehindCrownBun(_ c: inout PixelCanvas, spec: FaceSpec, hairRGB: (Double, Double, Double), ribbonRGB: (Double, Double, Double)) {
  let bc = CGPoint(x: spec.crownCenter.x + 4, y: spec.crownTopY + 4)
  let baseC = nsColor(CGFloat(hairRGB.0), CGFloat(hairRGB.1), CGFloat(hairRGB.2))
  let darkC = nsColor(CGFloat(hairRGB.0 * 0.42), CGFloat(hairRGB.1 * 0.40), CGFloat(hairRGB.2 * 0.42))
  let hiC   = nsColor(CGFloat(min(1, hairRGB.0 * 1.35 + 0.06)), CGFloat(min(1, hairRGB.1 * 1.35 + 0.06)), CGFloat(min(1, hairRGB.2 * 1.35 + 0.06)))

  c.compositeCG(behindExisting: true) { ctx in
    let bunRect = CGRect(x: bc.x - 48, y: bc.y - 42, width: 96, height: 80)
    ctx.saveGState()
    ctx.addEllipse(in: bunRect)
    ctx.clip()
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hiC, baseC, darkC] as CFArray, locations: [0.0, 0.55, 1.0])!
    ctx.drawLinearGradient(grad, start: CGPoint(x: bc.x - 16, y: bc.y - 42), end: CGPoint(x: bc.x + 18, y: bc.y + 38), options: [])
    ctx.restoreGState()

    ctx.setStrokeColor(darkC); ctx.setLineWidth(2.4)
    ctx.strokeEllipse(in: bunRect)

    // Organic hair-strand curves across the chignon bun
    ctx.setLineWidth(1.5); ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: bc.x - 32, y: bc.y - 6))
    ctx.addQuadCurve(to: CGPoint(x: bc.x + 30, y: bc.y - 14), control: CGPoint(x: bc.x, y: bc.y - 30))
    ctx.strokePath()
    ctx.move(to: CGPoint(x: bc.x - 24, y: bc.y + 8))
    ctx.addQuadCurve(to: CGPoint(x: bc.x + 34, y: bc.y - 2), control: CGPoint(x: bc.x + 6, y: bc.y - 16))
    ctx.strokePath()
  }

  // Delicate small satin ribbon tie right along the crown-bun junction
  c.compositeCG(expandAlpha: true) { ctx in
    let rBase = nsColor(CGFloat(ribbonRGB.0), CGFloat(ribbonRGB.1), CGFloat(ribbonRGB.2), 0.96)
    let rDark = nsColor(CGFloat(ribbonRGB.0 * 0.55), CGFloat(ribbonRGB.1 * 0.48), CGFloat(ribbonRGB.2 * 0.52), 0.96)
    for side in [-1.0, 1.0] {
      let bow = CGMutablePath()
      bow.move(to: CGPoint(x: bc.x, y: bc.y - 2))
      bow.addQuadCurve(to: CGPoint(x: bc.x + CGFloat(side) * 34, y: bc.y - 14), control: CGPoint(x: bc.x + CGFloat(side) * 18, y: bc.y - 18))
      bow.addQuadCurve(to: CGPoint(x: bc.x + CGFloat(side) * 28, y: bc.y + 4), control: CGPoint(x: bc.x + CGFloat(side) * 40, y: bc.y - 4))
      bow.closeSubpath()
      ctx.addPath(bow); ctx.setFillColor(rBase); ctx.fillPath()
      ctx.addPath(bow); ctx.setStrokeColor(rDark); ctx.setLineWidth(1.8); ctx.strokePath()
    }
  }
}

// FIX 5B: Delicate Temple Hairpins / Small Satin Ribbon (replaces giant plastic headbands!)
func drawHairAccessory(_ c: inout PixelCanvas, spec: FaceSpec, style: String, accentRGB: (Double, Double, Double)) {
  c.compositeCG(expandAlpha: false) { ctx in
    let baseC = nsColor(CGFloat(accentRGB.0), CGFloat(accentRGB.1), CGFloat(accentRGB.2), 0.96)
    let darkC = nsColor(CGFloat(accentRGB.0 * 0.45), CGFloat(accentRGB.1 * 0.38), CGFloat(accentRGB.2 * 0.42), 0.96)
    let hiC   = nsColor(CGFloat(min(1, accentRGB.0 * 1.25)), CGFloat(min(1, accentRGB.1 * 1.25)), CGFloat(min(1, accentRGB.2 * 1.25)), 0.95)

    if style == "ribbon" {
      let rp = CGPoint(x: spec.rightBrow.x + 28, y: spec.crownTopY + 66)
      ctx.saveGState()
      ctx.translateBy(x: rp.x, y: rp.y)
      ctx.rotate(by: 0.32)
      for dir in [-1.0, 1.0] {
        let w = CGMutablePath()
        w.move(to: .zero)
        w.addQuadCurve(to: CGPoint(x: CGFloat(dir) * 26, y: -12), control: CGPoint(x: CGFloat(dir) * 14, y: -15))
        w.addQuadCurve(to: CGPoint(x: CGFloat(dir) * 24, y: 12), control: CGPoint(x: CGFloat(dir) * 32, y: 0))
        w.closeSubpath()
        ctx.addPath(w); ctx.setFillColor(baseC); ctx.fillPath()
        ctx.addPath(w); ctx.setStrokeColor(darkC); ctx.setLineWidth(1.8); ctx.strokePath()
      }
      // Hanging ribbon tails
      for dir in [-1.0, 1.0] {
        ctx.setStrokeColor(baseC); ctx.setLineWidth(5.5); ctx.setLineCap(.round)
        ctx.move(to: CGPoint(x: CGFloat(dir) * 3, y: 4))
        ctx.addQuadCurve(to: CGPoint(x: CGFloat(dir) * 14, y: 28), control: CGPoint(x: CGFloat(dir) * 10, y: 16))
        ctx.strokePath()
      }
      ctx.setFillColor(hiC); ctx.fillEllipse(in: CGRect(x: -6, y: -6, width: 12, height: 12))
      ctx.setStrokeColor(darkC); ctx.setLineWidth(1.6); ctx.strokeEllipse(in: CGRect(x: -6, y: -6, width: 12, height: 12))
      ctx.restoreGState()
    } else if style == "pins" {
      let pp = CGPoint(x: spec.leftBrow.x - 26, y: spec.leftBrow.y - 22)
      ctx.saveGState()
      ctx.translateBy(x: pp.x, y: pp.y)
      ctx.rotate(by: -0.26)
      ctx.setLineCap(.round)
      // Criss-cross anime hairpins
      ctx.setStrokeColor(darkC); ctx.setLineWidth(5.2)
      ctx.move(to: CGPoint(x: -14, y: -5)); ctx.addLine(to: CGPoint(x: 14, y: 6)); ctx.strokePath()
      ctx.move(to: CGPoint(x: -14, y: 6)); ctx.addLine(to: CGPoint(x: 14, y: -5)); ctx.strokePath()
      ctx.setStrokeColor(baseC); ctx.setLineWidth(3.2)
      ctx.move(to: CGPoint(x: -14, y: -5)); ctx.addLine(to: CGPoint(x: 14, y: 6)); ctx.strokePath()
      ctx.move(to: CGPoint(x: -14, y: 6)); ctx.addLine(to: CGPoint(x: 14, y: -5)); ctx.strokePath()
      ctx.setFillColor(hiC); ctx.fillEllipse(in: CGRect(x: -3.5, y: -3, width: 7, height: 7))
      ctx.restoreGState()
    }
  }
}

// FIX 5C: Skin-Masked Velvet Choker (only renders onto actual exposed neck skin -> hair locks stay naturally in front!)
func drawNeckChokerOnSkin(_ c: inout PixelCanvas, spec: FaceSpec, colorRGB: (Double, Double, Double), pearlCenter: Bool = true) {
  let cy = Int(spec.neckPivot.y + 18)
  let minX = max(0, Int(spec.neckPivot.x) - 52)
  let maxX = min(c.w - 1, Int(spec.neckPivot.x) + 52)
  var skinXs: [Int] = []

  for y in (cy - 5)...(cy + 5) {
    for x in minX...maxX {
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.85 { continue }
      if isCharacterHairPixel(r, g, b, id: spec.id, y: y, x: x, spec: spec) { continue }
      if isAnySkinPixel(r, g, b, ref: spec.skinRGB) {
        let curveY = Double(cy) + 0.0035 * pow(Double(x) - Double(spec.neckPivot.x), 2)
        let dist = abs(Double(y) - curveY)
        if dist < 4.2 {
          skinXs.append(x)
          let edgeFade = dist < 2.8 ? 0.92 : max(0.0, (4.2 - dist) / 1.4) * 0.92
          let shade = dist > 2.2 ? 0.55 : 1.0
          let cr = colorRGB.0 * shade, cg = colorRGB.1 * shade, cb = colorRGB.2 * shade
          c.setRGBA(x, y,
                    r: r * (1 - edgeFade) + cr * edgeFade,
                    g: g * (1 - edgeFade) + cg * edgeFade,
                    b: b * (1 - edgeFade) + cb * edgeFade,
                    a: a)
        }
      }
    }
  }

  if pearlCenter && skinXs.count > 12 {
    let midX = CGFloat(spec.neckPivot.x)
    let midY = CGFloat(cy + 5)
    let centerP = c.rgba(Int(midX), Int(midY))
    if isAnySkinPixel(centerP.0, centerP.1, centerP.2, ref: spec.skinRGB) {
      c.compositeCG(expandAlpha: false) { ctx in
        ctx.setFillColor(nsColor(0.98, 0.95, 0.92, 0.96))
        ctx.fillEllipse(in: CGRect(x: midX - 4.5, y: midY - 2, width: 9, height: 9))
        ctx.setStrokeColor(nsColor(0.45, 0.34, 0.30, 0.90)); ctx.setLineWidth(1.4)
        ctx.strokeEllipse(in: CGRect(x: midX - 4.5, y: midY - 2, width: 9, height: 9))
      }
    }
  }
}

func applyHairstyleVariant(_ c: inout PixelCanvas, spec: FaceSpec, variant: String) -> (Double, Double, Double) {
  var hairRGB = spec.hairBaseRGB

  switch (spec.id, variant) {
  case ("seoyoon", "happy"):
    hairRGB = (0.58, 0.37, 0.26)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.48)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.96, 0.72, 0.32))
  case ("seoyoon", "pout"):
    // Keep signature white beret + cute cross hairpins on left bangs
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.95, 0.50, 0.62))
  case ("seoyoon", "yandere"):
    removeSeoyoonBeret(&c, spec: spec)
    hairRGB = (0.20, 0.13, 0.14)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.64)
  case ("seoyoon", "shy"):
    removeSeoyoonBeret(&c, spec: spec)
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.98, 0.68, 0.76))
  case ("seoyoon", "casual"):
    removeSeoyoonBeret(&c, spec: spec)
    hairRGB = (0.52, 0.36, 0.28)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.38)
    drawBehindCrownBun(&c, spec: spec, hairRGB: hairRGB, ribbonRGB: (0.78, 0.70, 0.92))
  case ("seoyoon", "lounge"):
    removeSeoyoonBeret(&c, spec: spec)
    drawBehindCrownBun(&c, spec: spec, hairRGB: spec.hairBaseRGB, ribbonRGB: (0.96, 0.68, 0.76))
  case ("seoyoon", "date"):
    removeSeoyoonBeret(&c, spec: spec)
    hairRGB = (0.52, 0.22, 0.26)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.54)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.76, 0.18, 0.28))
  case ("seoyoon", "night"):
    removeSeoyoonBeret(&c, spec: spec)
    hairRGB = (0.26, 0.18, 0.32)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.56, ombreTipsOnly: true)

  case ("harin", "yandere"):
    // Asymmetric one-side twin-tail cut (puff sleeves 100% protected!)
    trimHarinTwinTails(&c, trimLeft: false, trimRight: true, spec: spec)
  case ("harin", "shy"):
    // Clean chic short bob cut (both twin-tails removed above shoulders, puff sleeves 100% protected!)
    trimHarinTwinTails(&c, trimLeft: true, trimRight: true, spec: spec)
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (1.0, 0.48, 0.72))
  case ("harin", "lounge"):
    let loungeSpec = FaceSpec(
      id: "harin", rawFile: harinCasual,
      leftEye: CGPoint(x: 458, y: 343), rightEye: CGPoint(x: 557, y: 364),
      eyeRx: 28, eyeRy: 18,
      leftBrow: CGPoint(x: 457, y: 320), rightBrow: CGPoint(x: 572, y: 340),
      leftCheek: CGPoint(x: 445, y: 390), rightCheek: CGPoint(x: 558, y: 406),
      nose: CGPoint(x: 507, y: 411), mouth: CGPoint(x: 495, y: 456), mouthRx: 26, mouthRy: 12,
      neckPivot: CGPoint(x: 496, y: 492), crownCenter: CGPoint(x: 465, y: 170), crownTopY: 96, torsoTopY: 480,
      hasBangsOverBrows: true, skinRGB: spec.skinRGB, hairBaseRGB: spec.hairBaseRGB, hairShadowRGB: spec.hairShadowRGB, hairHiRGB: spec.hairHiRGB, lipRGB: spec.lipRGB
    )
    // Keep Harin's native side-low bun clean + add pastel lavender hairpins!
    drawHairAccessory(&c, spec: loungeSpec, style: "pins", accentRGB: (0.86, 0.64, 0.96))
  case ("harin", "night"):
    let dateSpec = FaceSpec(
      id: "harin", rawFile: harinDate,
      leftEye: CGPoint(x: 456, y: 276), rightEye: CGPoint(x: 550, y: 268),
      eyeRx: 28, eyeRy: 18,
      leftBrow: CGPoint(x: 450, y: 246), rightBrow: CGPoint(x: 559, y: 238),
      leftCheek: CGPoint(x: 438, y: 318), rightCheek: CGPoint(x: 552, y: 312),
      nose: CGPoint(x: 522, y: 325), mouth: CGPoint(x: 517, y: 363), mouthRx: 26, mouthRy: 12,
      neckPivot: CGPoint(x: 495, y: 415), crownCenter: CGPoint(x: 492, y: 135), crownTopY: 62, torsoTopY: 445,
      hasBangsOverBrows: true, skinRGB: spec.skinRGB, hairBaseRGB: spec.hairBaseRGB, hairShadowRGB: spec.hairShadowRGB, hairHiRGB: spec.hairHiRGB, lipRGB: spec.lipRGB
    )
    hairRGB = (0.36, 0.18, 0.48)
    applyHairDye(&c, spec: dateSpec, targetRGB: hairRGB, strength: 0.48, ombreTipsOnly: true)
    drawHairAccessory(&c, spec: dateSpec, style: "ribbon", accentRGB: (0.95, 0.24, 0.62))

  case ("sea", "happy"):
    hairRGB = (0.80, 0.74, 0.92)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.45)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.74, 0.66, 0.94))
  case ("sea", "pout"):
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.68, 0.78, 0.92))
  case ("sea", "anxious"):
    hairRGB = (0.58, 0.72, 0.88)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.44)
  case ("sea", "shy"):
    hairRGB = (0.88, 0.72, 0.78)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.46)
    // Trim lower side locks outside collar cleanly for neat chin-bob
    for y in 420...486 {
      let fade = min(1.0, Double(y - 420) / 22.0)
      for x in 230..<670 {
        if x < 346 || x > 556 {
          let (r, g, b, a) = c.rgba(x, y)
          if a > 0.02 && !isAnySkinPixel(r, g, b, ref: spec.skinRGB) && r > 0.35 {
            c.setRGBA(x, y, r: r, g: g, b: b, a: a * (1.0 - fade))
          }
        }
      }
    }
  case ("sea", "casual"):
    hairRGB = (0.44, 0.48, 0.56)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.50)
    drawBehindCrownBun(&c, spec: spec, hairRGB: hairRGB, ribbonRGB: (0.56, 0.70, 0.86))
  case ("sea", "lounge"):
    drawBehindCrownBun(&c, spec: spec, hairRGB: hairRGB, ribbonRGB: (0.72, 0.86, 0.84))
  case ("sea", "date"):
    hairRGB = (0.86, 0.82, 0.92)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.34)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.58, 0.22, 0.38))
  case ("sea", "night"):
    hairRGB = (0.38, 0.72, 0.92)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.52, ombreTipsOnly: true)

  case ("chaewon", "happy"):
    hairRGB = (0.52, 0.16, 0.22)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.52)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.82, 0.18, 0.26))
  case ("chaewon", "shy"):
    // keep original hair (the old side-trim left hard-edged holes next to the neck)
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.92, 0.76, 0.56))
  case ("chaewon", "casual"):
    for y in 275...368 {
      for x in 285..<615 {
        if x < 375 || x > 522 {
          let (r, g, b, a) = c.rgba(x, y)
          if a > 0.04 && isCharacterHairPixel(r, g, b, id: "chaewon", y: y, x: x, spec: spec) {
            c.setRGBA(x, y, r: 0, g: 0, b: 0, a: 0)
          }
        }
      }
    }
    if variant == "casual" {
      hairRGB = (0.38, 0.34, 0.38)
      applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.42)
      drawBehindCrownBun(&c, spec: spec, hairRGB: hairRGB, ribbonRGB: (0.68, 0.20, 0.28))
    } else {
      drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.92, 0.76, 0.56))
    }
  case ("chaewon", "lounge"):
    drawBehindCrownBun(&c, spec: spec, hairRGB: spec.hairBaseRGB, ribbonRGB: (0.86, 0.78, 0.68))
  case ("chaewon", "date"):
    hairRGB = (0.44, 0.16, 0.44)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.50)
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.94, 0.80, 0.52))
  case ("chaewon", "yandere"):
    hairRGB = (0.12, 0.10, 0.18)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.55)
  case ("chaewon", "night"):
    hairRGB = (0.56, 0.14, 0.34)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.52, ombreTipsOnly: true)

  case ("nayeon", "pout"):
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (0.98, 0.48, 0.66))
  case ("nayeon", "anxious"):
    // Cool muted ash-champagne waves for anxious mood (nayeon-casual showcases her genuine studio bob haircut!)
    hairRGB = (0.72, 0.64, 0.58)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.42)
  case ("nayeon", "casual"):
    trimNayeonBobClean(&c, spec: spec)
    hairRGB = (0.58, 0.48, 0.44)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.44)
  case ("nayeon", "shy"):
    hairRGB = (0.94, 0.66, 0.72)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.48)
    drawHairAccessory(&c, spec: spec, style: "pins", accentRGB: (1.0, 0.86, 0.90))
  case ("nayeon", "lounge"):
    drawBehindCrownBun(&c, spec: spec, hairRGB: spec.hairBaseRGB, ribbonRGB: (0.98, 0.72, 0.80))
  case ("nayeon", "date"):
    hairRGB = (0.92, 0.64, 0.68)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.42)
    drawHairAccessory(&c, spec: spec, style: "ribbon", accentRGB: (0.72, 0.16, 0.28))
  case ("nayeon", "night"):
    hairRGB = (0.92, 0.90, 0.88)
    applyHairDye(&c, spec: spec, targetRGB: hairRGB, strength: 0.48)

  default:
    break
  }
  return hairRGB
}

// MARK: - Skin-Safe Outfit Recolor + Color Grading + Neon Rim + Clean Smartphone Prop
func recolorOutfit(_ c: inout PixelCanvas, spec: FaceSpec, target: (Double, Double, Double), darkClothOnly: Bool, strength: Double = 0.74) {
  let torsoStart = Int(spec.torsoTopY)
  for y in torsoStart..<c.h {
    let blendY = min(1.0, Double(y - torsoStart) / 42.0)
    for x in 0..<c.w {
      let (r, g, b, a) = c.rgba(x, y)
      if a < 0.08 { continue }
      let maxC = max(r, max(g, b)), minC = min(r, min(g, b))
      let lum = 0.299 * r + 0.587 * g + 0.114 * b
      let sat = maxC > 0.001 ? (maxC - minC) / maxC : 0
      if lum < 0.10 || lum > 0.95 { continue }

      // Strictly protect ALL skin tones including shadowed neck, collarbones, hands & fingers!
      if isAnySkinPixel(r, g, b, ref: spec.skinRGB) { continue }

      // Protect character hair locks draping onto torso
      if spec.id == "seoyoon" && y < 690 && (lum < 0.58 || (r > g * 1.14 && r > b * 1.30)) { continue }
      if spec.id == "nayeon" && y < 805 && r > g && (g - b) > 0.045 && lum > 0.32 { continue }
      if spec.id == "sea" && y < 540 && lum > 0.44 && sat < 0.14 { continue }
      if spec.id == "chaewon" && y < 535 && (lum < 0.30 && r > g * 1.25) { continue }

      if darkClothOnly {
        // Only target dark neutral/charcoal knitwear or blazers — never warm skin shadows or ceramic mugs!
        if lum > 0.46 || sat > 0.18 { continue }
      } else {
        if lum < 0.30 { continue }
      }

      let wStrength = strength * blendY
      let lift = darkClothOnly ? max(0.30, min(1.30, lum * 2.05)) : max(0.30, min(1.08, lum * 1.03))
      let nr = min(1.0, target.0 * lift), ng = min(1.0, target.1 * lift), nb = min(1.0, target.2 * lift)
      c.setRGBA(x, y,
                r: r * (1 - wStrength) + nr * wStrength,
                g: g * (1 - wStrength) + ng * wStrength,
                b: b * (1 - wStrength) + nb * wStrength,
                a: a)
    }
  }
}

func gradeCanvas(_ c: inout PixelCanvas, sat: Double = 1.0, bri: Double = 0.0, con: Double = 1.0, warmth: Double = 0.0) {
  for y in 0..<c.h {
    for x in 0..<c.w {
      let (r0, g0, b0, a) = c.rgba(x, y)
      if a < 0.02 { continue }
      let lum = 0.299 * r0 + 0.587 * g0 + 0.114 * b0
      var r = lum + (r0 - lum) * sat
      var g = lum + (g0 - lum) * sat
      var b = lum + (b0 - lum) * sat
      r = (r - 0.5) * con + 0.5 + bri + warmth * 0.055
      g = (g - 0.5) * con + 0.5 + bri
      b = (b - 0.5) * con + 0.5 + bri - warmth * 0.065
      c.setRGBA(x, y, r: max(0, min(1, r)), g: max(0, min(1, g)), b: max(0, min(1, b)), a: a)
    }
  }
}

func applySilhouetteNeonRim(_ c: inout PixelCanvas) {
  let srcPx = c.px
  let w = c.w, h = c.h
  func alphaAt(_ x: Int, _ y: Int) -> Double {
    if x < 0 || x >= w || y < 0 || y >= h { return 0 }
    return Double(srcPx[(y * w + x) * 4 + 3]) / 255.0
  }
  for y in 6..<(h - 6) {
    for x in 8..<(w - 8) {
      let a = alphaAt(x, y)
      if a < 0.45 { continue }
      let gx = alphaAt(x + 6, y) - alphaAt(x - 6, y)
      let gy = alphaAt(x, y + 6) - alphaAt(x, y - 6)
      if gx > 0.28 || gy > 0.36 {
        let rim = min(0.65, max(gx, gy * 0.7))
        let i = (y * w + x) * 4
        let r = Double(srcPx[i]) / 255.0, g = Double(srcPx[i + 1]) / 255.0, b = Double(srcPx[i + 2]) / 255.0
        c.setRGBA(x, y, r: r * (1 - rim * 0.40), g: min(0.88, g + rim * 0.55), b: min(0.92, b + rim * 0.75), a: a)
      } else if gx < -0.28 {
        let rim = min(0.65, -gx)
        let i = (y * w + x) * 4
        let r = Double(srcPx[i]) / 255.0, g = Double(srcPx[i + 1]) / 255.0, b = Double(srcPx[i + 2]) / 255.0
        c.setRGBA(x, y, r: min(0.92, r + rim * 0.78), g: g * (1 - rim * 0.35), b: min(0.88, b + rim * 0.52), a: a)
      }
    }
  }
}

// Clean anime accessories ONLY — zero stiff roundedRect scarves, banana collars, or oval headphones!
func drawPropOverlay(_ c: inout PixelCanvas, spec: FaceSpec, variant: String) {
  if variant == "yandere" {
    c.compositeCG(expandAlpha: true) { ctx in
      let center = CGPoint(x: spec.neckPivot.x + 122, y: spec.torsoTopY + 358)
      ctx.saveGState()
      ctx.translateBy(x: center.x, y: center.y)
      ctx.rotate(by: -0.14)
      let c0 = nsColor(1.0, 0.24, 0.58, 0.42), c1 = nsColor(1.0, 0.24, 0.58, 0)
      let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [c0, c1] as CFArray, locations: [0, 1])!
      ctx.drawRadialGradient(g, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: 128, options: [])

      ctx.setFillColor(nsColor(0.02, 0.01, 0.05, 0.32))
      ctx.addPath(CGPath(roundedRect: CGRect(x: -50, y: -88, width: 108, height: 184), cornerWidth: 16, cornerHeight: 16, transform: nil))
      ctx.fillPath()

      let body = CGPath(roundedRect: CGRect(x: -55, y: -95, width: 110, height: 190), cornerWidth: 16, cornerHeight: 16, transform: nil)
      ctx.addPath(body); ctx.setFillColor(nsColor(0.08, 0.08, 0.11, 1)); ctx.fillPath()
      ctx.addPath(body); ctx.setStrokeColor(nsColor(0.36, 0.34, 0.42, 1)); ctx.setLineWidth(2.8); ctx.strokePath()
      let screen = CGPath(roundedRect: CGRect(x: -47, y: -85, width: 94, height: 170), cornerWidth: 10, cornerHeight: 10, transform: nil)
      ctx.saveGState(); ctx.addPath(screen); ctx.clip()
      let scrG = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [nsColor(0.18, 0.10, 0.26), nsColor(0.08, 0.05, 0.14)] as CFArray, locations: [0, 1])!
      ctx.drawLinearGradient(scrG, start: CGPoint(x: 0, y: -85), end: CGPoint(x: 0, y: 85), options: [])
      for (by, bw, msg) in [(-54.0, 74.0, "왜 안 봐?"), (-20.0, 68.0, "지금 어디야?"), (14.0, 78.0, "나만 보라며"), (48.0, 60.0, "부재중 14통")] {
        let bp = CGPath(roundedRect: CGRect(x: -39, y: by, width: bw, height: 23), cornerWidth: 8, cornerHeight: 8, transform: nil)
        ctx.addPath(bp); ctx.setFillColor(nsColor(0.98, 0.30, 0.58, 0.94)); ctx.fillPath()
        let str = NSAttributedString(string: msg, attributes: [.font: NSFont.boldSystemFont(ofSize: 10.2), .foregroundColor: NSColor.white])
        str.draw(at: CGPoint(x: -32, y: by + 4.5))
      }
      ctx.setFillColor(nsColor(1, 1, 1, 0.08))
      let gl = CGMutablePath()
      gl.move(to: CGPoint(x: -48, y: -88)); gl.addLine(to: CGPoint(x: 14, y: -88)); gl.addLine(to: CGPoint(x: -48, y: 38)); gl.closeSubpath()
      ctx.addPath(gl); ctx.fillPath()
      ctx.restoreGState()
      ctx.restoreGState()
    }
  } else if variant == "date" && (spec.id == "seoyoon" || spec.id == "nayeon") {
    drawNeckChokerOnSkin(&c, spec: spec, colorRGB: (0.28, 0.08, 0.14), pearlCenter: true)
  } else if variant == "night" && (spec.id == "seoyoon" || spec.id == "nayeon") {
    drawNeckChokerOnSkin(&c, spec: spec, colorRGB: (0.12, 0.10, 0.16), pearlCenter: false)
  }
}

// MARK: - Articulated Pose Warper (Distinct Per-Variant & Per-Character Framing + Lean + Tilt)
struct PoseConfig {
  let headTiltDeg: CGFloat
  let torsoTiltDeg: CGFloat
  let torsoShearX: CGFloat
  let scale: CGFloat
  let shiftX: CGFloat
  let shiftY: CGFloat
  let flipX: Bool
}

let poseTable: [String: PoseConfig] = [
  "normal":  PoseConfig(headTiltDeg:  0.0, torsoTiltDeg:  0.0, torsoShearX:  0.00, scale: 1.00, shiftX:   0, shiftY:   0, flipX: false),
  "happy":   PoseConfig(headTiltDeg:  2.6, torsoTiltDeg: -1.5, torsoShearX:  0.02, scale: 1.04, shiftX:  -6, shiftY:   4, flipX: false),
  "pout":    PoseConfig(headTiltDeg: -3.0, torsoTiltDeg:  2.0, torsoShearX: -0.03, scale: 1.03, shiftX: -10, shiftY:   4, flipX: false),
  "anxious": PoseConfig(headTiltDeg: -2.3, torsoTiltDeg:  1.5, torsoShearX:  0.02, scale: 0.94, shiftX:  10, shiftY:  26, flipX: false),
  "yandere": PoseConfig(headTiltDeg:  2.1, torsoTiltDeg: -1.0, torsoShearX:  0.00, scale: 1.15, shiftX:  -4, shiftY:  14, flipX: false),
  "shy":     PoseConfig(headTiltDeg:  3.3, torsoTiltDeg: -2.0, torsoShearX:  0.03, scale: 1.10, shiftX:   8, shiftY:  10, flipX: false),
  "casual":  PoseConfig(headTiltDeg: -1.9, torsoTiltDeg:  1.8, torsoShearX:  0.03, scale: 1.03, shiftX:   8, shiftY:   4, flipX: false),
  "lounge":  PoseConfig(headTiltDeg:  2.6, torsoTiltDeg: -2.0, torsoShearX: -0.03, scale: 1.06, shiftX: -10, shiftY:   8, flipX: false),
  "date":    PoseConfig(headTiltDeg: -2.3, torsoTiltDeg:  2.2, torsoShearX: -0.03, scale: 1.04, shiftX:  -8, shiftY:   4, flipX: false),
  "night":   PoseConfig(headTiltDeg: -1.8, torsoTiltDeg:  1.5, torsoShearX:  0.02, scale: 1.11, shiftX:   6, shiftY:  10, flipX: false),
]

func applyArticulatedPose(_ src: PixelCanvas, spec: FaceSpec, cfg: PoseConfig) -> PixelCanvas {
  var work = PixelCanvas(w: src.w, h: src.h)
  if cfg.flipX {
    for y in 0..<src.h {
      for x in 0..<src.w {
        let p = src.rgba(src.w - 1 - x, y)
        work.setRGBA(x, y, r: p.0, g: p.1, b: p.2, a: p.3)
      }
    }
  } else {
    work = src
  }

  let pivotX = cfg.flipX ? (CGFloat(src.w) - spec.neckPivot.x) : spec.neckPivot.x
  let pivotY = spec.neckPivot.y
  let headRad = cfg.headTiltDeg * .pi / 180.0
  let torsoRad = cfg.torsoTiltDeg * .pi / 180.0

  var dst = PixelCanvas(w: src.w, h: src.h)
  let anchorX = CGFloat(src.w) * 0.5
  let anchorY = CGFloat(src.h) * 0.22

  // Automatic top-headroom clamp so zoomed poses never chop off the top of the head/bun!
  var srcMinY = src.h
  outer: for y in 0..<src.h {
    for x in 0..<src.w {
      if work.rgba(x, y).3 > 0.15 {
        srcMinY = y
        break outer
      }
    }
  }
  let projectedTopY = (CGFloat(srcMinY) - anchorY) * cfg.scale + anchorY + cfg.shiftY
  let safeShiftY = cfg.shiftY + max(0, 18.0 - projectedTopY)

  for y in 0..<dst.h {
    for x in 0..<dst.w {
      let ux = (CGFloat(x) - anchorX - cfg.shiftX) / cfg.scale + anchorX
      let uy = (CGFloat(y) - anchorY - safeShiftY) / cfg.scale + anchorY

      let dy = uy - pivotY
      let band: CGFloat = 32.0
      let u = max(0.0, min(1.0, (band - dy) / (2.0 * band)))
      let headW = 0.5 - 0.5 * cos(u * .pi)
      let angle = headW * headRad + (1.0 - headW) * torsoRad

      let shX = (1.0 - headW) * cfg.torsoShearX * dy
      let dx = ux - shX - pivotX

      let cosA = cos(-angle), sinA = sin(-angle)
      let sx = pivotX + dx * cosA - dy * sinA
      let sy = pivotY + dx * sinA + dy * cosA

      let sampled = work.sampleBilinear(sx, sy)
      if sampled.3 > 0.01 {
        dst.setRGBA(x, y, r: sampled.0, g: sampled.1, b: sampled.2, a: sampled.3)
      }
    }
  }
  return dst
}

// MARK: - Build All 50 Character Sprites (Picks Up All Authentic Raws + Clean Procedural Variants)
func buildCharacterSprites() {
  let harinBaseFiles: [String: String] = [
    "normal":  harinNormal,
    "happy":   harinHappy,
    "pout":    harinPout,
    "anxious": harinAnx,
    "casual":  harinCasual,
    "date":    harinDate,
    "yandere": harinPout,
    "shy":     harinHappy,
    "lounge":  harinCasual,
    "night":   harinDate,
  ]

  let order = ["seoyoon", "harin", "sea", "chaewon", "nayeon"]
  let variants = ["normal", "happy", "pout", "anxious", "yandere", "shy", "casual", "lounge", "date", "night"]

  var cutoutCache: [String: PixelCanvas] = [:]
  func getCutout(path: String, faceCenter: CGPoint) -> PixelCanvas {
    if let hit = cutoutCache[path] { return hit }
    let c = extractBaseCanvas(from: path, faceCenter: faceCenter)
    cutoutCache[path] = c
    return c
  }

  for id in order {
    let spec = charSpecs[id]!
    let faceCenter = CGPoint(x: (spec.leftEye.x + spec.rightEye.x) * 0.5, y: (spec.leftEye.y + spec.rightEye.y) * 0.5)
    let isDarkOutfit = (id == "sea" || id == "chaewon")

    for v in variants {
      // 1. Check if a bespoke studio raw exists in newRawDir (e.g. seoyoon_casual_raw, seoyoon_happy_raw, nayeon_happy_raw, sea_happy_raw, chaewon_casual_raw, nayeon_casual_raw, etc.)
      if let bespokeRaw = findLatestRaw(prefix: "\(id)_\(v)_raw") {
        let c = getCutout(path: bespokeRaw, faceCenter: faceCenter)
        c.saveDefringedPNG(to: "\(outDir)/\(id)-\(v).png")
        print("  [RAW] \(id)-\(v).png <- \((bespokeRaw as NSString).lastPathComponent)")
        continue
      }

      // 2. Harin's 6 dedicated studio raws in legacyRawDir
      if id == "harin" && ["normal", "happy", "pout", "anxious", "casual", "date"].contains(v) {
        let c = getCutout(path: "\(legacyRawDir)/\(harinBaseFiles[v]!)", faceCenter: faceCenter)
        c.saveDefringedPNG(to: "\(outDir)/harin-\(v).png")
        print("  [RAW] harin-\(v).png <- \(harinBaseFiles[v]!)")
        continue
      }

      let basePath = (id == "harin") ? "\(legacyRawDir)/\(harinBaseFiles[v]!)" : "\(legacyRawDir)/\(spec.rawFile)"
      var c = getCutout(path: basePath, faceCenter: faceCenter)

      let activeSpec: FaceSpec = {
        if id == "harin" && v == "lounge" {
          return FaceSpec(
            id: "harin", rawFile: harinCasual,
            leftEye: CGPoint(x: 458, y: 343), rightEye: CGPoint(x: 557, y: 364),
            eyeRx: 28, eyeRy: 18,
            leftBrow: CGPoint(x: 457, y: 320), rightBrow: CGPoint(x: 572, y: 340),
            leftCheek: CGPoint(x: 445, y: 390), rightCheek: CGPoint(x: 558, y: 406),
            nose: CGPoint(x: 507, y: 411), mouth: CGPoint(x: 495, y: 456), mouthRx: 28, mouthRy: 13,
            neckPivot: CGPoint(x: 496, y: 492), crownCenter: CGPoint(x: 465, y: 170), crownTopY: 96, torsoTopY: 480,
            hasBangsOverBrows: true, skinRGB: spec.skinRGB, hairBaseRGB: spec.hairBaseRGB, hairShadowRGB: spec.hairShadowRGB, hairHiRGB: spec.hairHiRGB, lipRGB: spec.lipRGB
          )
        }
        if id == "harin" && v == "night" {
          return FaceSpec(
            id: "harin", rawFile: harinDate,
            leftEye: CGPoint(x: 456, y: 276), rightEye: CGPoint(x: 550, y: 268),
            eyeRx: 28, eyeRy: 18,
            leftBrow: CGPoint(x: 450, y: 246), rightBrow: CGPoint(x: 559, y: 238),
            leftCheek: CGPoint(x: 438, y: 318), rightCheek: CGPoint(x: 552, y: 312),
            nose: CGPoint(x: 522, y: 325), mouth: CGPoint(x: 517, y: 363), mouthRx: 26, mouthRy: 12,
            neckPivot: CGPoint(x: 495, y: 415), crownCenter: CGPoint(x: 492, y: 135), crownTopY: 62, torsoTopY: 445,
            hasBangsOverBrows: true, skinRGB: spec.skinRGB, hairBaseRGB: spec.hairBaseRGB, hairShadowRGB: spec.hairShadowRGB, hairHiRGB: spec.hairHiRGB, lipRGB: spec.lipRGB
          )
        }
        return spec
      }()

      if v != "normal" {
        let effectiveHair = applyHairstyleVariant(&c, spec: spec, variant: v)

        if id == "harin" && v == "lounge" {
          // Skin-safe recoloring of black home sweater -> soft lavender knit (0% purple bleed on neck/fingers!)
          recolorOutfit(&c, spec: activeSpec, target: (0.66, 0.48, 0.78), darkClothOnly: true, strength: 0.76)
        } else if id != "harin" {
          switch v {
          case "casual":
            let col: (Double, Double, Double) = id == "seoyoon" ? (0.76, 0.72, 0.90) : id == "sea" ? (0.30, 0.44, 0.64) : id == "chaewon" ? (0.56, 0.18, 0.24) : (0.54, 0.68, 0.88)
            recolorOutfit(&c, spec: spec, target: col, darkClothOnly: isDarkOutfit, strength: 0.72)
          case "lounge":
            let col: (Double, Double, Double) = id == "seoyoon" ? (0.94, 0.74, 0.78) : id == "sea" ? (0.58, 0.54, 0.50) : id == "chaewon" ? (0.36, 0.42, 0.54) : (0.94, 0.76, 0.80)
            recolorOutfit(&c, spec: spec, target: col, darkClothOnly: isDarkOutfit, strength: 0.70)
          case "date":
            let col: (Double, Double, Double) = id == "seoyoon" ? (0.70, 0.28, 0.36) : id == "sea" ? (0.48, 0.22, 0.34) : id == "chaewon" ? (0.42, 0.22, 0.50) : (0.76, 0.30, 0.42)
            recolorOutfit(&c, spec: spec, target: col, darkClothOnly: isDarkOutfit, strength: 0.74)
          case "night":
            let col: (Double, Double, Double) = id == "seoyoon" ? (0.28, 0.24, 0.42) : id == "sea" ? (0.18, 0.24, 0.38) : id == "chaewon" ? (0.22, 0.14, 0.30) : (0.34, 0.24, 0.44)
            recolorOutfit(&c, spec: spec, target: col, darkClothOnly: isDarkOutfit, strength: 0.58)
          default: break
          }
        }

        let isHarinNightWink = (id == "harin" && v == "night")
        applyExpression(&c, spec: activeSpec, variant: v, effectiveHairRGB: effectiveHair, rightEyeAlreadyClosed: isHarinNightWink)

        switch v {
        case "happy":   gradeCanvas(&c, sat: 1.07, bri:  0.02, con: 1.02, warmth:  0.28)
        case "pout":    gradeCanvas(&c, sat: 0.96, bri:  0.00, con: 1.02, warmth: -0.10)
        case "anxious": gradeCanvas(&c, sat: 0.92, bri: -0.01, con: 1.02, warmth: -0.16)
        case "yandere": gradeCanvas(&c, sat: 0.90, bri: -0.02, con: 1.06, warmth: -0.14)
        case "shy":     gradeCanvas(&c, sat: 1.05, bri:  0.02, con: 1.00, warmth:  0.32)
        case "lounge":  gradeCanvas(&c, sat: 1.02, bri:  0.02, con: 0.98, warmth:  0.30)
        case "date":    gradeCanvas(&c, sat: 1.08, bri:  0.01, con: 1.04, warmth:  0.18)
        case "night":
          gradeCanvas(&c, sat: 1.12, bri: -0.03, con: 1.10, warmth: -0.40)
          applySilhouetteNeonRim(&c)
        default: break
        }

        drawPropOverlay(&c, spec: activeSpec, variant: v)

        if let pose = poseTable[v] {
          c = applyArticulatedPose(c, spec: activeSpec, cfg: pose)
        }
      }

      c.saveDefringedPNG(to: "\(outDir)/\(id)-\(v).png")
      print("  [GEN] \(id)-\(v).png")
    }
  }
}

// MARK: - Build All 17 Unique Non-Duplicated Backgrounds
func saveAspectFillJPG(from rawPath: String, to outPath: String, target: CGSize = CGSize(width: 896, height: 1376)) {
  guard let src = CIImage(contentsOf: URL(fileURLWithPath: rawPath)) else {
    fatalError("Missing raw background at \(rawPath)")
  }
  let iw = src.extent.width, ih = src.extent.height
  let s = max(target.width / iw, target.height / ih)
  let scaled = src.transformed(by: CGAffineTransform(scaleX: s, y: s))
  let dx = (scaled.extent.width - target.width) * 0.5
  let dy = (scaled.extent.height - target.height) * 0.5
  let cropRect = CGRect(x: scaled.extent.minX + dx, y: scaled.extent.minY + dy, width: target.width, height: target.height)
  let finalImg = scaled.cropped(to: cropRect).transformed(by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y))

  let targetRect = CGRect(origin: .zero, size: target)
  guard let cg = ciCtx.createCGImage(finalImg, from: targetRect) else { fatalError("CGImage failed for \(outPath)") }
  let rep = NSBitmapImageRep(cgImage: cg)
  let data = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92])!
  try! data.write(to: URL(fileURLWithPath: outPath))
}

func buildAllBackgrounds() {
  // Remove orphaned legacy scene files so assets/ has strictly the 67 active assets
  let fm = FileManager.default
  for orphan in ["bg-street.jpg", "bg-euljiro.jpg"] {
    let p = "\(outDir)/\(orphan)"
    if fm.fileExists(atPath: p) { try? fm.removeItem(atPath: p) }
  }

  let bgTable: [(String, String, String?)] = [
    // 7 Seoul Public Landmarks
    ("bg-seongsu.jpg",        "bg_seongsu_raw",        "bg_seongsu_png_1794658968164.jpg"),
    ("bg-hongdae.jpg",        "bg_hongdae_raw",        nil),
    ("bg-hangang.jpg",        "bg_hangang_raw",        nil),
    ("bg-gangnam.jpg",        "bg_gangnam_raw",        nil),
    ("bg-campus.jpg",         "bg_campus_raw",         nil),
    ("bg-rooftop.jpg",        "bg_rooftop_raw",        nil),
    ("bg-namsan.jpg",         "bg_namsan_raw",         nil),
    // 10 Character Exclusive Spaces (Room + Living)
    ("bg-seoyoon-room.jpg",   "bg_seoyoon_room_raw",   nil),
    ("bg-seoyoon-living.jpg", "bg_seoyoon_living_raw", nil),
    ("bg-harin-room.jpg",     "bg_harin_room_raw",     "bg_room_1794658970842.jpg"),
    ("bg-harin-living.jpg",   "bg_harin_living_raw",   nil),
    ("bg-sea-room.jpg",       "bg_sea_room_raw",       nil),
    ("bg-sea-living.jpg",     "bg_sea_living_raw",     nil),
    ("bg-chaewon-room.jpg",   "bg_chaewon_room_raw",   nil),
    ("bg-chaewon-living.jpg", "bg_chaewon_living_raw", nil),
    ("bg-nayeon-room.jpg",    "bg_nayeon_room_raw",    nil),
    ("bg-nayeon-living.jpg",  "bg_nayeon_living_raw",  nil),
  ]

  for (outName, prefix, legacyFallback) in bgTable {
    guard let srcPath = findLatestRaw(prefix: prefix, fallbackLegacy: legacyFallback) else {
      fatalError("Missing authentic raw background for \(outName) (prefix: \(prefix))")
    }
    saveAspectFillJPG(from: srcPath, to: "\(outDir)/\(outName)")
    print("  [BG]  \(outName) <- \((srcPath as NSString).lastPathComponent)")
  }
}

print("Building 50 refined anatomical character sprites...")
buildCharacterSprites()
print("Building 17 unique studio backgrounds...")
buildAllBackgrounds()
print("All 67 assets built successfully!")
