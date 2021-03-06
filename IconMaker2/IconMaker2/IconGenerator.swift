//
//  IconGenerator.swift
//  IconMaker2
//
//  Created by Yurii Zadoianchuk on 16/05/2017.
//  Copyright © 2017 Yurii Zadoianchuk. All rights reserved.
//

import AppKit

enum IconGeneratorError: Error {
  case stringError(String)
  case cancelPressed
}

class IconGenerator {
  class func generateIcon(_ originalImage: NSImage, outputFolderPath: URL) throws {
    do {
      let iconJSONPath = getIconJSONPath(iconFolderPath: outputFolderPath)
      let jsonDict = try getJSONDict(jsonDictPath: iconJSONPath)
//      guard let sizesArray = jsonDict["images"] as? NSArray else {
//        throw IconGeneratorError.stringError("Error retrieving icon sizes from icon JSON")
//      }
//      for singleSize in sizesArray {
//        guard let si = singleSize as? NSMutableDictionary,
//          let size = si["size"] as? String,
//          let scale = si["scale"] as? String else {
//            throw IconMakerError.stringError("")
//        }
//        let resultName = try resizeImage(img: originalImage, stringSize: size, stringScale: scale, savePath: isu)
//        si["filename"] = resultName
//      }
//      try saveResultingIconJSON(jsonDict: jsonDict, savePath: iconJSONPath)
    } catch IconGeneratorError.stringError(let description) {

    } catch _ {
      
    }
  }
  
  class func loadImageAtPath(imagePathURL: URL) throws -> NSImage {
    guard let i = NSImage(contentsOf: imagePathURL) else {
      throw IconGeneratorError.stringError("Loading original image failed")
    }
    return i
  }
  
  static func getIconJSONPath(iconFolderPath: URL) -> URL {
    return iconFolderPath.appendingPathComponent("Contents.json")
  }
  
  static func getJSONDict(jsonDictPath: URL) throws -> NSDictionary {
    guard let data = NSData(contentsOf: jsonDictPath) else {
      throw IconGeneratorError.stringError("Loading icon JSON failed")
    }
    guard let jsonDict = try? JSONSerialization.jsonObject(with: data as Data, options: [.mutableContainers]) as? NSDictionary else {
      throw IconGeneratorError.stringError("Parsing icon JSON failed")
    }
    return jsonDict!
  }
  
  func resizeImage(img: NSImage, stringSize: String, stringScale: String, savePath: URL) throws -> String {
    guard let size = Double(stringSize.components(separatedBy: "x").first!),
      let scale = Double(stringScale.components(separatedBy: "x").first!) else {
        throw IconGeneratorError.stringError("Error retrieving icon size or scale")
    }
    let resultSize = NSSize(width: size * scale, height: size * scale)
    img.size = resultSize
    _ = NSBitmapImageRep(focusedViewRect: NSRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height))
    let data = try dataFromImage(image: img, size: Int(size * scale))
    let imgName = "Icon-\(size)@\(stringScale).png"
    try! data.write(to: savePath.appendingPathComponent(imgName), options: [Data.WritingOptions.atomic])
    //        else {
    //            throw IconMakerError.stringError("Error saving icon")
    //        }
    return imgName
  }
  
  func dataFromImage(image: NSImage, size: Int) throws -> Data {
    if let representation = NSBitmapImageRep(bitmapDataPlanes: nil,
                                             pixelsWide: size,
                                             pixelsHigh: size,
                                             bitsPerSample: 8,
                                             samplesPerPixel: 4,
                                             hasAlpha: true,
                                             isPlanar: false,
                                             colorSpaceName: NSColorSpaceName.calibratedRGB,
                                             bytesPerRow: 0,
                                             bitsPerPixel: 0) {
      representation.size = NSSize(width: size, height: size)
      NSGraphicsContext.saveGraphicsState()
      NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: representation)
      image.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                 from: NSZeroRect,
                 operation: NSCompositingOperation.copy,
                 fraction: 1.0)
      NSGraphicsContext.restoreGraphicsState()
      guard let imageData = representation.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey : AnyObject]()) else {
        throw IconGeneratorError.stringError("Error obtaining data for icon image")
      }
      return imageData
    } else {
      throw IconGeneratorError.stringError("Error obtaining representation for icon image")
    }
  }
  
  func saveResultingIconJSON(jsonDict: NSDictionary, savePath: URL) throws {
    do {
      let data = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
      guard let _ = try? data.write(to: savePath) else {
        throw IconGeneratorError.stringError("Error saving icon JSON to disk")
      }
    } catch IconGeneratorError.stringError(let description) {
      throw IconGeneratorError.stringError(description)
    } catch _ {
      throw IconGeneratorError.stringError("Error creating icon JSON")
    }
  }
}
