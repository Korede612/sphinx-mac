//
//  WebAppHelper.swift
//  Sphinx
//
//  Created by Tomas Timinskas on 19/08/2020.
//  Copyright © 2020 Sphinx. All rights reserved.
//

import Foundation
import WebKit

class WebAppHelper : NSObject {
    
    
    public let messageHandler = "sphinx"
    
    var webView : WKWebView! = nil
    var authorizeHandler: (([String: AnyObject]) -> ())! = nil
    
    var persistingValues: [String: AnyObject] = [:]
    
    func setWebView(_ webView: WKWebView, authorizeHandler: @escaping (([String: AnyObject]) -> ())) {
        self.webView = webView
        self.authorizeHandler = authorizeHandler
    }
}

extension WebAppHelper : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == messageHandler {
            guard let dict = message.body as? [String: AnyObject] else {
                return
            }

            if let type = dict["type"] as? String {
                switch(type) {
                case "AUTHORIZE":
                    authorizeHandler(dict)
                    break
                case "KEYSEND":
                    sendKeySend(dict)
                    break
                case "UPDATED":
                    sendUpdatedMessage(dict)
                    NotificationCenter.default.post(name: .onBalanceDidChange, object: nil)
                    break
                case "RELOAD":
                    sendReloadMessage(dict)
                    break
                case "PAYMENT":
                    sendPayment(dict)
                    break
                case "LSAT":
                    saveLSAT(dict)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func jsonStringWithObject(obj: AnyObject) -> String? {
        let jsonData  = try? JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        if let jsonData = jsonData {
            return String(data: jsonData, encoding: .utf8)
        }
        
        return nil
    }
    
    func sendMessage(dict: [String: AnyObject]) {
        if let string = jsonStringWithObject(obj: dict as AnyObject) {
            let javascript = "window.sphinxMessage('\(string)')"
            webView.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
    
    func setTypeApplicationAndPassword(params: inout [String: AnyObject], dict: [String: AnyObject]) {
        let password = EncryptionManager.randomString(length: 16)
        saveValue(password as AnyObject, for: "password")
        
        params["type"] = dict["type"] as AnyObject
        params["application"] = dict["application"] as AnyObject
        params["password"] = password as AnyObject
    }
    
    //AUTHORIZE
    func authorizeWebApp(amount: Int, dict: [String: AnyObject], completion: @escaping () -> ()) {
        if let challenge = dict["challenge"] as? String {
            signChallenge(amount: amount, challenge: challenge, dict: dict, completion: completion)
        } else {
            sendAuthorizeMessage(amount: amount, dict: dict, completion: completion)
        }
    }
    
    func sendAuthorizeMessage(amount: Int, signature: String? = nil, dict: [String: AnyObject], completion: @escaping () -> ()) {
        if let pubKey = UserData.sharedInstance.getUserPubKey() {
            var params: [String: AnyObject] = [:]
            setTypeApplicationAndPassword(params: &params, dict: dict)
            
            params["budget"] = amount as AnyObject
            params["pubkey"] = pubKey as AnyObject
            
            saveValue(amount as AnyObject, for: "budget")
            saveValue(pubKey as AnyObject, for: "pubkey")
            
            if let signature = signature {
                params["signature"] = signature as AnyObject
            }
            
            sendMessage(dict: params)
            completion()
        }
    }
    
    func signChallenge(amount: Int, challenge: String, dict: [String: AnyObject], completion: @escaping () -> ()) {
        API.sharedInstance.signChallenge(challenge: challenge, callback: { signature in
            self.sendAuthorizeMessage(amount: amount, signature: signature, dict: dict, completion: completion)
        })
    }
    
    //UPDATED
    func sendUpdatedMessage(_ dict: [String: AnyObject]) {
        var params: [String: AnyObject] = [:]
        setTypeApplicationAndPassword(params: &params, dict: dict)
        sendMessage(dict: params)
    }
    
    //RELOAD
    func sendReloadMessage(_ dict: [String: AnyObject]) {
        let (success, budget, pubKey) = getReloadParams(dict: dict)
        var params: [String: AnyObject] = [:]
        params["success"] = success as AnyObject
        params["budget"] = budget as AnyObject
        params["pubkey"] = pubKey as AnyObject
        
        setTypeApplicationAndPassword(params: &params, dict: dict)
        sendMessage(dict: params)
    }
    
    func getReloadParams(dict: [String: AnyObject]) -> (Bool, Int, String) {
        let password: String? = getValue(withKey: "password")
        var budget = 0
        var pubKey = ""
        var success = false
        
        if let pass = dict["password"] as? String, pass == password {
            let savedBudget: Int? = getValue(withKey: "budget")
            let savedPubKey: String? = getValue(withKey: "pubkey")
            
            success = true
            budget = savedBudget ?? 0
            pubKey = savedPubKey ?? ""
        }
        
        return (success, budget, pubKey)
    }
    
    //KEYSEND
    func sendKeySendResponse(dict: [String: AnyObject], success: Bool) {
        var params: [String: AnyObject] = [:]
        setTypeApplicationAndPassword(params: &params, dict: dict)
        params["success"] = success as AnyObject
        
        sendMessage(dict: params)
    }
    
    func sendKeySend(_ dict: [String: AnyObject]) {
        if let dest = dict["dest"] as? String, let amt = dict["amt"] as? Int {
            let params = getParams(pubKey: dest, amount: amt)
            API.sharedInstance.sendDirectPayment(params: params, callback: { payment in
                self.sendKeySendResponse(dict: dict, success: true)
            }, errorCallback: {
                self.sendKeySendResponse(dict: dict, success: false)
            })
        }
    }
    
    //Payment
    func sendPaymentResponse(dict: [String: AnyObject], success: Bool) {
        var params: [String: AnyObject] = [:]
        setTypeApplicationAndPassword(params: &params, dict: dict)
        params["success"] = success as AnyObject
        
        sendMessage(dict: params)
    }
    
    func sendPayment(_ dict: [String: AnyObject]) {
        if let paymentRequest = dict["paymentRequest"] as? String {
            let params = ["payment_request": paymentRequest as AnyObject]
            API.sharedInstance.payInvoice(parameters: params, callback: { payment in
                self.sendPaymentResponse(dict: dict, success: true)
            }, errorCallback: {
                self.sendPaymentResponse(dict: dict, success: false)
            })
        }
    }
    
    //Payment
    func sendLsatResponse(dict: [String: AnyObject], success: Bool) {
        var params: [String: AnyObject] = [:]
        setTypeApplicationAndPassword(params: &params, dict: dict)
        params["lsat"] = dict["lsat"] as AnyObject
        params["success"] = success as AnyObject
        sendMessage(dict: params)
    }
    
    func saveLSAT(_ dict: [String: AnyObject]) {

        if let paymentRequest = dict["paymentRequest"] as? String, let macaroon = dict["macaroon"] as? String, let issuer = dict["issuer"] as? String {
            let params = ["paymentRequest": paymentRequest as AnyObject, "macaroon": macaroon as AnyObject, "issuer": issuer as AnyObject]
            let savedBudget: Int? = getValue(withKey: "budget")
            let amount: Int = getInvoiceAmount(invoice: paymentRequest)
            if(savedBudget! < amount || amount == -1){
                self.sendLsatResponse(dict: dict, success: false)
                return
            }
            let newBudget = savedBudget! - amount
            saveValue(newBudget as AnyObject, for: "budget")

            API.sharedInstance.payLsat(parameters: params, callback: { payment in
                var newDict = dict
                if let lsat = payment["lsat"].string {
                    newDict["lsat"] = lsat as AnyObject
                }
                
                self.sendLsatResponse(dict: newDict, success: true)
            }, errorCallback: {
                self.sendLsatResponse(dict: dict, success: false)
            })
        }
    }
    
    func getParams(pubKey: String, amount: Int) -> [String: AnyObject] {
        var parameters = [String : AnyObject]()
        parameters["amount"] = amount as AnyObject?
        parameters["destination_key"] = pubKey as AnyObject?
            
        return parameters
    }
    
    func saveValue(_ value: AnyObject, for key: String) {
        persistingValues[key] = value
    }
    
    func getValue<T>(withKey key: String) -> T? {
        if let value = persistingValues[key] as? T {
            return value
        }
        return nil
    }
    
    func getInvoiceAmount(invoice: String) -> Int {
        var amount: Int = 0
        let network: String = invoice[0 ..< 4]
        if(network != "lnbc"){
            //fail here
            return -1
        }
        
        let invoiceMinusNetwork: String = invoice[4 ..< invoice.length]
        var splitInvoice: Array<String> = []
        outer: for letter in invoiceMinusNetwork {
            switch letter {
                case "m":
                    splitInvoice = invoiceMinusNetwork.components(separatedBy: "m")
                    let theAmount = splitInvoice[0]
                    amount = Int(theAmount)! * 100000
                    break outer;
                case "u":
                    splitInvoice = invoiceMinusNetwork.components(separatedBy: "u")
                    let theAmount = splitInvoice[0]
                    amount = Int(theAmount)! * 100
                    break outer;
                case "n":
                    splitInvoice = invoiceMinusNetwork.components(separatedBy: "n")
                    let theAmount = splitInvoice[0]
                    amount = Int(theAmount)! / 10
                    break outer;
                case "p":
                    splitInvoice = invoiceMinusNetwork.components(separatedBy: "p")
                    let theAmount = splitInvoice[0]
                    amount = Int(theAmount)! / 10000
                    break outer;
                default:
                    continue
            }
        }
        return amount
    }
}
