//
//  Chat+CoreDataClass.swift
//  
//
//  Created by Tomas Timinskas on 11/05/2020.
//
//

import Foundation
import CoreData
import SwiftyJSON

@objc(Chat)
public class Chat: NSManagedObject {
    
    public var lastMessage : TransactionMessage? = nil
    public var conversationContact : UserContact? = nil
    public var tribeAdmin: UserContact? = nil
    
    public var ongoingMessage : String? = nil
    var tribeInfo: GroupsManager.TribeInfo? = nil
    var aliasesAndPics: [(String, String)] = []
    
    public enum ChatType: Int {
        case conversation = 0
        case privateGroup = 1
        case publicGroup = 2
        
        public init(fromRawValue: Int){
            self = ChatType(rawValue: fromRawValue) ?? .conversation
        }
    }
    
    public enum ChatStatus: Int {
        case approved = 0
        case pending = 1
        case rejected = 2
        
        public init(fromRawValue: Int){
            self = ChatStatus(rawValue: fromRawValue) ?? .approved
        }
    }
    
    public enum NotificationLevel: Int {
        case SeeAll = 0
        case OnlyMentions = 1
        case MuteChat = 2
        
        public init(fromRawValue: Int){
            self = NotificationLevel(rawValue: fromRawValue) ?? .SeeAll
        }
    }
    
    static func getChatInstance(id: Int, managedContext: NSManagedObjectContext) -> Chat {
        if let ch = Chat.getChatWith(id: id) {
            return ch
        } else {
            return Chat(context: managedContext) as Chat
        }
    }
    
    static func insertChat(chat: JSON) -> Chat? {
        if let id = chat.getJSONId() {
            let name = chat["name"].string ?? ""
            let photoUrl = chat["photo_url"].string ?? ""
            let uuid = chat["uuid"].stringValue
            let type = chat["type"].intValue
            let muted = chat["is_muted"].boolValue
            let seen = chat["seen"].boolValue
            let host = chat["host"].stringValue
            let groupKey = chat["group_key"].stringValue
            let ownerPubkey = chat["owner_pubkey"].stringValue
            let pricePerMessage = chat["price_per_message"].intValue
            let escrowAmount = chat["escrow_amount"].intValue
            let myAlias = chat["my_alias"].string
            let myPhotoUrl = chat["my_photo_url"].string
            let metaData = chat["meta"].string
            let status = chat["status"].intValue
            let pinnedMessageUUID = chat["pin"].string
            let date = Date.getDateFromString(dateString: chat["created_at"].stringValue) ?? Date()
            
            var notify = muted ? NotificationLevel.MuteChat.rawValue : NotificationLevel.SeeAll.rawValue
            
            if let n = chat["notify"].int {
                notify = n
            }
            
            let contactIds = chat["contact_ids"].arrayObject as? [NSNumber] ?? []
            let pendingContactIds = chat["pending_contact_ids"].arrayObject as? [NSNumber] ?? []
            
            let chat = Chat.createObject(id: id,
                                         name: name,
                                         photoUrl: photoUrl,
                                         uuid: uuid,
                                         type: type,
                                         status: status,
                                         muted: muted,
                                         seen: seen,
                                         host: host,
                                         groupKey: groupKey,
                                         ownerPubkey:ownerPubkey,
                                         pricePerMessage: pricePerMessage,
                                         escrowAmount: escrowAmount,
                                         myAlias: myAlias,
                                         myPhotoUrl: myPhotoUrl,
                                         notify: notify,
                                         pinnedMessageUUID: pinnedMessageUUID,
                                         contactIds: contactIds,
                                         pendingContactIds: pendingContactIds,
                                         date: date,
                                         metaData: metaData)
            
            return chat
        }
        return nil
    }
    
    static func createObject(id: Int,
                             name: String,
                             photoUrl: String?,
                             uuid: String?,
                             type: Int,
                             status: Int,
                             muted: Bool,
                             seen: Bool,
                             host: String?,
                             groupKey: String?,
                             ownerPubkey: String?,
                             pricePerMessage: Int,
                             escrowAmount: Int,
                             myAlias: String?,
                             myPhotoUrl: String?,
                             notify: Int,
                             pinnedMessageUUID: String?,
                             contactIds: [NSNumber],
                             pendingContactIds: [NSNumber],
                             date: Date,
                             metaData: String?) -> Chat? {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let chat = getChatInstance(id: id, managedContext: managedContext)
        chat.id = id
        chat.name = name
        chat.photoUrl = photoUrl
        chat.uuid = uuid
        chat.type = type
        chat.status = status
        chat.muted = muted
        chat.seen = seen
        chat.host = host
        chat.groupKey = groupKey
        chat.ownerPubkey = ownerPubkey
        chat.createdAt = date
        chat.myAlias = myAlias
        chat.myPhotoUrl = myPhotoUrl
        chat.notify = notify
        chat.contactIds = contactIds
        chat.pendingContactIds = pendingContactIds
        chat.subscription = chat.getContact()?.getCurrentSubscription()
        
        if chat.isMyPublicGroup() {
            chat.pricePerMessage = NSDecimalNumber(integerLiteral: pricePerMessage)
            chat.escrowAmount = NSDecimalNumber(integerLiteral: escrowAmount)
            chat.pinnedMessageUUID = pinnedMessageUUID
        }
        
        return chat
    }
    
    func getContactIdsArray() -> [Int] {
        var ids:[Int] = []
        for contactId in self.contactIds {
            ids.append(contactId.intValue)
        }
        return ids
    }
    
    func getPendingContactIdsArray() -> [Int] {
        var ids:[Int] = []
        for contactId in self.pendingContactIds {
            ids.append(contactId.intValue)
        }
        return ids
    }
    
    func isMuted() -> Bool {
        return self.notify == NotificationLevel.MuteChat.rawValue
    }
    
    public func isOnlyMentions() -> Bool {
        return self.notify == NotificationLevel.OnlyMentions.rawValue
    }
    
    func willNotifyOnlyMentions() -> Bool {
        return self.notify == NotificationLevel.OnlyMentions.rawValue
    }
    
    func isStatusPending() -> Bool {
        return self.status == ChatStatus.pending.rawValue
    }
    
    func isStatusRejected() -> Bool {
        return self.status == ChatStatus.rejected.rawValue
    }
    
    func isStatusApproved() -> Bool {
        return self.status == ChatStatus.approved.rawValue
    }
    
    static func getAll() -> [Chat] {
        var predicate: NSPredicate! = nil
        
        if GroupsPinManager.sharedInstance.isStandardPIN {
            predicate = NSPredicate(format: "pin == null")
        } else {
            let currentPin = GroupsPinManager.sharedInstance.currentPin
            predicate = NSPredicate(format: "pin = %@", currentPin)
        }
        
        let chats:[Chat] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: [], entityName: "Chat")
        return chats
    }
    
    public static func getAllConversations() -> [Chat] {
        let predicate = NSPredicate(format: "type = %d", Chat.ChatType.conversation.rawValue)
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let chats:[Chat] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: sortDescriptors, entityName: "Chat")
        return chats
    }
    
    public static func getAllExcluding(ids: [Int]) -> [Chat] {
        var predicate: NSPredicate! = nil
        
        if GroupsPinManager.sharedInstance.isStandardPIN {
            predicate = NSPredicate(format: "NOT (id IN %@) AND pin == null", ids)
        } else {
            let currentPin = GroupsPinManager.sharedInstance.currentPin
            predicate = NSPredicate(format: "NOT (id IN %@) AND pin = %@", ids, currentPin)
        }
        
        let chats: [Chat] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: [], entityName: "Chat")
        return chats
    }
    
    static func getAllGroups() -> [Chat] {
        var predicate: NSPredicate! = nil
        
        if GroupsPinManager.sharedInstance.isStandardPIN {
            predicate = NSPredicate(format: "type IN %@ AND pin == null", [Chat.ChatType.privateGroup.rawValue, Chat.ChatType.publicGroup.rawValue])
        } else {
            let currentPin = GroupsPinManager.sharedInstance.currentPin
            predicate = NSPredicate(format: "type IN %@ AND pin = %@", [Chat.ChatType.privateGroup.rawValue, Chat.ChatType.publicGroup.rawValue], currentPin)
        }
        
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let chats:[Chat] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: sortDescriptors, entityName: "Chat")
        return chats
    }
    
    public static func getPrivateChats() -> [Chat] {
        let predicate = NSPredicate(format: "pin != null")
        let chats: [Chat] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: [], entityName: "Chat")
        return chats
    }
    
    static func getOrCreateChat(chat: JSON) -> Chat? {
        let chatId = chat["id"].intValue
        if let chat = Chat.getChatWith(id: chatId) {
            return chat
        }
        return Chat.insertChat(chat: chat)
    }
    
    static func getChatWith(id: Int, managedContext: NSManagedObjectContext? = nil) -> Chat? {
        let predicate = NSPredicate(format: "id == %d", id)
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let chat:Chat? = CoreDataManager.sharedManager.getObjectOfTypeWith(predicate: predicate, sortDescriptors: sortDescriptors, entityName: "Chat", managedContext: managedContext)
        return chat
    }
    
    static func getChatWith(uuid: String) -> Chat? {
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let chat: Chat? = CoreDataManager.sharedManager.getObjectOfTypeWith(predicate: predicate, sortDescriptors: sortDescriptors, entityName: "Chat")
        
        return chat
    }
    
    func processAliasesFrom(messages: [TransactionMessage]) {
        var aliases: [String] = []
        
        aliasesAndPics = []
        
        for message in messages {
            if let alias = message.senderAlias, alias.isEmpty == false {
                if !aliases.contains(alias) {
                    aliasesAndPics.append(
                        (alias, message.senderPic ?? "")
                    )
                    aliases.append(alias)
                }
            }
        }
    }
    
    func findImageURLByAlias(alias:String)->URL?{
        let allMessages = self.getAllMessages()
        guard let picURLString = allMessages.first(where: {$0.senderAlias == alias})?.senderPic else { return nil }
        return URL(string: picURLString)
    }
    
    func getAllMessages(
        limit: Int? = 100,
        messagesIdsToExclude: [Int] = [],
        lastMessage: TransactionMessage? = nil,
        firstMessage: TransactionMessage? = nil
    ) -> [TransactionMessage] {
        return TransactionMessage.getAllMessagesFor(
            chat: self,
            limit: limit,
            messagesIdsToExclude: messagesIdsToExclude,
            lastMessage: lastMessage,
            firstMessage: firstMessage
        )
    }
    
    func getAllMessagesCount() -> Int {
        return TransactionMessage.getAllMessagesCountFor(chat: self)
    }
    
    func getNewMessagesCount(lastMessageId: Int? = nil) -> Int {
        guard let lastMessageId = lastMessageId else {
            return 0
        }
        return TransactionMessage.getNewMessagesCountFor(chat: self, lastMessageId: lastMessageId)
    }
    
    func setChatMessagesAsSeen(shouldSync: Bool = true, shouldSave: Bool = true, forceSeen: Bool = false) {
        if NSApplication.shared.isActive || forceSeen {
            self.seen = true
            self.unseenMessagesCount = 0
            self.unseenMentionsCount = 0
            
            let receivedUnseenMessages = self.getReceivedUnseenMessages()
            if receivedUnseenMessages.count > 0 {
                for m in receivedUnseenMessages {
                    m.seen = true
                }
            }
            
            if shouldSave {
                CoreDataManager.sharedManager.saveContext()
            }
            
            if shouldSync && receivedUnseenMessages.count > 0 {
                API.sharedInstance.setChatMessagesAsSeen(chatId: self.id, callback: { _ in })
            }
        }
        
        DispatchQueue.main.async {
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.setBadge(count: TransactionMessage.getReceivedUnseenMessagesCount())
            }
        }
    }
    
    func getGroupEncrypted(text: String) -> String {
        if let groupKey = groupKey {
            let encryptedM = EncryptionManager.sharedInstance.encryptMessage(message: text, groupKey: groupKey)
            return encryptedM.1
        }
        return text
    }
    
    func getReceivedUnseenMessages() -> [TransactionMessage] {
        let userId = UserData.sharedInstance.getUserId()
        let predicate = NSPredicate(format: "senderId != %d AND chat == %@ AND seen == %@", userId, self, NSNumber(booleanLiteral: false))
        let messages: [TransactionMessage] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: [], entityName: "TransactionMessage")
        return messages
    }
    
    var unseenMessagesCount: Int = 0
    
    func getReceivedUnseenMessagesCount() -> Int {
        if unseenMessagesCount == 0 {
            calculateUnseenMessagesCount()
        }
        return unseenMessagesCount
    }
    
    var unseenMentionsCount: Int = 0
    
    func getReceivedUnseenMentionsCount() -> Int {
        if unseenMentionsCount == 0 {
            calculateUnseenMentionsCount()
        }
        return unseenMentionsCount
    }
    
    func calculateBadge() {
        calculateUnseenMessagesCount()
        calculateUnseenMentionsCount()
    }
    
    func calculateUnseenMessagesCount() {
        let userId = UserData.sharedInstance.getUserId()
        let predicate = NSPredicate(format: "senderId != %d AND chat == %@ AND seen == %@ && chat.seen == %@", userId, self, NSNumber(booleanLiteral: false), NSNumber(booleanLiteral: false))
        unseenMessagesCount = CoreDataManager.sharedManager.getObjectsCountOfTypeWith(predicate: predicate, entityName: "TransactionMessage")
    }
    
    func calculateUnseenMentionsCount() {
        let userId = UserData.sharedInstance.getUserId()
        let predicate = NSPredicate(
            format: "senderId != %d AND chat == %@ AND seen == %@ && push == %@ && chat.seen == %@",
            userId, self,
            NSNumber(booleanLiteral: false),
            NSNumber(booleanLiteral: true),
            NSNumber(booleanLiteral: false)
        )
        unseenMentionsCount = CoreDataManager.sharedManager.getObjectsCountOfTypeWith(predicate: predicate, entityName: "TransactionMessage")
    }
    
    func getLastMessageToShow() -> TransactionMessage? {
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "id", ascending: false)]
        let predicate = NSPredicate(format: "chat == %@ AND type != %d", self, TransactionMessage.TransactionMessageType.repayment.rawValue)
        let messages: [TransactionMessage] = CoreDataManager.sharedManager.getObjectsOfTypeWith(predicate: predicate, sortDescriptors: sortDescriptors, entityName: "TransactionMessage", fetchLimit: 1)
        return messages.first
    }
    
    public static func updateLastMessageForChats(_ chatIds: [Int]) {
        for id in chatIds {
            if let chat = Chat.getChatWith(id: id) {
                chat.calculateBadge()
            }
        }
    }
    
    public func updateLastMessage() {
        if lastMessage?.id ?? 0 <= 0 {
            lastMessage = getLastMessageToShow()
            calculateBadge()
        }
    }
    
    public func setLastMessage(_ message: TransactionMessage) {
        guard let lastM = lastMessage else {
            lastMessage = message
            calculateBadge()
            return
        }
        
        if (lastM.messageDate < message.messageDate) {
            lastMessage = message
            calculateBadge()
        }
    }
    
    func getContact() -> UserContact? {
        if self.type == Chat.ChatType.conversation.rawValue {
            let contacts = getContacts(includeOwner: false)
            return contacts.first
        }
        return nil
    }
    
    func getAdmin() -> UserContact? {
        let contacts = getContacts(includeOwner: false)
        if self.type == Chat.ChatType.publicGroup.rawValue && contacts.count > 0 {
            return contacts.first
        }
        return nil
    }
    
    func getContactForRouteCheck() -> UserContact? {
        if let contact = getContact() {
            return contact
        }
        if let admin = getAdmin() {
            return admin
        }
        return nil
    }
    
    func getPendingContacts() -> [UserContact] {
        let ids:[Int] = self.getPendingContactIdsArray()
        let contacts: [UserContact] = UserContact.getContactsWith(ids: ids, includeOwner: false, ownerAtEnd: false)
        return contacts
    }
    
    func getContacts(includeOwner: Bool = true, ownerAtEnd: Bool = false) -> [UserContact] {
        let ids:[Int] = self.getContactIdsArray()
        let contacts: [UserContact] = UserContact.getContactsWith(ids: ids, includeOwner: includeOwner, ownerAtEnd: ownerAtEnd)
        return contacts
    }
    
    func isPendingMember(id: Int) -> Bool {
        return getPendingContactIdsArray().contains(id)
    }
    
    func isActiveMember(id: Int) -> Bool {
        return getContactIdsArray().contains(id)
    }
    
    func updateTribeInfo(completion: @escaping () -> ()) {
        if
            let host = host,
            let uuid = uuid,
            host.isEmpty == false,
            isPublicGroup()
        {
            API.sharedInstance.getTribeInfo(
                host: host,
                uuid: uuid,
                callback: { chatJson in
                    self.tribeInfo = GroupsManager.sharedInstance.getTribesInfoFrom(json: chatJson)
                    self.updateChatFromTribesInfo()
                    
                    if let feedUrl = self.tribeInfo?.feedUrl, !feedUrl.isEmpty {
                        ContentFeed.fetchChatFeedContentInBackground(feedUrl: feedUrl, chatId: self.id) { feedId in
                            if let feedId = feedId {
                                self.contentFeed = ContentFeed.getFeedWith(feedId: feedId)
                                self.saveChat()
                                
                                FeedsManager.sharedInstance.restoreContentFeedStatusFor(feedId: feedId, completionCallback: {
                                    completion()
                                })
                                return
                            }
                            completion()
                        }
                        return
                    } else if let existingFeed = self.contentFeed {
                        ContentFeed.deleteFeedWith(feedId: existingFeed.feedID)
                    }
                    completion()
                },
                errorCallback: {
                    completion()
                }
            )
        }
    }
    
    
    
    func updateChatFromTribesInfo() {
        if self.isMyPublicGroup() {
            self.pinnedMessageUUID = self.tribeInfo?.pin ?? nil
            self.saveChat()
            return
        }
        
        self.escrowAmount = NSDecimalNumber(
            integerLiteral: self.tribeInfo?.amountToStake ?? (self.escrowAmount?.intValue ?? 0)
        )
        self.pricePerMessage = NSDecimalNumber(
            integerLiteral: self.tribeInfo?.pricePerMessage ?? (self.pricePerMessage?.intValue ?? 0)
        )
        self.pinnedMessageUUID = self.tribeInfo?.pin ?? nil
        self.name = (self.tribeInfo?.name?.isEmpty ?? true) ? self.name : self.tribeInfo!.name
        
        let tribeImage = self.tribeInfo?.img ?? self.photoUrl
        
        if self.photoUrl != tribeImage {
            self.photoUrl = tribeImage
            NotificationCenter.default.post(name: .onTribeImageChanged, object: nil, userInfo: nil)
        }
        
        self.saveChat()
        self.syncTribeWithServer()
        self.checkForDeletedTribe()
    }
    
    func checkForDeletedTribe() {
        if let tribeInfo = self.tribeInfo, tribeInfo.deleted {
            if let lastMessage = self.getAllMessages(limit: 1).last, lastMessage.type != TransactionMessage.TransactionMessageType.groupDelete.rawValue {
                AlertHelper.showAlert(title: "deleted.tribe.title".localized, message: "deleted.tribe.description".localized)
            }
        }
    }
    
    func getAppUrl() -> String? {
        if let tribeInfo = self.tribeInfo, let appUrl = tribeInfo.appUrl, !appUrl.isEmpty {
            return appUrl
        }
        return nil
    }
    
    func getFeedUrl() -> String? {
        if let tribeInfo = self.tribeInfo, let feedUrl = tribeInfo.feedUrl, !feedUrl.isEmpty {
            return feedUrl
        }
        return nil
    }
    
    func getWebAppIdentifier() -> String {
        return "web-app-\(self.id)"
    }
    
    func updateWebAppLastDate() {
        self.webAppLastDate = Date()
        NotificationCenter.default.post(name: .shouldReloadChatsList, object: nil)
    }
    
    func hasWebApp() -> Bool {
        return tribeInfo?.appUrl != nil && tribeInfo?.appUrl?.isEmpty == false
    }
    
    func syncTribeWithServer() {
        DispatchQueue.global().async {
            let params: [String: AnyObject] = ["name" : self.name as AnyObject, "img": self.photoUrl as AnyObject]
            API.sharedInstance.editGroup(id: self.id, params: params, callback: { _ in }, errorCallback: {})
        }
    }
    
    func setOngoingMessage(text: String?) {
        self.ongoingMessage = text
    }
    
    func resetOngoingMessage() {
        self.ongoingMessage = nil
    }
    
    func shouldShowPrice() -> Bool {
        return isPublicGroup()
    }
    
    func getTribePrices() -> (Int, Int) {
        return (self.pricePerMessage?.intValue ?? 0, self.escrowAmount?.intValue ?? 0)
    }
    
    func isGroup() -> Bool {
        return type == Chat.ChatType.privateGroup.rawValue || type == Chat.ChatType.publicGroup.rawValue
    }
    
    func isPrivateGroup() -> Bool {
        return type == Chat.ChatType.privateGroup.rawValue
    }
    
    func isPublicGroup() -> Bool {
        return type == Chat.ChatType.publicGroup.rawValue
    }
    
    func isConversation() -> Bool {
        return type == Chat.ChatType.conversation.rawValue
    }
    
    func isMyPublicGroup() -> Bool {
        return isPublicGroup() && ownerPubkey == UserData.sharedInstance.getUserPubKey()
    }
    
    func isEncrypted() -> Bool {
        if isPrivateGroup() {
            return true
        } else if isPublicGroup() {
            if let _ = groupKey {
                return true
            }
            return false
        } else if let contact = getContact() {
            return contact.hasEncryptionKey()
        }
        return false
    }
    
    func removedFromGroup() -> Bool {
        let predicate = NSPredicate(format: "chat == %@ AND type == %d", self, TransactionMessage.TransactionMessageType.groupKick.rawValue)
        let messagesCount = CoreDataManager.sharedManager.getObjectsCountOfTypeWith(predicate: predicate, entityName: "TransactionMessage")
        return messagesCount > 0
    }
    
    func getActionsMenuOptions() -> [(tag: Int, icon: String?, iconImage: String?, label: String)] {
        var options = [(tag: Int, icon: String?, iconImage: String?, label: String)]()
        
        let isPublicGroup = self.isPublicGroup()
        let isMyPublicGroup = self.isMyPublicGroup()
        
        if isPublicGroup {
            if isMyPublicGroup {
                options.append((MessageOptionsHelper.ChatActionsItem.Share.rawValue, "share", nil, "share.group".localized))
                options.append((MessageOptionsHelper.ChatActionsItem.Edit.rawValue, "edit", nil, "edit.tribe".localized))
                options.append((MessageOptionsHelper.ChatActionsItem.Delete.rawValue, "delete", nil, "delete.tribe".localized))
            } else {
                if self.removedFromGroup() {
                    options.append((MessageOptionsHelper.ChatActionsItem.Delete.rawValue, "delete", nil, "delete.tribe".localized))
                } else {
                    options.append((MessageOptionsHelper.ChatActionsItem.Exit.rawValue, nil, "exitTribeIcon", "exit.tribe".localized))
                }
            }
        } else {
            options.append((MessageOptionsHelper.ChatActionsItem.Exit.rawValue, nil, "exitTribeIcon", "exit.group".localized))
        }
        
        return options
    }
    
    func getJoinChatLink() -> String {
        return "sphinx.chat://?action=tribe&uuid=\(self.uuid ?? "")&host=\(self.host ?? "")"
    }
    
    func getPodcastFeed() -> PodcastFeed? {
        if let contentFeed = self.contentFeed {
            return PodcastFeed.convertFrom(contentFeed: contentFeed)
        }
        return nil
    }
    
    func saveChat() {
        CoreDataManager.sharedManager.saveContext()
    }
}
