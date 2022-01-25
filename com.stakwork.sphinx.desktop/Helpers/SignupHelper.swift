//
//  SignupHelper.swift
//  com.stakwork.sphinx.desktop
//
//  Created by Tomas Timinskas on 11/05/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import Foundation
import SwiftyJSON

class SignupHelper {
    
    public enum SignupMode: Int {
        case NewUser
        case ExistingUser
    }
    
    public enum SignupStep: Int {
        case Start
        case IPAndTokenSet
        case InviterContactCreated
        case PINNameSet
        case ImageSet
        case SphinxReady
        case SignupComplete
    }
    
    struct Inviter {
        var nickname: String
        var pubkey: String
        var routeHint: String? = nil
        var welcomeMessage: String
        
        init(nickname: String, pubkey: String, routeHint: String? = nil, welcomeMessage: String) {
            self.nickname = nickname
            self.pubkey = pubkey
            self.routeHint = routeHint
            self.welcomeMessage = welcomeMessage
        }
    }
    
    public static var step: Int {
        get {
            return UserDefaults.Keys.signupStep.get(defaultValue: 0)
        }
        set {
            UserDefaults.Keys.signupStep.set(newValue)
        }
    }
    
    public static func isLogged() -> Bool {
        return step == SignupHelper.SignupStep.SignupComplete.rawValue || step == SignupHelper.SignupStep.SphinxReady.rawValue
    }
    
    public static func completeSignup() {
        step = SignupStep.SignupComplete.rawValue
    }
    
    public static func getDefaultInviter() -> JSON {
        var inviteData = [String : String]()
        inviteData["nickname"] = "Sphinx Support"
        inviteData["pubkey"] = "023d70f2f76d283c6c4e58109ee3a2816eb9d8feb40b23d62469060a2b2867b77f"
        inviteData["message"] = "Welcome to Sphinx!"
        
        return JSON(inviteData)
    }
    
    public static func resetInviteInfo() {
        UserDefaults.Keys.currentIP.removeValue()
        UserDefaults.Keys.inviteString.removeValue()
        UserDefaults.Keys.inviterNickname.removeValue()
        UserDefaults.Keys.inviterRouteHint.removeValue()
        UserDefaults.Keys.inviterPubkey.removeValue()
        UserDefaults.Keys.welcomeMessage.removeValue()
    }
    
    public static func saveInviterInfo(invite: JSON, code: String? = nil) {
        UserDefaults.Keys.inviteString.set(code)
        UserDefaults.Keys.inviterNickname.set(invite["nickname"].stringValue)
        UserDefaults.Keys.inviterPubkey.set(invite["pubkey"].stringValue)
        UserDefaults.Keys.inviterRouteHint.set(invite["route_hint"].stringValue)
        UserDefaults.Keys.welcomeMessage.set(invite["message"].stringValue)
        UserDefaults.Keys.inviteAction.set(invite["action"].stringValue)

    }
    
    public static func getInviter() -> Inviter? {
        if let nickname:String = UserDefaults.Keys.inviterNickname.get(),
           let pubkey:String = UserDefaults.Keys.inviterPubkey.get(),
           let welcomeMessage:String = UserDefaults.Keys.welcomeMessage.get() {
           
            let routeHint: String? = UserDefaults.Keys.inviterRouteHint.get()
            return Inviter(nickname: nickname, pubkey: pubkey, routeHint: routeHint, welcomeMessage: welcomeMessage)
        }
        return nil
    }
    
    public static func resetSignupData() {
        UserDefaults.Keys.inviteString.removeValue()
        UserDefaults.Keys.inviterNickname.removeValue()
        UserDefaults.Keys.inviterPubkey.removeValue()
        UserDefaults.Keys.welcomeMessage.removeValue()
    }
}
