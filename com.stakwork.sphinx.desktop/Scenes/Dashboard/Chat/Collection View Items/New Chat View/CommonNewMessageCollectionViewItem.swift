//
//  CommonNewMessageCollectionViewItem.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 18/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

class CommonNewMessageCollectionViewitem : NSCollectionViewItem {
    
    weak var delegate: ChatCollectionViewItemDelegate!
    
    var rowIndex: Int!
    var messageId: Int?
    
    var urlRanges = [NSRange]()
    
    let kChatAvatarHeight: CGFloat = 33
    
    static let kMaximumLabelBubbleWidth: CGFloat = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    @objc func labelTapped(
//        gesture: UITapGestureRecognizer
//    ) {
//        if let label = gesture.view as? UILabel, let text = label.text {
//            for range in urlRanges {
//                if gesture.didTapAttributedTextInLabel(
//                    label,
//                    inRange: range
//                ) {
//                    let link = (text as NSString).substring(with: range)
//                    delegate?.didTapOnLink(link)
//                }
//            }
//        }
//    }
//
//
//    func addLongPressRescognizer() {
//        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        lpgr.minimumPressDuration = 0.5
//        lpgr.delaysTouchesBegan = true
//
//        contentView.addGestureRecognizer(lpgr)
//    }
//
//    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
//        if (gestureReconizer.state == .began) {
//            if shouldPreventOtherGestures {
//                return
//            }
//            didLongPressOnCell()
//        }
//    }
    
    func getBubbleView() -> NSBox? {
        return nil
    }
    
//    func didLongPressOnCell() {
//        if let messageId = messageId, let bubbleView = getBubbleView() {
//            delegate?.didLongPressOn(
//                cell: self,
//                with: messageId,
//                bubbleViewRect: bubbleView.frame
//            )
//        }
//    }
}