//
//  ThreadListCollectionViewItem+MessageTypesExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 28/09/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

extension ThreadListCollectionViewItem {
    func configureWith(
        threadLayoutState: ThreadLayoutState.ThreadMessages?
    ) {
        guard let threadLayoutState = threadLayoutState else {
            return
        }
        
        let originalMessageSenderInfo = threadLayoutState.orignalThreadMessage.senderInfo
        
        if threadLayoutState.orignalThreadMessage.text.isNotEmpty {
            originalMessageTextLabel.maximumNumberOfLines = 2
            originalMessageTextLabel.stringValue = threadLayoutState.orignalThreadMessage.text
            originalMessageTextLabel.isHidden = false
        }
        
        originalMessageDateLabel.stringValue = threadLayoutState.orignalThreadMessage.timestamp
        originalMessageSenderAliasLabel.stringValue = originalMessageSenderInfo.1
        
        originalMessageAvatarView.configureForUserWith(
            color: originalMessageSenderInfo.0,
            alias: originalMessageSenderInfo.1,
            picture: originalMessageSenderInfo.2,
            radius: 18.0
        )
        
        repliesCountLabel.stringValue = "\(threadLayoutState.repliesCount) replies"
        lastReplyDateLabel.stringValue = threadLayoutState.lastReplyTimestamp
        
        let threadPeople = threadLayoutState.threadPeople

        if (threadPeople.count > 0) {
            reply1Container.isHidden = false

            let reply1SenderInfo = threadLayoutState.threadPeople[0].senderIndo

            reply1AvatarView.configureForUserWith(
                color: reply1SenderInfo.0,
                alias: reply1SenderInfo.1,
                picture: reply1SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply1Container.isHidden = true
        }

        if (threadPeople.count > 1) {
            reply2Container.isHidden = false

            let reply2SenderInfo = threadLayoutState.threadPeople[1].senderIndo

            reply2AvatarView.configureForUserWith(
                color: reply2SenderInfo.0,
                alias: reply2SenderInfo.1,
                picture: reply2SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply2Container.isHidden = true
        }

        if (threadPeople.count > 2) {
            reply3Container.isHidden = false

            let reply3SenderInfo = threadLayoutState.threadPeople[2].senderIndo

            reply3AvatarView.configureForUserWith(
                color: reply3SenderInfo.0,
                alias: reply3SenderInfo.1,
                picture: reply3SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply3Container.isHidden = true
        }

        if (threadPeople.count > 3) {
            reply4Container.isHidden = false

            let reply4SenderInfo = threadLayoutState.threadPeople[3].senderIndo

            reply4AvatarView.configureForUserWith(
                color: reply4SenderInfo.0,
                alias: reply4SenderInfo.1,
                picture: reply4SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply4Container.isHidden = true
        }

        if (threadPeople.count > 4) {
            reply5Container.isHidden = false

            let reply5SenderInfo = threadLayoutState.threadPeople[4].senderIndo

            reply5AvatarView.configureForUserWith(
                color: reply5SenderInfo.0,
                alias: reply5SenderInfo.1,
                picture: reply5SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply5Container.isHidden = true
        }

        if (threadPeople.count > 5) {
            reply6Container.isHidden = false

            let reply6SenderInfo = threadLayoutState.threadPeople[5].senderIndo

            reply6AvatarView.configureForUserWith(
                color: reply6SenderInfo.0,
                alias: reply6SenderInfo.1,
                picture: reply6SenderInfo.2,
                radius: 11.0
            )
        } else {
            reply6Container.isHidden = true
        }

        if threadLayoutState.threadPeopleCount > 6 {
            reply6CountContainer.isHidden = false
            reply6CountLabel.stringValue = "+\(threadLayoutState.threadPeopleCount-6)"
        } else {
            reply6CountContainer.isHidden = true
        }
    }
    
    func configureWith(
        messageMedia: BubbleMessageLayoutState.MessageMedia?,
        mediaData: MessageTableCellState.MediaData?
    ) {
        if let messageMedia = messageMedia {
            
            mediaMessageView.configureWith(
                messageMedia: messageMedia,
                mediaData: mediaData,
                bubble: BubbleMessageLayoutState.Bubble(direction: .Incoming, grouping: .Isolated),
                and: self
            )
            
            mediaMessageView.isHidden = false
            mediaMessageView.mediaButton.isEnabled = false
            
            if let messageId = messageId, mediaData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    if messageMedia.isImage {
                        self.delegate?.shouldLoadImageDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isPdf {
                        self.delegate?.shouldLoadPdfDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isVideo {
                        self.delegate?.shouldLoadVideoDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    } else if messageMedia.isGiphy {
                        self.delegate?.shouldLoadGiphyDataFor(
                            messageId: messageId,
                            and: self.rowIndex
                        )
                    }
                }
            }
        }
    }
    
    func configureWith(
        genericFile: BubbleMessageLayoutState.GenericFile?,
        mediaData: MessageTableCellState.MediaData?
    ) {
        if let _ = genericFile {

            fileDetailsView.configureWith(
                mediaData: mediaData,
                and: self
            )

            fileDetailsView.isHidden = false

            if let messageId = messageId, mediaData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    self.delegate?.shouldLoadFileDataFor(
                        messageId: messageId,
                        and: self.rowIndex
                    )
                }
            }
        }
    }
    
    func configureWith(
        audio: BubbleMessageLayoutState.Audio?,
        mediaData: MessageTableCellState.MediaData?
    ) {
        if let audio = audio {
            
            audioMessageView.configureWith(
                audio: audio,
                mediaData: mediaData,
                bubble: BubbleMessageLayoutState.Bubble(direction: .Incoming, grouping: .Isolated),
                and: self
            )
            
            audioMessageView.isHidden = false

            if let messageId = messageId, mediaData == nil {
                let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.global().asyncAfter(deadline: delayTime) {
                    self.delegate?.shouldLoadAudioDataFor(
                        messageId: messageId,
                        and: self.rowIndex
                    )
                }
            }
        }
    }
}

extension ThreadListCollectionViewItem : MediaMessageViewDelegate {
    func didTapMediaButton() {}
}

extension ThreadListCollectionViewItem : FileInfoViewDelegate {
    func didTouchDownloadButton() {}
}

extension ThreadListCollectionViewItem : AudioMessageViewDelegate {
    func didTapPlayPauseButton() {}
}