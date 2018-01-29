//
//  DTJourneyDetailsViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTJourneyDetailsViewController: UIViewController, DTResultHandler {
    
    @IBOutlet weak var journeyImage: UIImageView!
    @IBOutlet weak var journeyLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var tenantLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bookJourneyButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bookingResultLabel: UILabel!
    
    var journey : DTJourney?
    var dateFormatter : DateFormatter?
    var bookingResult : NSMutableDictionary?
    var currentBookingElement : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        dateFormatter = DateFormatter()
        dateFormatter?.dateStyle = .medium
        dateFormatter?.timeStyle = .short
        
        if let curJourney = journey {
            journeyImage.image = curJourney.image
            journeyLabel.text = curJourney.name
            destinationLabel.text = curJourney.destination.name
            fromDateLabel.text = dateFormatter?.string(from: curJourney.fromDateTime)
            toDateLabel.text = dateFormatter?.string(from: curJourney.toDateTime)
            tenantLabel.text = journey?.tenant.name
            priceLabel.text = String(format: "$%.2f", curJourney.amount)
            bookingResultLabel.isHidden = true
            
            prepareButton()
        }
        
        // iPad back button color (default: orange)
        if UIScreen.main.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // reload after login segue
        prepareButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segId = segue.identifier, segId == "bookLogin",
            let loginVC = segue.destination as? DTLoginViewController {
            loginVC.closeOnSuccess = true
        }
    }
    
    func prepareButton() {
        if DTUtils.userName() == nil {
            bookJourneyButton.setTitle("Login to book a journey!", for: UIControlState.normal)
        } else {
            bookJourneyButton.setTitle("Book Journey", for: UIControlState.normal)
        }
    }
    
    @IBAction func bookJourney(_ sender: Any) {
        if DTUtils.userName() == nil {
            // login
            performSegue(withIdentifier: "bookLogin", sender: self)
        } else {
            // book journey
            
            progressIndicator.startAnimating()
            bookJourneyButton.isHidden = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            // JLT-110432 create credit card number from user name, so it is different for different users
            if let user = DTUtils.userName(),
                let journeyObj = journey {
                let creditCardNumber = calculateCreditCardNumber(user)
                
                //see http://dynasprint.emea.cpwr.corp:8091/services/listServices
                var params = Dictionary<String, String>()
                params["journeyId"] = String(format: "%ld", journeyObj.idNumber)
                params["userName"] = user
                params["creditCard"] = String(creditCardNumber)
                params["amount"] = String(format: "%ld", journeyObj.amount)
                DTRestUtils(delegate: self, showErrors: true).performOperation(STORE_BOOKING, ofService: BOOKING_SERVICE, withParameters: params, withKey: journeyObj.name)
            }
        }
    }
    
    func calculateCreditCardNumber(_ userName : String) -> String {
        // ensure same calculation and result on iOS and Android
        var value : UInt64 = 0
        for i in 0 ... userName.count - 1{
            // Cleaner solution Character -> UInt64?
            value = 31 * value + UInt64(userName[i].utf8.map{ UInt8($0) }[0])
        }
        
        // make sure it has exactly 16 digits
        let creditConst : UInt64 = 1000000000000000
        return String(format: "%lu", (value + creditConst % creditConst))
    }
    
    func cleanup() {
        progressIndicator.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // DTHandler delegate methods
    func operationFinished(_ data: NSObject!) {
        //check if we got correct data - else do not overwrite messages set by operatioFailed:
        if let result = data as? NSDictionary {
            var value = result.object(forKey: kStoreBookingResponse)
            if UserDefaults.standard.bool(forKey: ERRORS_ON_SEARCH_AND_BOOKING) {
                value = nil
            }
            
            if value != nil,
                result.object(forKey: String(format: DTConstants.kReturn)) != nil{
                bookingFinished(successful: true)
            } else {
                bookingFinished(successful: false)
            }
            bookingResultLabel.isHidden = false
        }
        
        //close action after reporting values
        cleanup()
    }
    
    func bookingFinished(successful : Bool) {
        if let _ = journey {
            if successful {
                bookingResultLabel.text = "Booking Journey successful"
                bookingResultLabel.textColor = UIColor.green
                bookingResultLabel.isHidden = false
            } else {
            
                bookingResultLabel.text = "Booking Journey failed!"
                bookingResultLabel.textColor = UIColor.red
            }
            bookJourneyButton.isHidden = true
            bookingResultLabel.isHidden = false
        }
    }
    
    func operationFailed(_ data: NSObject!) {
        bookingFinished(successful: false)
        cleanup()
    }
    
    func parseXMLResponse(_ xmlData: Data!) -> [AnyHashable : Any]! {
        if (xmlData) != nil {
            let parser = XMLParser(data: xmlData)
            parser.delegate = self
            bookingResult = NSMutableDictionary()
            
            if parser.parse() {
                return bookingResult as! [AnyHashable : Any]
            }
        }
        return nil
    }
    
    // NSXMLParser delegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        NSLog("START element: \(elementName) nsURI: \(namespaceURI ?? "") qname: \(qName ?? "") attributes: \(attributeDict)")
        DTRestUtils.parseNamespacePrefix(attributeDict)
        currentBookingElement = elementName
        if let curBookingElement = currentBookingElement {
            // insert element key
            bookingResult?.setObject(NSNull(), forKey: curBookingElement as NSCopying)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        NSLog("ELEMENT content: \(string)")
        if string.count > 0,
            let curBookingElement = currentBookingElement {
            // replace value for element if present
            bookingResult?.setObject(string, forKey: curBookingElement as NSCopying)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        NSLog("\(parseError.localizedDescription)")
    }
}
