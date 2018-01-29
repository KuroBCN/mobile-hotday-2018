//
//  DTSettingsViewControllerSW.swift
//  easyTravel
//
//  Created by labuser on 11.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTSettingsViewController: UIViewController {
    
    @IBOutlet weak var easyTravelHost: UITextField!
    @IBOutlet weak var easyTravelPort: UITextField!
    @IBOutlet weak var alternativMonitorSignalDestination: UITextField!
    @IBOutlet weak var agentInfoLabel: UILabel!
    @IBOutlet weak var crashOnLoginSwitch: UISwitch!
    @IBOutlet weak var frontendNotReachableSwitch: UISwitch!
    @IBOutlet weak var errorsOnSearchAndBooking: UISwitch!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var adkBottom: NSLayoutConstraint!
    @IBOutlet weak var layoutTop: NSLayoutConstraint!
    
    var layoutTopConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        agentInfoLabel.text = "Perform Example"
        
        
        // load settings
        let userDefaults = UserDefaults.standard
        easyTravelHost.text = DTRestUtils.getEasyTravelHost()
        easyTravelPort.text = DTRestUtils.getEasyTravelPort()
        alternativMonitorSignalDestination.text = userDefaults.object(forKey: ADK_MONITOR_SIGNAL_DESTINATION) as? String
        
        crashOnLoginSwitch.setOn(userDefaults.bool(forKey: CRASH_ON_LOGIN), animated: false)
        frontendNotReachableSwitch.setOn(userDefaults.bool(forKey: FRONTEND_NOT_REACHABLE), animated: false)
        errorsOnSearchAndBooking.setOn(userDefaults.bool(forKey: ERRORS_ON_SEARCH_AND_BOOKING), animated: false)
        
        // listen on keyboard for IB constraint changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardAppears(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDisappears(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // prevent from beeing freed after temporarily disabling the constraint
        layoutTopConstraint = layoutTop
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save settings
        let userDefaults = UserDefaults.standard
        let easyTravelHost = self.easyTravelHost.text
        let easyTravelPort = self.easyTravelPort.text
        let alternativMonitorSignalDestination = self.alternativMonitorSignalDestination.text
        
        if let host = easyTravelHost,
            host.count > 3 {
            // shortest hostnam is s.t. like 1.at
            userDefaults.set(host, forKey: EASYTRAVEL_HOST)
        }
        
        if let port = easyTravelPort as NSString?,
            port.integerValue > 0 && port.integerValue < 65536 {
            //no strings, only valid port ranges 0 - (2^16)-1
            userDefaults.set(port, forKey: EASYTRAVEL_PORT)
        } else {
            userDefaults.removeObject(forKey: EASYTRAVEL_PORT)
        }
        
        if let monitor = alternativMonitorSignalDestination,
            monitor.count > 3 {
            userDefaults.set(monitor, forKey: ADK_MONITOR_SIGNAL_DESTINATION)
        } else {
            userDefaults.set("", forKey: ADK_MONITOR_SIGNAL_DESTINATION)
        }
        
        userDefaults.set(crashOnLoginSwitch.isOn, forKey: CRASH_ON_LOGIN)
        userDefaults.set(frontendNotReachableSwitch.isOn, forKey: FRONTEND_NOT_REACHABLE)
        userDefaults.set(errorsOnSearchAndBooking.isOn, forKey: ERRORS_ON_SEARCH_AND_BOOKING)
        userDefaults.set(false, forKey: FIRST_LAUNCH)
        
        // cleanup
        NotificationCenter.default.removeObserver(self)
        
        self.easyTravelPort.resignFirstResponder()
        self.easyTravelHost.resignFirstResponder()
        self.alternativMonitorSignalDestination.resignFirstResponder()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // close keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        easyTravelPort.resignFirstResponder()
        easyTravelHost.resignFirstResponder()
        alternativMonitorSignalDestination.resignFirstResponder()
    }
    
    @objc func keyboardAppears(notification : NSNotification) {
        if alternativMonitorSignalDestination.isFirstResponder,
            let info = notification.userInfo,
            let keyboardInfo = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                if !self.isIpadPortrait() {
                    self.layoutTopConstraint!.isActive = false
                }
                self.adkBottom.constant = keyboardInfo.cgRectValue.size.height
            })
        }
    }
    
    @objc func keyboardDisappears(notification : NSNotification) {
        if alternativMonitorSignalDestination.isFirstResponder {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.adkBottom.constant = 20
                if !self.isIpadPortrait() {
                    self.layoutTopConstraint!.isActive = true
                }
            })
        }
    }
    
    // Should be done in IB
    func isIpadPortrait() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isPortrait
    }
}
