//
//  DragView.swift
//  IconMaker2
//
//  Created by Yurii Zadoianchuk on 15/05/2017.
//  Copyright © 2017 Yurii Zadoianchuk. All rights reserved.
//

import Cocoa

class DragView: NSView {
  
  @IBOutlet var imageView: NSImageView!
  
  let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String), NSPasteboard.PasteboardType(rawValue: kUTTypeItem as String), NSPasteboard.PasteboardType(rawValue: kUTTypeURL as String), NSPasteboard.PasteboardType(rawValue: kUTTypePNG as String), NSPasteboard.PasteboardType(rawValue: kUTTypeImage as String)])

  }
  
  override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    return true
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    
    return .copy
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    imageView.image = NSImage(pasteboard: sender.draggingPasteboard())
    return true
  }
    
}
