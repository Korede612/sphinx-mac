//
//  ChatMentionAutocompleteCell.swift
//  Sphinx
//
//  Created by James Carucci on 12/14/22.
//  Copyright © 2022 Tomas Timinskas. All rights reserved.
//

import Cocoa

class ChatMentionAutocompleteCell: NSCollectionViewItem {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.purple.cgColor
    }
    
    func configureWith(alias:String){
        self.textField?.stringValue = alias
    }
    
}
