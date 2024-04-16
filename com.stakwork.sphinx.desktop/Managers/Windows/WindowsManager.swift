//
//  WindowsManager.swift
//  com.stakwork.sphinx.desktop
//
//  Created by Tomas Timinskas on 12/05/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import Cocoa

class WindowsManager {
    
    class var sharedInstance : WindowsManager {
        struct Static {
            static let instance = WindowsManager()
        }
        return Static.instance
    }
    
    func saveWindowState() {
        if let keyWindow = NSApplication.shared.keyWindow {
            //            let menuCollapsed = (keyWindow.contentViewController as? DashboardViewController)?.isLeftMenuCollapsed() ?? false
            let menuCollapsed = false
            let windowState = WindowState(frame: keyWindow.frame, minSize: keyWindow.minSize, menuCollapsed: menuCollapsed)
            
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(windowState) {
                UserDefaults.Keys.windowRect.set(encoded)
            }
        }
    }
    
    func getWindowState() -> WindowState {
        var windowState: WindowState? = nil
        
        if let data: Data = UserDefaults.Keys.windowRect.get() {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(WindowState.self, from: data) {
                windowState = decoded
            }
        }
        
        if let windowState = windowState {
            return windowState
        }
        
        let isUserLogged = UserData.sharedInstance.isUserLogged()
        let initialSize = isUserLogged ? CGSize(width: 1100, height: 850) : CGSize(width: 800, height: 500)
        let minSize = isUserLogged ? CGSize(width: 950, height: 735) : CGSize(width: 800, height: 500)
        let initialFrame = getCenteredFrameFor(size: initialSize)
        
        return WindowState(frame: initialFrame, minSize: minSize, menuCollapsed: false)
    }
    
    func getCenteredFrameFor(size: CGSize) -> CGRect {
        let mainScreen = NSScreen.main
        let centerPoint = CGPoint(x: ((mainScreen?.frame.width ?? 1000) / 2) - (size.width / 2), y: ((mainScreen?.frame.height ?? 735) / 2) - (size.height / 2))
        let initialFrame = CGRect(x: centerPoint.x, y: centerPoint.y, width: size.width, height: size.height)
        return initialFrame
    }
    
    func getWindowStateFor(size: CGSize) -> WindowState {
        let mainScreen = NSScreen.main
        let centerPoint = CGPoint(x: ((mainScreen?.frame.width ?? 1000) / 2) - (size.width / 2), y: ((mainScreen?.frame.height ?? 735) / 2) - (size.height / 2))
        let initialFrame = CGRect(x: centerPoint.x, y: centerPoint.y, width: size.width, height: size.height)
        return WindowState(frame: initialFrame, minSize: size, menuCollapsed: false)
    }
    
    func showNewWindow(
        with title: String,
        size: CGSize,
        minSize: CGSize? = nil,
        centeredIn w: NSWindow? = nil,
        position: CGPoint? = nil,
        identifier: String? = nil,
        chatIdentifier: Int? = nil,
        styleMask: NSWindow.StyleMask = [.closable, .titled, .resizable],
        contentVC: NSViewController,
        shouldClose: Bool = false
    ) {
        
        if let identifier = identifier {
            if !shouldClose && bringToFrontIfExists(identifier: identifier, chatIdentifier: chatIdentifier) {
                return
            }
            closeIfExists(identifier: identifier)
        }
        
        let newWindow = TaggedWindow(contentRect: .init(origin: .zero, size: size),
                                     styleMask: styleMask,
                                     backing: .buffered,
                                     defer: false)
        
        newWindow.title = title
        newWindow.minSize = minSize ?? size
        newWindow.isOpaque = false
        newWindow.isMovableByWindowBackground = false
        newWindow.contentViewController = contentVC
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.isReleasedWhenClosed = false
        newWindow.windowIdentifier = identifier
        newWindow.chatIdentifier = chatIdentifier
        newWindow.backgroundColor = NSColor.Sphinx.Body
        
        if let w = w {
            let position = CGPoint(x: w.frame.origin.x + (w.frame.width - size.width) / 2, y: w.frame.origin.y + (w.frame.height - size.height) / 2)
            newWindow.setFrame(.init(origin: position, size: size), display: true)
        } else if let position = position {
            newWindow.setFrame(.init(origin: position, size: size), display: true)
        } else {
            newWindow.center()
        }
    }
    
    func dismissViewFromCurrentWindow()  {
        if let keyWindow = NSApplication.shared.keyWindow {
            if let dashboardVC = keyWindow.contentViewController as? DashboardViewController {
                dashboardVC.presenterContainerBGView.isHidden = true
                dashboardVC.presenter?.dismissVC()
                dashboardVC.presenter?.contentVC = nil
            }
        }
    }
    
    func showOnCurrentWindow(
        with title: String,
        identifier: String? = nil,
        contentVC: NSViewController,
        hideDivider: Bool = true,
        replaceVC: Bool = true,
        hideBackButton: Bool = true,
        height: CGFloat = 629
    ) {
        if let keyWindow = NSApplication.shared.keyWindow {
            if let dashboardVC = keyWindow.contentViewController as? DashboardViewController {
                dashboardVC.presenterContainerBGView.isHidden = false
                dashboardVC.presenterBGView.layer?.cornerRadius = 12
                dashboardVC.presenterContainerMainView.layer?.cornerRadius = 12
                dashboardVC.presenterBackButton.isHidden = hideBackButton
                dashboardVC.presenterViewHeightConstraint.constant = height
                DispatchQueue.main.async {
                    dashboardVC.presenterBGView.layoutSubtreeIfNeeded()
                }
                if dashboardVC.presenterIdentifier != identifier {
                    if replaceVC {
                        dashboardVC.presenter?.dismissVC()
                        dashboardVC.presenter?.contentVC = nil
                    } else {
                        dashboardVC.presenter?.setParentVC()
                        dashboardVC.presenter?.dismissVC()
                    }
                    dashboardVC.presenter?.configurePresenterVC(contentVC)
                    dashboardVC.presenterTitleLabel.stringValue = title
                    dashboardVC.presenterIdentifier = identifier
                    dashboardVC.presenterHeaderDivider.isHidden = hideDivider
                }
            }
        }
    }
    
    func showPubKeyWindow(vc: NSViewController, window: NSWindow?) {
        showNewWindow(with: "pubkey".localized,
                      size: CGSize(width: 400, height: 600),
                      centeredIn: window,
                      identifier: "pubkey-window",
                      contentVC: vc,
                      shouldClose: true)
    }
    
    func showTribeQRWindow(vc: NSViewController, window: NSWindow?) {
        showNewWindow(with: "share.group.link".localized,
                      size: CGSize(width: 400, height: 600),
                      centeredIn: window,
                      identifier: "tribe-qr-window",
                      contentVC: vc,
                      shouldClose: true)
    }
    
    func showEnterPinWindow(vc: NSViewController, window: NSWindow?, title: String? = nil) {
        showNewWindow(with: title ?? "pin".localized,
                      size: CGSize(width: 400, height: 440),
                      centeredIn: window,
                      contentVC: vc)
    }
    
    func showChangePinWindow(vc: NSViewController, window: NSWindow?, title: String? = nil) {
        showNewWindow(with: title ?? "pin".localized,
                      size: CGSize(width: 400, height: 500),
                      centeredIn: window,
                      contentVC: vc)
    }
    
    func showProfileWindow(vc: NSViewController, window: NSWindow?) {
        showOnCurrentWindow(with: "profile".localized, 
                            identifier: "profile-custom-window",
                            contentVC: vc,
                            hideDivider: false)
    }
    
    func showTransationsListWindow(vc: NSViewController, window: NSWindow?) {
        showOnCurrentWindow(with: "transactions".localized, 
                            identifier: "transactions-custom-window",
                            contentVC: vc,
                            hideDivider: false)
    }
    
    func showContactWindow(vc: NSViewController, window: NSWindow?, title: String, identifier: String, size: CGSize) {
        showOnCurrentWindow(with: title.localized,
                            identifier: "contact-custom-window",
                            contentVC: vc,
                            height: size.height)
    }
    
    func showInviteCodeWindow(vc: NSViewController, window: NSWindow?) {
        showNewWindow(with: "share.invite.code".localized,
                      size: CGSize(width: 400, height: 600),
                      centeredIn: window,
                      styleMask: [.closable, .titled],
                      contentVC: vc)
    }
    
    func showInvoiceWindow(vc: NSViewController, window: NSWindow?) {
        showNewWindow(with: "invoice".localized,
                      size: CGSize(width: 400, height: 600),
                      centeredIn: window,
                      identifier: "invoice-window",
                      contentVC: vc,
                      shouldClose: true)
    }
    
    func showCreateTribeWindow(
        title: String,
        vc: NSViewController,
        window: NSWindow?
    ) {
        showOnCurrentWindow(with: "Create Tribe".localized, 
                            identifier: "create-tribe-custom-window",
                            contentVC: vc,
                            hideDivider: false)
    }
    
    func showWebAppWindow(chat: Chat?, view: NSView, isAppURL: Bool = true) {
        if let chat = chat, let tribeInfo = chat.tribeInfo, let gameURL = isAppURL ? tribeInfo.appUrl : tribeInfo.secondBrainUrl, !gameURL.isEmpty && gameURL.isValidURL,
           let webGameVC = WebAppViewController.instantiate(chat: chat, isAppURL: isAppURL) {
            
            let appTitle = chat.name ?? ""
            let screen = NSApplication.shared.keyWindow
            let frame : CGRect = screen?.frame ?? view.frame
            
            let position = (screen?.frame.origin) ?? CGPoint(x: 0.0, y: 0.0)
            
            showNewWindow(with: appTitle,
                          size: CGSize(width: frame.width, height: frame.height),
                          minSize: CGSize(width: 350, height: 550),
                          position: position,
                          identifier: chat.getWebAppIdentifier(),
                          styleMask: [.titled, .resizable, .closable],
                          contentVC: webGameVC)
        }
        else{
            AlertHelper.showAlert(title: "generic.error.title".localized, message: "generic.error.message".localized)
        }
    }
    
    func showCallWindow(link: String) {
        if let jitsiCallVC = JitsiCallWebViewController.instantiate(link: link) {
            let appTitle = "Sphinx Call"
            
            let screen = NSApplication.shared.keyWindow
            let frame : CGRect = screen?.frame ?? CGRect(x: 0, y: 0, width: 400, height: 400)
            
            let position = (screen?.frame.origin) ?? CGPoint(x: 0.0, y: 0.0)
            
            showNewWindow(with: appTitle,
                          size: CGSize(width: frame.width, height: frame.height),
                          minSize: CGSize(width: 350, height: 550),
                          position: position,
                          identifier: link,
                          styleMask: [.titled, .resizable, .closable],
                          contentVC: jitsiCallVC)
        } else {
            if let url = URL(string: link) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func bringToFrontIfExists(identifier: String, chatIdentifier: Int? = nil) -> Bool {
        for window in NSApplication.shared.windows {
            if let window = window as? TaggedWindow {
                if window.windowIdentifier == identifier {
                    if let chatIdentifier = chatIdentifier, let wChatI = window.chatIdentifier, chatIdentifier != wChatI {
                        return false
                    }
                    window.orderedIndex = 0
                    return true
                }
            }
        }
        return false
    }
    
    func closeIfExists(identifier: String) {
        for window in NSApplication.shared.windows {
            if let window = window as? TaggedWindow {
                if window.windowIdentifier == identifier {
                    window.close()
                }
            }
        }
    }
}

struct WindowState: Codable {
    
    var frame: CGRect
    var minSize: CGSize
    var menuCollapsed: Bool
    
    init(frame: CGRect, minSize: CGSize, menuCollapsed: Bool) {
        self.frame = frame
        self.minSize = minSize
        self.menuCollapsed = menuCollapsed
    }
}

class TaggedWindow : NSWindow {
    var windowIdentifier: String? = nil
    var chatIdentifier: Int? = nil
}
