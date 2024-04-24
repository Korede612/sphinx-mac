//
//  NewChatHeaderView.swift
//  Sphinx
//
//  Created by Oko-osi Korede on 23/04/2024.
//  Copyright © 2024 Tomas Timinskas. All rights reserved.
//

import Cocoa

protocol NewChatHeaderViewDelegate: AnyObject {
    func refreshTapped()
    func menuTapped(_ frame: CGRect)
}

class NewChatHeaderView: NSView, LoadableNib {
    
    weak var delegate: NewChatHeaderViewDelegate?
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var profileImageView: AspectFillNSImageView!
    
    @IBOutlet weak var balanceLabel: NSTextField!
    @IBOutlet weak var balanceUnitLabel: NSTextField!
    
    @IBOutlet weak var healthCheckView: HealthCheckView!
    
    @IBOutlet weak var reloadButton: CustomButton!
    @IBOutlet weak var menuButton: CustomButton!
    
    @IBOutlet weak var loadingWheel: NSProgressIndicator!
    @IBOutlet weak var loadingWheelContainer: NSView!
    
    var walletBalanceService = WalletBalanceService()
    
    let profile = UserContact.getOwner()
    
    var loading = false {
        didSet {
            healthCheckView.isHidden = loading
            LoadingWheelHelper.toggleLoadingWheel(loading: loading, loadingWheel: loadingWheel, color: NSColor.white, controls: [])
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
        setup()
        setupViews()
        loading = true
        healthCheckView.delegate = self
        configureProfile()
        listenForNotifications()
    }
    
    private func setup() {
        reloadButton.cursor = .pointingHand
        menuButton.cursor = .pointingHand
    }
    
    func configureProfile() {
        walletBalanceService.updateBalance(labels: [balanceLabel])
        balanceUnitLabel.stringValue = "sat"
        
        if let profile = profile {
            if let imageUrl = profile.avatarUrl?.trim(), imageUrl != "" {
                MediaLoader.loadAvatarImage(url: imageUrl, objectId: profile.id, completion: { (image, id) in
                    guard let image = image else {
                        return
                    }
                    self.profileImageView.bordered = false
                    self.profileImageView.image = image
                })
            } else {
                profileImageView.image = NSImage(named: "profileAvatar")
            }
            
            let nickname = profile.nickname ?? ""
            nameLabel.stringValue = nickname.getNameStyleString()
        }
    }
    
    func setupViews() {
        profileImageView.wantsLayer = true
        profileImageView.rounded = true
        profileImageView.layer?.cornerRadius = profileImageView.frame.height / 2
    }
    
    @IBAction func refreshButtonTapped(_ sender: NSButton) {
        delegate?.refreshTapped()
        configureProfile()
    }
    
    @IBAction func menuButtonTapped(_ sender: NSButton) {
        delegate?.menuTapped(menuButton.frame)
    }
    
    func shouldCheckAppVersions() {
//        API.sharedInstance.getAppVersions(callback: { v in
//            let version = Int(v) ?? 0
//            let appVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0
//
//            self.upgradeButton.isHidden = version <= appVersion
//            self.upgradeBox.isHidden = version <= appVersion
//        })
    }
    
    func listenForNotifications() {
        healthCheckView.listenForEvents()
        
        NotificationCenter.default.addObserver(
            forName: .onBalanceDidChange,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] (n: Notification) in
                self?.updateBalance()
        }
    }
    
    func updateBalance() {
        balanceUnitLabel.stringValue = "sat"
        walletBalanceService.updateBalance(labels: [balanceLabel])
    }
}

extension NewChatHeaderView : HealthCheckDelegate {
    func shouldShowBubbleWith(_ message: String) {
        NewMessageBubbleHelper().showGenericMessageView(text:message, in: self.contentView, position: .Top, delay: 3)
    }
}
