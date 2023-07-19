//
//  NewChatViewController+PodcastExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 17/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Cocoa

extension NewChatViewController {
    func addPodcastVC(
        deepLinkData: DeeplinkData? = nil
    ) {
        guard let chat = chat else {
            return
        }
        
        guard let contentFeed = chat.contentFeed, contentFeed.isPodcast else {
            return
        }
        
        podcastPlayerVC = NewPodcastPlayerViewController.instantiate(
            chat: chat,
            delegate: self,
            deepLinkData: deepLinkData
        )
//        self.deeplinkData = nil
        
        addChildVC(vc: podcastPlayerVC!)
        
        chatTableDataSource?.updateFrame()
    }
    
    func addChildVC(vc: NSViewController) {
        self.addChildVC(
            child: vc,
            container: podcastPlayerView
        )
        podcastPlayerView.isHidden = false
        
        chatBottomView.updateBottomBarHeight()
//        chatMentionAutocompleteDataSource?.configureCollectionView()
    }
}

extension NewChatViewController : PodcastPlayerViewDelegate {
    func shouldReloadEpisodesTable() {
        
    }
    
    func shouldShareClip(comment: PodcastComment) {
        
    }
    
    func shouldSendBoost(
        message: String,
        amount: Int,
        animation: Bool
    ) -> TransactionMessage? {
        return nil
    }
    
    func shouldSyncPodcast() {
        
    }
}
