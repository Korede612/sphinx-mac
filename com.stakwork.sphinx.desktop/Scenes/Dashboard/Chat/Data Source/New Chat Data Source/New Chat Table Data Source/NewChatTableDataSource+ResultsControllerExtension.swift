//
//  NewChatTableDataSource+ResultsControllerExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 18/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa
import CoreData

extension NewChatTableDataSource {
    
    enum CollectionViewSection: Int, CaseIterable {
        case messages
    }
    
    typealias DataSource = NSCollectionViewDiffableDataSource<CollectionViewSection, MessageTableCellState>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, MessageTableCellState>
    
    func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: self.collectionView,
            itemProvider: makeCellProvider(for: self.collectionView)
        )

        return dataSource
    }

    func configureDataSource() {
        dataSource = makeDataSource()

//        restorePreloadedMessages()
        
        DelayPerformedHelper.performAfterDelay(seconds: 0.1, completion: { [weak self] in
            guard let self = self else { return }
            self.configureResultsController(items: max(self.dataSource.snapshot().numberOfItems, 500))
        })
    }
    
    func makeSnapshotForCurrentState() -> DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()

        snapshot.appendSections([CollectionViewSection.messages])

        snapshot.appendItems(
            messageTableCellStateArray,
            toSection: .messages
        )

        return snapshot
    }
    
    func updateSnapshot() {
        let snapshot = makeSnapshotForCurrentState()

        DispatchQueue.main.async {
//            self.saveSnapshotCurrentState()
            self.dataSource.apply(snapshot, animatingDifferences: false)
            self.collectionView.alphaValue = 1.0
//            self.restoreScrollLastPosition()
            self.collectionView.scrollToBottom(animated: false)
            self.loadingMoreItems = false
        }
    }
    
    func makeCellProvider(
        for collectionView: NSCollectionView
    ) -> DataSource.ItemProvider {
        { (collectionView, indexPath, dataSourceItem) -> NSCollectionViewItem in
            
            var cell: ChatCollectionViewItemProtocol? = nil
            var mutableDataSourceItem = dataSourceItem

//            if let _ = mutableDataSourceItem.bubble {
//                if mutableDataSourceItem.isTextOnlyMessage {
                    cell = collectionView.makeItem(
                        withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NewOnlyTextMessageCollectionViewitem"),
                        for: indexPath
                    ) as? ChatCollectionViewItemProtocol
//                } else {
//                    cell = tableView.dequeueReusableCell(
//                        withIdentifier: "NewMessageTableViewCell",
//                        for: indexPath
//                    ) as! NewMessageTableViewCell
//                }
//            } else {
//                cell = tableView.dequeueReusableCell(
//                    withIdentifier: "MessageNoBubbleTableViewCell",
//                    for: indexPath
//                ) as! MessageNoBubbleTableViewCell
//            }

            let mediaData = (dataSourceItem.messageId != nil) ? self.mediaCached[dataSourceItem.messageId!] : nil
            let tribeData = (dataSourceItem.linkTribe?.uuid != nil) ? self.preloaderHelper.tribesData[dataSourceItem.linkTribe!.uuid] : nil
            let linkData = (dataSourceItem.linkWeb?.link != nil) ? self.preloaderHelper.linksData[dataSourceItem.linkWeb!.link] : nil
            let botWebViewData = (dataSourceItem.messageId != nil) ? self.botsWebViewData[dataSourceItem.messageId!] : nil
            let uploadProgressData = (dataSourceItem.messageId != nil) ? self.uploadingProgress[dataSourceItem.messageId!] : nil

            cell?.configureWith(
                messageCellState: dataSourceItem,
                mediaData: mediaData,
                tribeData: tribeData,
                linkData: linkData,
                botWebViewData: botWebViewData,
                uploadProgressData: uploadProgressData,
                delegate: self,
                searchingTerm: self.searchingTerm,
                indexPath: indexPath
            )

            return (cell as? NSCollectionViewItem) ?? NSCollectionViewItem()
        }
    }
}

extension NewChatTableDataSource {
    
    func processMessages(
        messages: [TransactionMessage]
    ) {
        let chat = chat ?? contact?.getFakeChat()
        
        guard let chat = chat else {
            return
        }
        
        guard let owner = UserContact.getOwner() else {
            return
        }
        
//        startSearchProcess()
        
        var newMsgCount = 0
        var array: [MessageTableCellState] = []
        
        let admin = chat.getAdmin()
        let contact = chat.getConversationContact()
        
        let replyingMessagesMap = getReplyingMessagesMapFor(messages: messages)
        let boostMessagesMap = getBoostMessagesMapFor(messages: messages)
        let purchaseMessagesMap = getPurchaseMessagesMapFor(messages: messages)
        let linkContactsArray = getLinkContactsArrayFor(messages: messages)
        let linkTribesArray = getLinkTribesArrayFor(messages: messages)
        
        var groupingDate: Date? = nil
        
        var invoiceData: (Int, Int) = (0, 0)
        
        chat.processAliasesFrom(messages: messages)

        for (index, message) in messages.enumerated() {
            
            invoiceData = (
                invoiceData.0 + ((message.isPayment() && message.isIncoming(ownerId: owner.id)) ? -1 : 0),
                invoiceData.1 + ((message.isPayment() && message.isOutgoing(ownerId: owner.id)) ? -1 : 0)
            )
            
            let bubbleStateAndDate = getBubbleBackgroundForMessage(
                message: message,
                with: index,
                in: messages,
                groupingDate: &groupingDate
            )
            
//            if let separatorDate = bubbleStateAndDate.1 {
//                array.insert(
//                    MessageTableCellState(
//                        chat: chat,
//                        owner: owner,
//                        contact: contact,
//                        tribeAdmin: admin,
//                        viewWidth: collectionView.frame.width,
//                        separatorDate: separatorDate,
//                        invoiceData: (invoiceData.0 > 0, invoiceData.1 > 0)
//                    ),
//                    at: 0
//                )
//            }
            
            let replyingMessage = (message.replyUUID != nil) ? replyingMessagesMap[message.replyUUID!] : nil
            let boostsMessages = (message.uuid != nil) ? (boostMessagesMap[message.uuid!] ?? []) : []
            let purchaseMessages = purchaseMessagesMap[message.getMUID()] ?? [:]
            let linkContact = linkContactsArray[message.id]
            let linkTribe = linkTribesArray[message.id]
            let linkWeb = getLinkWebFor(message: message)
            
            let messageTableCellState = MessageTableCellState(
                message: message,
                chat: chat,
                owner: owner,
                contact: contact,
                tribeAdmin: admin,
                viewWidth: 0.0,
                separatorDate: nil,
                bubbleState: bubbleStateAndDate.0,
                contactImage: headerImage,
                replyingMessage: replyingMessage,
                boostMessages: boostsMessages,
                purchaseMessages: purchaseMessages,
                linkContact: linkContact,
                linkTribe: linkTribe,
                linkWeb: linkWeb,
                invoiceData: (invoiceData.0 > 0, invoiceData.1 > 0)
            )
            
            array.insert(messageTableCellState, at: 0)
            
            invoiceData = (
                invoiceData.0 + ((message.isInvoice() && message.isPaid() && message.isOutgoing(ownerId: owner.id)) ? 1 : 0),
                invoiceData.1 + ((message.isInvoice() && message.isPaid() && message.isIncoming(ownerId: owner.id)) ? 1 : 0)
            )
            
            newMsgCount += getNewMessageCountFor(message: message, and: owner)
            
//            processForSearch(
//                message: message,
//                messageTableCellState: messageTableCellState,
//                index: array.count - 1
//            )
        }
        
        messageTableCellStateArray = array
        
        updateSnapshot()
        delegate?.configureNewMessagesIndicatorWith(newMsgCount: newMsgCount)
        
//        finishSearchProcess()
    }
    
    func forceReload() {
        processMessages(messages: messagesArray)
    }
    
    private func getNewMessageCountFor(
        message: TransactionMessage,
        and owner: UserContact
    ) -> Int {
        if (
            message.isIncoming(ownerId: owner.id) &&
            message.seen == false &&
            message.chat?.seen == false
        ) {
            return 1
        }
        return 0
    }
    
    private func getBubbleBackgroundForMessage(
        message: TransactionMessage,
        with index: Int,
        in messages: [TransactionMessage],
        groupingDate: inout Date?
    ) -> (MessageTableCellState.BubbleState?, Date?) {
        
        let previousMessage = (index < messages.count - 1) ? messages[index + 1] : nil
        let nextMessage = (index > 0) ? messages[index - 1] : nil
        
        var separatorDate: Date? = nil
        
        if let nextMessageDate = nextMessage?.date, let date = message.date {
            if Date.isDifferentDay(firstDate: nextMessageDate, secondDate: date) {
                separatorDate = date
            }
        } else if nextMessage == nil {
            separatorDate = message.date
        }
        
        if message.isDeleted() || message.isGroupActionMessage() {
            return (nil, separatorDate)
        }
        
        if message.isPayment() {
            return (MessageTableCellState.BubbleState.Empty, separatorDate)
        }
        
        if message.isInvoice() && !message.isPaid() && !message.isExpired() {
            return (MessageTableCellState.BubbleState.Empty, separatorDate)
        }
        
        let groupingMinutesLimit = 5
        let messageDate = message.date ?? Date(timeIntervalSince1970: 0)
        var date = groupingDate ?? messageDate

        let shouldAvoidGroupingWithPrevious = (previousMessage?.shouldAvoidGrouping() ?? true) || message.shouldAvoidGrouping()
        let isGroupedBySenderWithPrevious = previousMessage?.hasSameSenderThanMessage(message) ?? false
        let isGroupedByDateWithPrevious = messageDate.getMinutesDifference(from: date) < groupingMinutesLimit
        let groupedWithPrevious = (!shouldAvoidGroupingWithPrevious && isGroupedBySenderWithPrevious && isGroupedByDateWithPrevious)

        date = (groupedWithPrevious) ? date : messageDate

        let shouldAvoidGroupingWithNext = (nextMessage?.shouldAvoidGrouping() ?? true) || message.shouldAvoidGrouping()
        let isGroupedBySenderWithNext = nextMessage?.hasSameSenderThanMessage(message) ?? false
        let isGroupedByDateWithNext = (nextMessage != nil) ? (nextMessage?.date?.getMinutesDifference(from: date) ?? 0) < groupingMinutesLimit : false
        let groupedWithNext = (!shouldAvoidGroupingWithNext && isGroupedBySenderWithNext && isGroupedByDateWithNext)

        groupingDate = date
        
        if !groupedWithPrevious && !groupedWithNext {
            return (MessageTableCellState.BubbleState.Isolated, separatorDate)
        } else if groupedWithPrevious && !groupedWithNext {
            return (MessageTableCellState.BubbleState.Last, separatorDate)
        } else if !groupedWithPrevious && groupedWithNext {
            return (MessageTableCellState.BubbleState.First, separatorDate)
        } else if groupedWithPrevious && groupedWithNext {
            return (MessageTableCellState.BubbleState.Middle, separatorDate)
        }
        return (MessageTableCellState.BubbleState.Isolated, separatorDate)
    }
    
    func getReplyingMessagesMapFor(
        messages: [TransactionMessage]
    ) -> [String: TransactionMessage] {
        
        let replayingUUIDs: [String] = messages.map({ $0.replyUUID ?? "" }).filter({ $0.isNotEmpty })
        let replyingMessages = TransactionMessage.getMessagesWith(uuids: replayingUUIDs)
        var replyingMessagesMap: [String: TransactionMessage] = [:]
        
        replyingMessages.map({ ( ($0.uuid ?? "-"), $0) }).forEach {
            replyingMessagesMap[$0.0] = $0.1
        }
        
        return replyingMessagesMap
    }
    
    func getPurchaseMessagesMapFor(
        messages: [TransactionMessage]
    ) -> [String: [Int: TransactionMessage]] {
        
        guard let chat = chat else {
            return [:]
        }
        
        let messageMUIDs: [String] = messages.map({ $0.getMUID() }).filter({ $0.isNotEmpty })
        let purchaseMessages = TransactionMessage.getPurchaseItemsFor(messageMUIDs, on: chat)
        
        var purchaseMessagesMap: [String: [Int: TransactionMessage]] = [:]
        
        for purchaseMessage in purchaseMessages {
            if let muid = purchaseMessage.muid ?? purchaseMessage.originalMuid, muid.isNotEmpty {
                if var _ = purchaseMessagesMap[muid] {
                    purchaseMessagesMap[muid]![purchaseMessage.type] = purchaseMessage
                } else {
                    purchaseMessagesMap[muid] = [purchaseMessage.type: purchaseMessage]
                }
            }
        }
        
        return purchaseMessagesMap
    }
    
    func getBoostMessagesMapFor(
        messages: [TransactionMessage]
    ) -> [String: [TransactionMessage]] {
        
        guard let chat = chat else {
            return [:]
        }
        
        let messageUUIDs: [String] = messages.map({ $0.uuid ?? "" }).filter({ $0.isNotEmpty })
        let boostMessages = TransactionMessage.getBoostMessagesFor(messageUUIDs, on: chat)
        
        var boostMessagesMap: [String: [TransactionMessage]] = [:]
        
        for boostMessage in boostMessages {
            if let replyUUID = boostMessage.replyUUID, replyUUID.isNotEmpty {
                if let map = boostMessagesMap[replyUUID], map.count > 0 {
                    boostMessagesMap[replyUUID]?.append(boostMessage)
                } else {
                    boostMessagesMap[replyUUID] = [boostMessage]
                }
            }
        }
        
        return boostMessagesMap
    }
    
    func getLinkContactsArrayFor(
        messages: [TransactionMessage]
    ) -> [Int: MessageTableCellState.LinkContact] {
        
        var pubkeys: [Int: (String, String?)] = [:]
        
        messages.forEach({
            if $0.bubbleMessageContentString?.hasPubkeyLinks == true {
                pubkeys[$0.id] = (
                    $0.messageContent?.stringFirstPubKey?.pubkeyComponents.0 ?? "",
                    $0.messageContent?.stringFirstPubKey?.pubkeyComponents.1
                )
            }
        })
        
        let contacts = UserContact.getContactsWith(pubkeys: Array(pubkeys.values.map({ $0.0 })))
        var linkContactsMap: [Int: MessageTableCellState.LinkContact] = [:]
        
        pubkeys.forEach({ (key, value) in
            linkContactsMap[key] = MessageTableCellState.LinkContact(
                pubkey: value.0,
                routeHint: value.1,
                contact: contacts.filter({ $0.publicKey == value.0 }).first
            )
        })
        
        return linkContactsMap
    }
    
    
    func getLinkTribesArrayFor(
        messages: [TransactionMessage]
    ) -> [Int: MessageTableCellState.LinkTribe] {
        
        var linksAndUUIDs: [Int: (String, String)] = [:]
        
        messages.forEach({
            if $0.bubbleMessageContentString?.hasTribeLinks == true {
                if let link = $0.messageContent?.stringFirstTribeLink {
                    if let uuid = GroupsManager.sharedInstance.getGroupInfo(query: link)?.uuid {
                        linksAndUUIDs[$0.id] = (link, uuid)
                    }
                }
            }
        })
        
        let chats = Chat.getChatsWith(uuids: linksAndUUIDs.values.map({ $0.1 }))
        
        var linkTribesMap: [Int: MessageTableCellState.LinkTribe] = [:]
        
        linksAndUUIDs.forEach({ (key, value) in
            linkTribesMap[key] = MessageTableCellState.LinkTribe(
                link: value.0,
                uuid: value.1,
                isJoined: chats.filter({ $0.uuid == value.1 }).count > 0
            )
        })
        
        return linkTribesMap
    }
    
    func getLinkWebFor(
        message: TransactionMessage
    ) -> MessageTableCellState.LinkWeb? {
        
        if message.messageContent?.hasLinks == true {
            if let link = message.messageContent?.stringFirstLink {
                return MessageTableCellState.LinkWeb(link: link)
            }
        }
        return nil
    }
}



extension NewChatTableDataSource : NSFetchedResultsControllerDelegate {
    
    func startListeningToResultsController() {
        messagesResultsController?.delegate = self
    }
    
    func stopListeningToResultsController() {
        messagesResultsController?.delegate = nil
    }
    
    func configureResultsController(items: Int) {
        guard let chat = chat else {
            return
        }
        
        if messagesArray.count < messagesCount {
            return
        }
        
        messagesCount = items
        
        let fetchRequest = TransactionMessage.getChatMessagesFetchRequest(
            for: chat,
            with: items
        )

        messagesResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.sharedManager.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        messagesResultsController.delegate = self
        
        do {
            try self.messagesResultsController.performFetch()
        } catch {}
    }
    
    func configureBoostAndPurchaseResultsController() {
        guard let chat = chat else {
            return
        }
        
        if let _ = additionMessagesResultsController {
            return
        }
        
        let fetchRequest = TransactionMessage.getBoostsAndPurchaseMessagesFetchRequestOn(chat: chat)

        additionMessagesResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.sharedManager.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        additionMessagesResultsController.delegate = self
        
        do {
            try self.additionMessagesResultsController.performFetch()
        } catch {}
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        if let resultController = controller as? NSFetchedResultsController<NSManagedObject>,
            let firstSection = resultController.sections?.first {
            
            if controller == messagesResultsController {
                if let messages = firstSection.objects as? [TransactionMessage] {
                    self.messagesArray = messages.filter { $0.isOnlyText() }
                    
                    if !(self.delegate?.isOnStandardMode() ?? true) {
                        return
                    }
                    
                    self.processMessages(messages: self.messagesArray)
                    self.configureBoostAndPurchaseResultsController()
                }
            } else {
                if !(self.delegate?.isOnStandardMode() ?? true) {
                    return
                }
                
                self.processMessages(messages: self.messagesArray)
            }
        }
    }
}
