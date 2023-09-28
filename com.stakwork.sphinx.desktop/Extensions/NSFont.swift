//
//  NSFont.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 05/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

extension NSFont {
    func withTraits(
        traits: NSFontDescriptor.SymbolicTraits
    ) -> NSFont {
        if fontDescriptor.symbolicTraits.contains(traits) {
            let descriptor = fontDescriptor.withSymbolicTraits(traits)
            if let updatedFont = NSFont(descriptor: descriptor, size: 0) {
                return updatedFont
            }
        }
        return self
    }
    
    func bold() -> NSFont {
        return withTraits(traits: NSFontDescriptor.SymbolicTraits.bold)
    }
    
    func italic() -> NSFont {
        return withTraits(traits: NSFontDescriptor.SymbolicTraits.italic)
    }
    
    static func getMessageFont() -> NSFont {
        return Constants.kMessageFont
    }
    
    static func getEmojisFont() -> NSFont {
        return Constants.kEmojisFont
    }
    
    static func getThreadHeaderFont() -> NSFont {
        return NSFont(name: "Roboto-Regular", size: 16)!
    }
    
    static func getAmountFont() -> NSFont {
        return NSFont(name: "Roboto-Bold", size: 16)!
    }
    
    static func getEncryptionErrorFont() -> NSFont {
        return Constants.kBoldSmallMessageFont
    }
}
