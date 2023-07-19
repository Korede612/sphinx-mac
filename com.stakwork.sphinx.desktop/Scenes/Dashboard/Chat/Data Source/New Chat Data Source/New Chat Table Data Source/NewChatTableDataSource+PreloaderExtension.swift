//
//  NewChatTableDataSource+PreloaderExtension.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 18/07/2023.
//  Copyright © 2023 Tomas Timinskas. All rights reserved.
//

import Foundation

extension NewChatTableDataSource {
    func restorePreloadedMessages() {
        guard let chat = chat else {
            return
        }
        
        if let messagesStateArray = preloaderHelper.getMessageStateArray(for: chat.id) {
            messageTableCellStateArray = messagesStateArray
            updateSnapshot()
        }
    }
    
    func saveMessagesToPreloader() {
        let firstVisibleItem = collectionView.indexPathsForVisibleItems().sorted().first?.item ?? 0
        
        guard let chat = chat, collectionView.numberOfSections > 0 && firstVisibleItem > 0 else {
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        preloaderHelper.add(
            messageStateArray: messageTableCellStateArray.endSubarray(size: (numberOfItems - firstVisibleItem) + 10),
            for: chat.id
        )
    }
    
    func saveSnapshotCurrentState() {
//        guard let chat = chat else {
//            return
//        }
//
//        if let firstVisibleRow = collectionView.indexPathsForVisibleItems().sorted().first {
//
//            let cellRectInTable = collectionView.rectForRow(at: firstVisibleRow)
//            let cellOffset = tableView.convert(cellRectInTable.origin, to: bottomView)
//
//            preloaderHelper.save(
//                bottomFirstVisibleRow: firstVisibleRow.row,
//                bottomFirstVisibleRowOffset: cellOffset.y,
//                bottomFirstVisibleRowUniqueID: dataSource.snapshot().itemIdentifiers.first?.getUniqueIdentifier(),
//                numberOfItems: preloaderHelper.getPreloadedMessagesCount(for: chat.id),
//                for: chat.id
//            )
//        }
//
        saveMessagesToPreloader()
    }
    
    func restoreScrollLastPosition() {
        let collectionViewContentSize = collectionView.collectionViewLayout?.collectionViewContentSize.height ?? 0
        scrollViewDesiredOffset = collectionViewContentSize - collectionViewScroll.frame.height + collectionViewScroll.contentInsets.bottom
        collectionViewScroll.documentYOffset = scrollViewDesiredOffset ?? 0
        
//        guard let chat = chat else {
//            return
//        }
//        
//        if let scrollState = preloaderHelper.getScrollState(
//            for: chat.id,
//            with: dataSource.snapshot().itemIdentifiers
//        ) {
//            let row = scrollState.bottomFirstVisibleRow
//            let offset = scrollState.bottomFirstVisibleRowOffset
//            
//            if scrollState.shouldAdjustScroll && !loadingMoreItems {
//                
//                if tableView.numberOfRows(inSection: 0) > row {
//                    
//                    tableView.scrollToRow(
//                        at: IndexPath(row: row, section: 0),
//                        at: .top,
//                        animated: false
//                    )
//                    
//                    tableView.contentOffset.y = tableView.contentOffset.y + (offset + tableView.contentInset.top)
//                }
//            }
//            
//            if scrollState.shouldPreventSetMessagesAsSeen {
//                return
//            }
//        }
//        
//        if tableView.contentOffset.y <= Constants.kChatTableContentInset {
//            delegate?.didScrollToBottom()
//        }
    }
}
