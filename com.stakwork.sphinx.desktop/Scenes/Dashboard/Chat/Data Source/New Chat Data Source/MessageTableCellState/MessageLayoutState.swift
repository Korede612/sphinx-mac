//
//  MessageLayoutState.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 18/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

struct BubbleMessageLayoutState {
    
    struct SwipeReply {}
    
    struct Bubble {
        var direction: MessageTableCellState.MessageDirection
        var grouping: MessageTableCellState.BubbleState
        
        init(
            direction: MessageTableCellState.MessageDirection,
            grouping: MessageTableCellState.BubbleState
        ) {
            self.direction = direction
            self.grouping = grouping
        }
    }
    
    struct InvoiceLines {
        var linesState: MessageTableCellState.InvoiceLinesState
        
        init(
            linesState: MessageTableCellState.InvoiceLinesState
        ) {
            self.linesState = linesState
        }
    }
    
    struct AvatarImage {
        var imageUrl: String?
        var color: NSColor
        var alias: String
        var image: NSImage?
        
        init(
            imageUrl: String?,
            color: NSColor,
            alias: String,
            image: NSImage? = nil
        ) {
            self.imageUrl = imageUrl
            self.color = color
            self.alias = alias
            self.image = image
        }
    }
    
    struct StatusHeader {
        var senderName: String?
        var color: NSColor?
        var showSent: Bool
        var showSendingIcon: Bool
        var showBoltIcon: Bool
        var showFailedContainer: Bool
        var showLockIcon: Bool
        var showExpiredSent: Bool
        var showExpiredReceived: Bool
        var expirationTimestamp: String?
        var timestamp: String
        
        init(
            senderName: String?,
            color: NSColor?,
            showSent: Bool,
            showSendingIcon: Bool,
            showBoltIcon: Bool,
            showFailedContainer: Bool,
            showLockIcon: Bool,
            showExpiredSent: Bool,
            showExpiredReceived: Bool,
            expirationTimestamp: String?,
            timestamp: String
        ) {
            self.senderName = senderName
            self.color = color
            self.showSent = showSent
            self.showSendingIcon = showSendingIcon
            self.showBoltIcon = showBoltIcon
            self.showFailedContainer = showFailedContainer
            self.showLockIcon = showLockIcon
            self.showExpiredSent = showExpiredSent
            self.showExpiredReceived = showExpiredReceived
            self.expirationTimestamp = expirationTimestamp
            self.timestamp = timestamp
        }
    }
    
    struct ThreadMessage {
        var text: String?
        var font: NSFont?
        var senderPic: String?
        var senderAlias: String?
        var senderColor: NSColor?
        var sendDate: Date?
        
        init(
            text: String?,
            font: NSFont?,
            senderPic: String?,
            senderAlias: String?,
            senderColor: NSColor?,
            sendDate: Date?
        ) {
            self.text = text
            self.font = font
            self.senderPic = senderPic
            self.senderAlias = senderAlias
            self.senderColor = senderColor
            self.sendDate = sendDate
        }
    }
    
    struct ThreadMessages {
        var originalMessage: ThreadMessage
        var firstReplySenderIndo: (NSColor, String, String?)
        var secondReplySenderInfo: (NSColor, String, String?)?
        var moreRepliesCount: Int
        
        init(
            originalMessage: ThreadMessage,
            firstReplySenderIndo: (NSColor, String, String?),
            secondReplySenderInfo: (NSColor, String, String?)?,
            moreRepliesCount: Int
        ) {
            self.originalMessage = originalMessage
            self.firstReplySenderIndo = firstReplySenderIndo
            self.secondReplySenderInfo = secondReplySenderInfo
            self.moreRepliesCount = moreRepliesCount
        }
    }
    
    struct ThreadLastReply {
        var lastReplySenderInfo: (NSColor, String, String?)
        var timestamp: String
        
        init(
            lastReplySenderInfo: (NSColor, String, String?),
            timestamp: String
        ) {
            self.lastReplySenderInfo = lastReplySenderInfo
            self.timestamp = timestamp
        }
    }
    
    struct MessageReply {
        var messageId: Int
        var color: NSColor
        var alias: String
        var message: String?
        var mediaType: Int?
        
        init(
            messageId: Int,
            color: NSColor,
            alias: String,
            message: String?,
            mediaType: Int?
        ) {
            self.messageId = messageId
            self.color = color
            self.alias = alias
            self.message = message
            self.mediaType = mediaType
        }
    }
    
    struct MessageContent {
        var text: String?
        var font: NSFont
        var linkMatches: [NSTextCheckingResult]
        var shouldLoadPaidText: Bool
        
        init(
            text: String?,
            font: NSFont,
            linkMatches: [NSTextCheckingResult],
            shouldLoadPaidText: Bool
        ) {
            self.text = text
            self.font = font
            self.linkMatches = linkMatches
            self.shouldLoadPaidText = shouldLoadPaidText
        }
    }
    
    struct BotHTMLContent {
        var html: String
        
        init(
            html: String
        ) {
            self.html = html
        }
    }
    
    struct DirectPayment {
        var amount: Int
        var isTribePmt: Bool
        
        var recipientPic: String?
        var recipientAlias: String?
        var recipientColor: NSColor?
        
        init(
            amount: Int,
            isTribePmt: Bool,
            recipientPic: String?,
            recipientAlias: String?,
            recipientColor: NSColor?
        ) {
            self.amount = amount
            self.isTribePmt = isTribePmt
            self.recipientPic = recipientPic
            self.recipientAlias = recipientAlias
            self.recipientColor = recipientColor
        }
    }
    
    struct CallLink {
        var link: String
        var callMode: VideoCallHelper.CallMode
        
        init(
            link: String,
            callMode: VideoCallHelper.CallMode
        ) {
            self.link = link
            self.callMode = callMode
        }
    }
    
    struct GenericFile {
        var url: URL?
        var mediaKey: String?
        
        init(
            url: URL?,
            mediaKey: String?
        ) {
            self.url = url
            self.mediaKey = mediaKey
        }
    }
    
    struct MessageMedia {
        var url: URL?
        var mediaKey: String?
        var isImage: Bool
        var isVideo: Bool
        var isGif: Bool
        var isPdf: Bool
        var isGiphy: Bool
        var isPaid: Bool
        var isPaymentTemplate: Bool
        
        init(
            url: URL?,
            mediaKey: String?,
            isImage: Bool,
            isVideo: Bool,
            isGif: Bool,
            isPdf: Bool,
            isGiphy: Bool,
            isPaid: Bool,
            isPaymentTemplate: Bool
        ) {
            self.url = url
            self.mediaKey = mediaKey
            self.isImage = isImage
            self.isVideo = isVideo
            self.isGif = isGif
            self.isPdf = isPdf
            self.isGiphy = isGiphy
            self.isPaid = isPaid
            self.isPaymentTemplate = isPaymentTemplate
        }
        
        func isPendingPayment() -> Bool {
            return isPaid && (url == nil || mediaKey == nil)
        }
    }
    
    struct Audio {
        var url: URL?
        var mediaKey: String?
        var bubbleWidth: CGFloat
        
        init(
            url: URL?,
            mediaKey: String?,
            bubbleWidth: CGFloat
        ) {
            self.url = url
            self.mediaKey = mediaKey
            self.bubbleWidth = bubbleWidth
        }
    }
    
    struct Boosts {
        var boosts: [Boost]
        var totalAmount: Int
        var boostedByMe: Bool
        
        init(
            boosts: [Boost],
            totalAmount: Int,
            boostedByMe: Bool
        ) {
            self.boosts = boosts
            self.totalAmount = totalAmount
            self.boostedByMe = boostedByMe
        }
    }
    
    struct Boost {
        var amount: Int
        var senderPic: String?
        var senderAlias: String?
        var senderColor: NSColor?
        
        init(
            amount: Int,
            senderPic: String?,
            senderAlias: String?,
            senderColor: NSColor?
        ) {
            self.amount = amount
            self.senderPic = senderPic
            self.senderAlias = senderAlias
            self.senderColor = senderColor
        }
    }
    
    struct PodcastBoost {
        var amount: Int
        
        init(
            amount: Int
        ) {
            self.amount = amount
        }
    }
    
    struct ContactLink {
        var pubkey: String
        var imageUrl: String?
        var alias: String?
        var color: NSColor?
        var isContact: Bool
        var bubbleWidth: CGFloat
        var roundedBottom: Bool
        
        init(
            pubkey: String,
            imageUrl: String?,
            alias: String?,
            color: NSColor?,
            isContact: Bool,
            bubbleWidth: CGFloat,
            roundedBottom: Bool
        ) {
            self.pubkey = pubkey
            self.imageUrl = imageUrl
            self.alias = alias
            self.color = color
            self.isContact = isContact
            self.bubbleWidth = bubbleWidth
            self.roundedBottom = roundedBottom
        }
    }
    
    struct TribeLink {
        var link: String
        
        init(
            link: String
        ) {
            self.link = link
        }
    }
    
    struct WebLink {
        var link: String
        
        init(
            link: String
        ) {
            self.link = link
        }
    }
    
    struct PaidContent {
        var price: Int
        var statusTitle: String
        var status: TransactionMessage.TransactionMessageType
        var shouldAddPadding: Bool
        
        init(
            price: Int,
            statusTitle: String,
            status: TransactionMessage.TransactionMessageType,
            shouldAddPadding: Bool
        ) {
            self.price = price
            self.statusTitle = statusTitle
            self.status = status
            self.shouldAddPadding = shouldAddPadding
        }
        
        func isPurchaseAccepted() -> Bool {
            return status == TransactionMessage.TransactionMessageType.purchaseAccept
        }
        
        func isPurchaseDenied() -> Bool {
            return status == TransactionMessage.TransactionMessageType.purchaseDeny
        }
    }
    
    struct PodcastComment {
        var title: String
        var timestamp: Int
        var url: URL
        var bubbleWidth: CGFloat
        
        init(
            title: String,
            timestamp: Int,
            url: URL,
            bubbleWidth: CGFloat
        ) {
            self.title = title
            self.timestamp = timestamp
            self.url = url
            self.bubbleWidth = bubbleWidth
        }
    }
    
    struct Invoice {
        var date: Date
        var amount: Int
        var memo: String?
        var font: NSFont
        var isPaid: Bool
        var isExpired: Bool
        var bubbleWidth: CGFloat
        
        init(
            date: Date,
            amount: Int,
            memo: String?,
            font: NSFont,
            isPaid: Bool,
            isExpired: Bool,
            bubbleWidth: CGFloat
        ) {
            self.date = date
            self.amount = amount
            self.memo = memo
            self.font = font
            self.isPaid = isPaid
            self.isExpired = isExpired
            self.bubbleWidth = bubbleWidth
        }
    }
    
    struct Payment {
        var date: Date
        var amount: Int
        
        init(
            date: Date,
            amount: Int
        ) {
            self.date = date
            self.amount = amount
        }
    }
}

struct NoBubbleMessageLayoutState {
    
    struct NoBubble {
        var direction: MessageTableCellState.MessageDirection
        
        init(
            direction: MessageTableCellState.MessageDirection
        ) {
            self.direction = direction
        }
    }
    
    struct GroupMemberNotification {
        
        var message: String
        
        init(
            message: String
        ) {
            self.message = message
        }
    }
    
    struct GroupKickRemovedOrDeclined {
        var message: String
        
        init(
            message: String
        ) {
            self.message = message
        }
    }
    
    struct GroupMemberRequest {
        var status: MemberRequestStatus
        var isActiveMember: Bool
        var senderAlias: String
        
        enum MemberRequestStatus: Int {
            case Pending = 19
            case Approved = 20
            case Rejected = 21
        }
        
        init(
            status: MemberRequestStatus,
            isActiveMember: Bool,
            senderAlias: String
        ) {
            self.status = status
            self.isActiveMember = isActiveMember
            self.senderAlias = senderAlias
        }
    }
    
    struct DateSeparator {
        
        var timestamp: String
        
        init(
            timestamp: String
        ) {
            self.timestamp = timestamp
        }
    }
    
    struct Deleted {
        var timestamp: String
        
        init(
            timestamp: String
        ) {
            self.timestamp = timestamp
        }
    }
    
    struct ThreadOriginalMessage {
        var text: String
        var linkMatches: [NSTextCheckingResult]
        var senderPic: String?
        var senderAlias: String
        var senderColor: NSColor
        var timestamp: String
        
        init(
            text: String,
            linkMatches: [NSTextCheckingResult],
            senderPic: String?,
            senderAlias: String,
            senderColor: NSColor,
            timestamp: String
        ) {
            self.text = text
            self.linkMatches = linkMatches
            self.senderPic = senderPic
            self.senderAlias = senderAlias
            self.senderColor = senderColor
            self.timestamp = timestamp
        }
    }
}
