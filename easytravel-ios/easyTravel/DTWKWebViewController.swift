//
//  DTWKWebViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 25.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit
import WebKit

class DTWKWebViewController: DTMasterWebViewController, WKNavigationDelegate {

    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView?.navigationDelegate = self

        if let url = targetUrl {
            /* Page: Contact, TOS, Privary Policy */
            webView?.load(URLRequest(url: getLocalPage("loading.html")))
            // wait some time befor switching from local to remote html
            if !UserDefaults.standard.bool(forKey: FRONTEND_NOT_REACHABLE) {
                webView?.perform(#selector(webView?.load(_:)), with: URLRequest(url: url), afterDelay: 1.5)
            }
        }
        
    }

    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //JLT-79873 avoid crashes because of scheduled performSelector: sent to deallocated object!
        if let webView = webView {
            NSObject.cancelPreviousPerformRequests(withTarget: webView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if targetUrl != nil {
            /* Page: Contact, TOS, Privary Policy */
            // might break if webpage gets updated
            webView.evaluateJavaScript("document.getElementsByTagName('html')[0].style.backgroundColor = 'white'")
            webView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.fontFamily = '-apple-system,HelveticaNeue'")
            webView.evaluateJavaScript("document.getElementsByTagName('body')[0].style.textAlign = 'center'")
        }
    }
    
    // APM-103834 disabled certificate check for WKWebView
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        NSLog("WKWebView SSL certificate check is disabled!");
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
