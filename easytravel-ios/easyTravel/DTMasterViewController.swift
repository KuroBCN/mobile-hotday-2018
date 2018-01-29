//
//  DTMasterViewControllerSW.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTMasterViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.easyTravelOrange
        
        // show master view on iPad potrait
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: FIRST_LAUNCH) {
            performSegue(withIdentifier: "SettingsSegue", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destController : DTMasterWebViewController?
        if let nav = segue.destination as? UINavigationController {
            // iPad
            destController = nav.topViewController as? DTMasterWebViewController
        } else {
            // iPhone
            destController = segue.destination as? DTMasterWebViewController
        }
        
        // prepare target web view controller
        destController?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        if let segId = segue.identifier {
            let host = DTRestUtils.getEasyTravelHost()
            let port = DTRestUtils.getEasyTravelPort()
            
            switch segId {
            case "ContactSegue":
                destController?.targetUrl = URL(string: String(format: "%@:%@/%@", host!, port!, "contact-orange-mobile.jsf"))
                destController?.title = "Contact"
                
            case "TermsOfUseSegue":
                destController?.targetUrl = URL(string: String(format: "%@:%@/%@", host!, port!, "legal-orange-mobile.jsf"))
                destController?.title = "Legal"
                
            case "PrivacyPolicySegue":
                destController?.targetUrl = URL(string: String(format: "%@:%@/%@", host!, port!, "privacy-orange-mobile.jsf"))
                destController?.title = "Privacy"
                
            case "specialOffers":
                destController?.title = "Special Offers"
                
            default:
                NSLog("unhandled segue identifier: \(segue.identifier ?? "")")
            }
        }
    }
}
