//
//  NewChatViewModel+AttachmentsExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 19/09/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Foundation

extension NewChatViewModel: AttachmentsManagerDelegate {
    func insertPrivisionalAttachmentMessageAndUpload(
        attachmentObject: AttachmentObject,
        chat: Chat?,
        audioDuration: Double? = nil
    ) {
//        let attachmentsManager = AttachmentsManager.sharedInstance
//
//        chatDataSource?.setMediaDataForMessageWith(
//            messageId: TransactionMessage.getProvisionalMessageId(),
//            mediaData: MessageTableCellState.MediaData(
//                image: attachmentObject.image,
//                data: attachmentObject.getDecryptedData(),
//                fileInfo: attachmentObject.getFileInfo(),
//                audioInfo: attachmentObject.getAudioInfo(duration: audioDuration),
//                failed: false
//            )
//        )
//
//        if let message = TransactionMessage.createProvisionalAttachmentMessage(
//            attachmentObject: attachmentObject,
//            date: Date(),
//            chat: chat,
//            replyUUID: replyingTo?.uuid,
//            threadUUID: threadUUID ?? replyingTo?.threadUUID ?? replyingTo?.uuid
//        ) {
//            attachmentsManager.setData(
//                delegate: self,
//                contact: contact,
//                chat: chat,
//                provisionalMessage: message
//            )
//
//            chatDataSource?.setProgressForProvisional(messageId: message.id, progress: 0)
//
////            let dataSourceThreadUUID = (chatDataSource as? ThreadTableDataSource)?.threadUUID
//
////            attachmentsManager.uploadAndSendAttachment(
////                attachmentObject: attachmentObject,
////                replyingMessage: replyingTo,
////                threadUUID: dataSourceThreadUUID ?? replyingTo?.threadUUID ?? replyingTo?.uuid
////            )
//
//            attachmentsManager.uploadAndSendAttachment(
//                attachmentObject: attachmentObject,
//                replyingMessage: replyingTo,
//                threadUUID: replyingTo?.threadUUID ?? replyingTo?.uuid
//            )
//        }
//
//        resetReply()
    }
    
    func shouldReplaceMediaDataFor(provisionalMessageId: Int, and messageId: Int) {
        chatDataSource?.replaceMediaDataForMessageWith(
            provisionalMessageId: provisionalMessageId,
            toMessageWith: messageId
        )
    }
    
    func didFailSendingMessage(
        provisionalMessage: TransactionMessage?
    ) {
        if let provisionalMessage = provisionalMessage {
            CoreDataManager.sharedManager.deleteObject(object: provisionalMessage)
            
            AlertHelper.showAlert(title: "generic.error.title".localized, message: "generic.error.message".localized)
        }
    }
    
    func didUpdateUploadProgressFor(messageId: Int, progress: Int) {
        chatDataSource?.setProgressForProvisional(messageId: messageId, progress: progress)
    }
    
    func didSuccessSendingAttachment(message: TransactionMessage, image: NSImage?) {
        insertSentMessage(
            message: message,
            completion: { _ in }
        )
    }
}

extension NewChatViewModel {
    func shouldStartRecordingWith(
        delegate: AudioHelperDelegate
    ) {
        let didAskForPermissions = configureAudioSession(delegate: delegate)
        
        if !didAskForPermissions {
            audioRecorderHelper.shouldStartRecording()
        }
    }
    
    func shouldStopAndSendAudio() {
        audioRecorderHelper.shouldFinishRecording()
    }
    
    func shouldCancelRecording() {
        audioRecorderHelper.shouldCancelRecording()
    }
    
    func configureAudioSession(
        delegate: AudioHelperDelegate
    ) -> Bool {
//        let didAskForPermissions = audioRecorderHelper.configureAudioSession(delegate: delegate)
//        return didAskForPermissions
        return true
    }
    
    func didFinishRecording() {
//        let audioData = audioRecorderHelper.getAudioData()
//        
//        if let data = audioData.0 {
//            let (key, encryptedData) = SymmetricEncryptionManager.sharedInstance.encryptData(data: data)
//            
//            if let encryptedData = encryptedData {
//                
//                let attachmentObject = AttachmentObject(
//                    data: encryptedData,
//                    mediaKey: key,
//                    type: AttachmentsManager.AttachmentType.Audio
//                )
//                
//                insertPrivisionalAttachmentMessageAndUpload(
//                    attachmentObject: attachmentObject,
//                    chat: chat,
//                    audioDuration: audioData.1
//                )
//            }
//        }
    }
}