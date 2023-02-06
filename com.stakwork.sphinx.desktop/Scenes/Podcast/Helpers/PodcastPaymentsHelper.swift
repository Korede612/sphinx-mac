//
//  PodcastPaymentsHelper.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 22/10/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import Foundation

class PodcastPaymentsHelper {
    public static func getSatsEarnedFor(_ feedId: Int) -> Int {
        let pmts = TransactionMessage.getPaymentsFor(feedId: feedId)
        var satsEarned = 0
        
        for pmt in pmts {
            satsEarned += (pmt.amount?.intValue ?? 0)
        }
        return satsEarned
    }
    
    func processPaymentsFor(podcastFeed: OldPodcastFeed?,
                            boostAmount: Int? = nil,
                            itemId: String,
                            currentTime: Int,
                            clipSenderPubKey: String? = nil,
                            uuid: String? = nil) {
        
        
        let suggestedAmount = getPodcastAmount(podcastFeed)
        let satsAmt = boostAmount ?? suggestedAmount
        let myPubKey = UserData.sharedInstance.getUserPubKey()
        var destinations = podcastFeed?.destinations ?? []
        var shouldUpdateMeta = true
        
        if let clipSenderPubKey = clipSenderPubKey, clipSenderPubKey != myPubKey {
            shouldUpdateMeta = false
            let clipSenderDestination = OldPodcastDestination(address: clipSenderPubKey, split: 1, type: "node")
            destinations.append(clipSenderDestination)
        }
        
        if let _ = boostAmount {
            shouldUpdateMeta = false
        }
        
        if let chatId = podcastFeed?.chatId, let podcastId = podcastFeed?.id, destinations.count > 0 {
            streamSats(podcastId: podcastId, podcatsDestinations: destinations, updateMeta: shouldUpdateMeta, amount: satsAmt, chatId: chatId, itemId: itemId, currentTime: currentTime, uuid: uuid)
        }
    }
    
    func getPodcastAmount(_ podcastFeed: OldPodcastFeed?) -> Int {
        var suggestedAmount = (podcastFeed?.model?.suggestedSats) ?? 5
        
        if let chatId = podcastFeed?.chatId, let savedAmount = UserDefaults.standard.value(forKey: "podcast-sats-\(chatId)") as? Int, chatId > 0 {
            suggestedAmount = savedAmount
        }
        
        return suggestedAmount
    }
    
    func getAmountFrom(sats: Double, split: Double) -> Int {
        let desinationAmt = Int(round(sats * (split/100)))
        return desinationAmt < 1 ? 1 : desinationAmt
    }
    
    func getClipSenderAmt(sats: Double) -> Int {
        let amt = Int(round(sats * 0.01))
        return amt < 1 ? 1 : amt
    }
    
    func streamSats(podcastId: Int,
                    podcatsDestinations: [OldPodcastDestination],
                    updateMeta: Bool,
                    amount: Int,
                    chatId: Int,
                    itemId: String,
                    currentTime: Int,
                    uuid: String? = nil) {
        
        var destinations = [[String: AnyObject]]()
        
        for d in podcatsDestinations {
            let destinationParams: [String: AnyObject] = ["address": (d.address ?? "") as AnyObject, "split": (d.split ?? 0) as AnyObject, "type": (d.type ?? "") as AnyObject]
            destinations.append(destinationParams)
        }
        
        var params: [String: AnyObject] = ["destinations": destinations as AnyObject, "amount": amount as AnyObject, "chat_id": chatId as AnyObject]
        params["update_meta"] = updateMeta as AnyObject
        
        if let uuid = uuid, !uuid.isEmpty {
            params["text"] = "{\"feedID\":\(podcastId),\"itemID\":\(itemId),\"ts\":\(currentTime),\"uuid\":\"\(uuid)\"}" as AnyObject
        } else {
            params["text"] = "{\"feedID\":\(podcastId),\"itemID\":\(itemId),\"ts\":\(currentTime)}" as AnyObject
        }
        
        API.sharedInstance.streamSats(params: params, callback: {}, errorCallback: {})
    }
}
