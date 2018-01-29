//
//  DTLoginViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit
import Security

class DTLoginViewController: UIViewController, DTResultHandler {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var rememberUserSwitch: UISwitch!
    
    var loginResult : NSMutableDictionary?
    var currentLoginElement : String?
    var closeOnSuccess = false
    
    static var sharedKeychain : KeychainItemWrapper?
    class func sharedKeychainWrapper() -> KeychainItemWrapper{
        if sharedKeychain == nil {
            sharedKeychain = KeychainItemWrapper(identifier: DTConstants.kKeychainIdentifier, accessGroup: nil)
        }
        return sharedKeychain!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        loginLabel.isHidden = true
        rememberUserSwitch.setOn(UserDefaults.standard.bool(forKey: REMEMBER_USER), animated: false)
        loadKeychainData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set(rememberUserSwitch.isOn, forKey: REMEMBER_USER)
        updateKeychainData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadKeychainData() {
        if UserDefaults.standard.bool(forKey: REMEMBER_USER) {
            let keyChainUser = DTLoginViewController.sharedKeychainWrapper().object(forKey: kSecAttrAccount)
            let KeyChainPassword = DTLoginViewController.sharedKeychainWrapper().object(forKey: kSecValueData)
            
            if let user = keyChainUser as? String, let pw = KeyChainPassword as? String {
                username.text = user
                password.text = pw
            }
        }
    }
    
    func updateKeychainData() {
        if UserDefaults.standard.bool(forKey: REMEMBER_USER) {
            // update data
            let keyChain = DTLoginViewController.sharedKeychainWrapper()
            keyChain.setObject(username.text, forKey: kSecAttrAccount)
            keyChain.setObject(password.text, forKey: kSecValueData)
        } else {
            // clear data
            DTLoginViewController.sharedKeychainWrapper().resetKeychainItem()
        }
    }
    
    @IBAction func loginButtonTouchDown(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: CRASH_ON_LOGIN) {
            UIAlertView(title: "CRASH", message: "You just triggered a crash!", delegate: nil, cancelButtonTitle: "OK").show()
            
            // provoke a crash
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                fatalError()
            })
            return
        }
        
        username.resignFirstResponder()
        password.resignFirstResponder()
        
        if checkLoginStringValidity(username.text, message: "Username is empty!")
            && checkLoginStringValidity(password.text, message: "Password is empty!") {
            performLogin()
        }
        
    }
    
    func checkLoginStringValidity(_ loginString : String?, message: String) -> Bool {
        if let str = loginString,
            str.count <= 0 {
            loginLabel.text = message
            loginLabel.textColor = UIColor.red
            loginLabel.isHidden = false
            return false
        }
        return true
    }
    
    func performLogin() {
        
        loginActivityIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var params = Dictionary<String, String>()
        params["userName"] = username.text
        params["password"] = password.text
        DTRestUtils(delegate: self, showErrors: true).performOperation(AUTHENTICATE, ofService: AUTH_SERVICE, withParameters: params, withKey: username.text)
        
        // 3rd party stuff - buy why?
        let timeout = 2.0
        loadURL("http://plusone.google.com", withTimeout: timeout)
        loadURL("https://www.facebook.com/compuware", withTimeout: timeout)
    }
    
    func loadURL(_ urlStr : String, withTimeout timeout : Double) {
        if let url = URL(string: urlStr) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
    
    func cleanup() {
        loginActivityIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // DTHandler delegate methods
    func operationFinished(_ data: NSObject!) {
        //check if we got correct data - else do not overwrite messages set by operatioFailed:
        if let result = data as? NSDictionary {
            let value = result.object(forKey: kAuthentictionResponse)
            if let strValue = result.object(forKey: String(format: DTConstants.kReturn)) as? NSString,
                value != nil {
                loginFinished(successful: strValue.boolValue)
            } else {
                loginFinished(successful: false)
            }
        }
        
        //close action after reporting values
        cleanup()
    }
    
    func loginFinished(successful : Bool) {
        if successful {
            DTUtils.setUserName(username.text)
            if closeOnSuccess {
                // came from journey view -> go back if logged in
                navigationController?.popViewController(animated: true)
            } else {
                loginLabel.text = "Login successful!"
                loginLabel.textColor = UIColor.green
                loginLabel.isHidden = false
            }
        } else {
            DTUtils.setUserName(nil)
            loginLabel.text = "Login failed!"
            loginLabel.textColor = UIColor.red
            loginLabel.isHidden = false
        }
    }
    
    func operationFailed(_ data: NSObject!) {
        cleanup()
        loginFinished(successful: false)
    }
    
    func parseXMLResponse(_ xmlData: Data!) -> [AnyHashable : Any]! {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        loginResult = NSMutableDictionary()
        
        if parser.parse() {
            return loginResult as! [AnyHashable : Any]
        }
        return nil
    }
    
    // NSXMLParser delegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        NSLog("START element: \(elementName) nsURI: \(namespaceURI ?? "") qname: \(qName ?? "") attributes: \(attributeDict)")
        DTRestUtils.parseNamespacePrefix(attributeDict)
        currentLoginElement = elementName
        if let curLoginElement = currentLoginElement {
            // insert element key
            loginResult?.setObject(NSNull(), forKey: curLoginElement as NSCopying)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        NSLog("ELEMENT content: \(string)")
        if string.count > 0,
            let curLoginElement = currentLoginElement {
            // replace value for element if present
            loginResult?.setObject(string, forKey: curLoginElement as NSCopying)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        NSLog("\(parseError.localizedDescription)")
    }
}
