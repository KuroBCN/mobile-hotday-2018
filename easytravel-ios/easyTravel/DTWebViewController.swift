//
//  DTWebViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTWebViewController: DTMasterWebViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = targetUrl {
            /* Page: Contact, TOS, Privary Policy */
            webView.loadRequest(URLRequest(url: getLocalPage("loading.html")))
            // wait some time befor switching from local to remote html
            if !UserDefaults.standard.bool(forKey: FRONTEND_NOT_REACHABLE) {
                webView.perform(#selector(webView.loadRequest), with: URLRequest(url: url), afterDelay: 1.5)
            }
        } else {
            /* Page: Special Offers */
            webView.loadRequest(URLRequest(url: getLocalPage("special_offers.html")))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //JLT-79873 avoid crashes because of scheduled performSelector: sent to deallocated object!
        NSObject.cancelPreviousPerformRequests(withTarget: webView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if targetUrl != nil {
            /* Page: Contact, TOS, Privary Policy */
            // might break if webpage gets updated
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('html')[0].style.backgroundColor = 'white'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontFamily = '-apple-system,HelveticaNeue'")
            webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.textAlign = 'center'")
        } else {
            /* Page: Special Offers */
            let easyTravelHost = DTRestUtils.getEasyTravelHost()
            let easyTravelPort = DTRestUtils.getEasyTravelPort()
            
            if let host = easyTravelHost, var port = easyTravelPort {
                if UserDefaults.standard.bool(forKey: FRONTEND_NOT_REACHABLE) {
                    port = "1234"
                }
                webView.stringByEvaluatingJavaScript(from: "createEasyTravelBaseURL('\(host)', '\(port)')")
            }
        }
    }
}
