//
//  DTMasterWebViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 25.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTMasterWebViewController: UIViewController {

    var targetUrl : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLocalPage(_ fileName : String) -> URL {
        let resourceURL = Bundle.main.resourceURL
        if let url = resourceURL {
            return url.appendingPathComponent(fileName)
        }
        return URL(string: "")!
    }
}
