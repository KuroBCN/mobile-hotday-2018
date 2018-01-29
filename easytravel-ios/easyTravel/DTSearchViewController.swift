//
//  SearchTableViewController.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit

class DTSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, DTResultHandler {
    
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var lastLocationResponseId = 0
    
    var fromDate : Date?
    var toDate : Date?
    var dateFormatterMedium : DateFormatter?
    var dateFormatterLong : DateFormatter?
    var searchResult : NSMutableDictionary?
    var searchResultArray : NSMutableArray?
    var xmlCurrentDictionaryStack : NSMutableArray?
    var xmlCurrentElementStack : NSMutableArray?
    var resultList : NSMutableArray?
    var suggestionsResultList : NSMutableArray?
    var resultSearchController = UISearchController()
    
    static let dateCellIdentifier = "dateCell"
    static let journeyCellIdentifier = "JourneySearchResultCell"
    static let suggestionCellIdentifier = "searchSuggestionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        datePicker.backgroundColor = .white
        
        dateFormatterMedium = DateFormatter()
        dateFormatterMedium?.dateStyle = .medium
        dateFormatterMedium?.timeStyle = .none
        
        dateFormatterLong = DateFormatter()
        dateFormatterLong?.dateStyle = .long
        dateFormatterLong?.timeStyle = .none
        
        fromDate = Date()
        toDate = Date()
        toDate! += 60*60*24*365 // 1 year
        
        datePicker.isHidden = true
        setDoneButtonState(false)
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.delegate = self
        resultSearchController.searchBar.barTintColor = UIColor.easyTravelOrange
        resultTable.tableHeaderView = resultSearchController.searchBar
        
        definesPresentationContext = true
        
        resultTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performAutocompleteSearchFor(destination : String, checkForJourneys : Bool, maxResultSize : Int) {
        
        var params = Dictionary<String, String>()
        params["name"] = destination
        params["maxResultSize"] = String(format: "%d", maxResultSize)
        params["checkForJourneys"] = checkForJourneys ? "true" : "false"
        DTRestUtils(delegate: self, showErrors: true).performOperation(FIND_LOCATIONS, ofService: JOURNEY_SERVICE, withParameters: params, withKey: destination)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func performSearchFor(destination : String, from : Date, to : Date) {
        
        if UserDefaults.standard.bool(forKey: ERRORS_ON_SEARCH_AND_BOOKING) {
            do {
                try _ = String(contentsOf: URL(string: "http://easyTravelAds")!, encoding: String.Encoding.utf8)
            } catch let error {
                NSLog("failed to contact advertisements server: \(error.localizedDescription)")
                return // ??
            }
        }
        
        let fromDateInSeconds = DTUtils.seconds(forTimeInterval: (fromDate?.timeIntervalSince1970)!)
        let toDateInSeconds = DTUtils.seconds(forTimeInterval: (toDate?.timeIntervalSince1970)!)
        
        var params = Dictionary<String, String>()
        params["destination"] = destination
        params["fromDate"] = String(format: "%lld", fromDateInSeconds)
        params["toDate"] = String(format: "%lld", toDateInSeconds)
        DTRestUtils(delegate: self, showErrors: true).performOperation(FIND_JOURNEYS, ofService: JOURNEY_SERVICE, withParameters: params, withKey: destination)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func cleanup() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JourneyDetailsSegue",
            let journey = sender as? DTJourney,
            let controller = segue.destination as? DTJourneyDetailsViewController {
            controller.journey = journey
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "JourneyDetailsSegue" && sender is DTJourney
    }
    
    @IBAction func doneAction(_ sender: Any) {
        hideDatePicker()
    }
    
    @IBAction func dateAction(_ sender: Any) {
        if let indexPath = resultTable.indexPathForSelectedRow {
            let cell = resultTable.cellForRow(at: indexPath)
            cell?.detailTextLabel?.text = dateFormatterMedium?.string(from: datePicker.date)
            
            if indexPath[1] == 0 {
                fromDate = datePicker.date
            } else {
                toDate = datePicker.date
            }
        }
    }
    
    func setDoneButtonState(_ state : Bool) {
        navigationItem.rightBarButtonItem?.title = state ? "Done" : ""
        navigationItem.rightBarButtonItem?.isEnabled = state
    }
    
    @objc func hidePicker() {
        datePicker.isHidden = true
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let result = resultList{
            return result.count
        } else if let result = suggestionsResultList {
            //got search suggestions
            return result.count
        } else {
            //set a cell with mock search suggestions
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let result = resultList,
            result.count > 0 {
            return buildJourneyCell(tableView, cellForRowAt: indexPath)
        } else if let suggestions = suggestionsResultList,
            suggestions.count > 0 {
            //got search suggestions
            return buildSuggestionCell(tableView, cellForRowAt: indexPath)
        } else if !resultSearchController.isActive {
            return buildDateCell(tableView, cellForRowAt: indexPath)
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let targetCell = tableView.cellForRow(at: indexPath),
            resultList == nil {
            if suggestionsResultList != nil {
                resultSearchController.searchBar.text = targetCell.textLabel?.text
                searchBarSearchButtonClicked(resultSearchController.searchBar)
                resultSearchController.searchBar.resignFirstResponder()
            } else if !resultSearchController.isActive {
                showDatePicker(tableView, targetCell: targetCell)
            }
        } else {
            let journey = resultList?.object(at: indexPath[1])
            performSegue(withIdentifier: "JourneyDetailsSegue", sender: journey)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func buildDateCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: DTSearchViewController.dateCellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: DTSearchViewController.suggestionCellIdentifier)
        }
        
        if indexPath[1] == 0 {
            cell?.textLabel?.text = "From Date"
            cell?.detailTextLabel?.text = dateFormatterMedium?.string(from: fromDate!)
        } else {
            cell?.textLabel?.text = "To Date"
            cell?.detailTextLabel?.text = dateFormatterMedium?.string(from: toDate!)
        }
        
        return cell!
    }
    
    func buildSuggestionCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: DTSearchViewController.suggestionCellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: DTSearchViewController.suggestionCellIdentifier)
        }
        
        if let suggestions = suggestionsResultList {
            //got search suggestions
            if let location : DTLocation = suggestions.object(at: indexPath[1]) as? DTLocation {
                cell?.textLabel?.text = location.name
            }
        } else {
            //add mock suggestions to table
            cell?.textLabel?.text = resultSearchController.searchBar.text
            
        }
        
        return cell!
    }
    
    func buildJourneyCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: DTSearchViewController.journeyCellIdentifier)
        
        if cell == nil {
            cell = Bundle.main.loadNibNamed("SearchResultCell", owner: self, options: nil)?[0] as? UITableViewCell
        }
        
        if let journey : DTJourney = resultList?.object(at: indexPath[1]) as? DTJourney {
            if let label = cell?.viewWithTag(1) as? UILabel {
                label.text = journey.name
            }
            if let label = cell?.viewWithTag(2) as? UILabel {
                label.text = String(format: "%@ - %@", (dateFormatterMedium?.string(from: journey.fromDate))!, (dateFormatterMedium?.string(from: journey.toDate))!)
            }
            if let label = cell?.viewWithTag(4) as? UILabel {
                label.text = String(format: "$%.2f", journey.amount)
            }
            if let image = cell?.viewWithTag(3) as? UIImageView {
                image.image = journey.image
            }
        }
        
        return cell!
    }
    
    func showDatePicker(_ tableView: UITableView, targetCell : UITableViewCell) {
        if datePicker.isHidden,
            let dateString = targetCell.detailTextLabel?.text,
            let date = dateFormatterMedium?.date(from: dateString),
            let datePickerSuperView = datePicker.superview{
            
            datePicker.date = date
            datePicker.isHidden = false
            //not adding to self.view.window as in eample code since it causes problems with different orientations
            view.addSubview(datePicker)
            
            // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
            // compute the start frame
            // not using [[UIScreen mainScreen] applicationFrame as in eample code since it causes problems with different orientations
            let screenRect : CGRect = view.bounds
            let pickerSize : CGSize = datePicker.sizeThatFits(CGSize.zero)
            let newPickerWidth : CGFloat = datePickerSuperView.frame.size.width
            let startRect : CGRect = CGRect(x: 0.0, y: screenRect.origin.y + screenRect.size.height, width: newPickerWidth, height: pickerSize.height)
            
            datePicker.frame = startRect
            
            // compute the end frame
            let pickerRect : CGRect = CGRect(x: 0.0, y: screenRect.origin.y + screenRect.size.height - pickerSize.height, width: newPickerWidth, height: pickerSize.height)
            
            // start the slide up animation
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            
            // we need to perform some post operations after the animation is complete
            UIView.setAnimationDelegate(self)
            
            datePicker.frame = pickerRect
            
            // shrink the table vertical size to make room for the date picker
            var newFrame : CGRect = tableView.frame
            newFrame.size.height -= datePicker.frame.size.height
            tableView.frame = newFrame
            UIView.commitAnimations()
            
            setDoneButtonState(true)
        }
    }
    
    func hideDatePicker() {
        if !datePicker.isHidden {
            let screenRect : CGRect = UIScreen.main.applicationFrame
            var endFrame : CGRect = datePicker.frame
            endFrame.origin.y = screenRect.origin.y + screenRect.size.height
            
            // start the slide down animation
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            
            // we need to perform some post operations after the animation is complete
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStop(#selector(hidePicker))
            
            datePicker.frame = endFrame
            UIView.commitAnimations()
            
            // grow the table back again in vertical size to make room for the date picker
            var newFrame : CGRect = resultTable.frame
            newFrame.size.height += datePicker.frame.size.height
            resultTable.frame = newFrame
            UIView.commitAnimations()
            
            setDoneButtonState(false)
            
            let indexPath = resultTable.indexPathForSelectedRow
            if let path = indexPath {
                resultTable.deselectRow(at: path, animated: true)
            }
        }
    }
    
    func updateSearchResults(for: UISearchController)
    {
        resultTable.reloadData()
    }
    
    // UISearchBarDelegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text,
            let fromDate = fromDate,
            let toDate = toDate {
            performSearchFor(destination: searchBarText, from: fromDate, to: toDate)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultList = nil
        if searchText.count <= 0  {
            suggestionsResultList = nil
            resultList = nil
        } else {
            performAutocompleteSearchFor(destination: searchText, checkForJourneys: true, maxResultSize: 20)
        }
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {

    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        resultList = nil
        doneAction(doneButton)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        suggestionsResultList = nil
        resultList = nil
        resultTable.reloadData()
    }
    
    // DTHandler delegate methods
    func operationFinished(_ data: NSObject!) {
        //check if we got correct data - else do not overwrite messages set by operatioFailed:
        if let result = data as? NSDictionary {
            var value = result.object(forKey: kFindJourneysResponse)
            if value != nil {
                // journey response
                resultList = NSMutableArray()
                let resultData = result.object(forKey: DTConstants.kResultData)
                if let data = resultData as? NSArray {
                    for case let journeyData as NSDictionary in data {
                        resultList?.add(parseJourney(withData: journeyData))
                    }
                }
                resultTable.reloadData()
            }
            
            value = result.object(forKey: DTConstants.kFindLocationResponse)
            if value != nil {
                // location response
                let requestId = result.value(forKey: REQUEST_ID) as? NSNumber
                var operationKey = result.value(forKey: OPERATION_KEY) as? String
                
                if(operationKey == nil){
                    operationKey = ""
                }
                
                if let reqId = requestId {
                    if reqId.intValue < lastLocationResponseId {
                        // JLT-52078 skip response if it would overwrite data of a newer response
                       NSLog("skipped response with id \(requestId?.uintValue ?? 0) because it was received after response with id \(lastLocationResponseId)")
                    } else {
                        lastLocationResponseId = reqId.intValue
                        suggestionsResultList = NSMutableArray()
                        let resultData = result.object(forKey: DTConstants.kResultData)
                        if let data = resultData as? NSArray {
                            for case let destinationData as NSDictionary in data {
                                suggestionsResultList?.add(parseDestination(withData: destinationData))
                            }
                        }

                        resultTable.reloadData()
                    }
                }
            }
        }
        
        //close action after reporting values
        cleanup()
    }
    
    func parseDestination(withData destionationData : NSDictionary) -> DTLocation{
        let destination = DTLocation()
        
        if let destinationName = destionationData.object(forKey: DTConstants.kName) as? String {
            destination.name = destinationName
        }
        if let destinationCreatedDate = destionationData.object(forKey: DTConstants.kCreated) as? String {
            destination.creationDate = DTUtils.date(from: destinationCreatedDate, withFormat: DTConstants.kDateFormat)
        }
        
        return destination
    }
    
    func parseJourney(withData journeyData : NSDictionary) -> DTJourney{
        let journey = DTJourney()
        
        if let journeyName = journeyData.object(forKey: DTConstants.kName) as? String {
            journey.name = journeyName
        }
        if let journeyId = journeyData.object(forKey: DTConstants.kId) as? NSString {
            journey.idNumber = Int(journeyId.intValue)
        }
        if let journeyAmount = journeyData.object(forKey: DTConstants.kAmount) as? NSString {
            journey.amount = Double(journeyAmount.doubleValue)
        }
        
        if let imageStr = journeyData.object(forKey: DTConstants.kPicture) as? String,
            let imageD = Data(base64Encoded: imageStr, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters),
            let image = UIImage(data: imageD) {
            journey.image = image
        } else {
            journey.image = DTUtils.missingImage()
        }
        
        let start = DTLocation()
        if let startData = journeyData.object(forKey: DTConstants.kStart) as? NSDictionary {
            if let startName = startData.object(forKey: DTConstants.kName) as? String {
                start.name = startName
            }
            if let startCreatedDate = startData.object(forKey: DTConstants.kCreated) as? String {
                start.creationDate = DTUtils.date(from: startCreatedDate, withFormat: DTConstants.kDateFormat)
            }
        }
        journey.start = start
        
        let destination = DTLocation()
        if let destinationData = journeyData.object(forKey: DTConstants.kDestination) as? NSDictionary {
            if let startName = destinationData.object(forKey: DTConstants.kName) as? String {
                destination.name = startName
            }
            if let destinationCreatedDate = destinationData.object(forKey: DTConstants.kCreated) as? String {
                destination.creationDate = DTUtils.date(from: destinationCreatedDate, withFormat: DTConstants.kDateFormat)
            }
        }
        journey.destination = destination
        
        let tenant = DTTenant()
        if let tenantData = journeyData.object(forKey: DTConstants.kTenant) as? NSDictionary {
            if let tenantName = tenantData.object(forKey: DTConstants.kName) as? String {
                tenant.name = tenantName
            }
            if let tenantPassword = tenantData.object(forKey: DTConstants.kPassword) as? String {
                tenant.password = tenantPassword
            }
            if let tenantDescription = tenantData.object(forKey: DTConstants.kDescription) as? String {
                tenant.tenantDescription = tenantDescription
            }
            if let tenantCreatedDate = tenantData.object(forKey: DTConstants.kCreated) as? String {
                tenant.created = DTUtils.date(from: tenantCreatedDate, withFormat: DTConstants.kDateFormat)
            }
            if let tenantLastLogin = tenantData.object(forKey: DTConstants.kLastLogin) as? String {
                tenant.lastLogin = DTUtils.date(from: tenantLastLogin, withFormat: DTConstants.kDateFormat)
            }
        }
        journey.tenant = tenant
        
        if let journeyFromDate = journeyData.object(forKey: DTConstants.kFromDate) as? String {
            journey.fromDate = DTUtils.date(from: journeyFromDate, withFormat: DTConstants.kDateFormat)
        }
        if let journeyFromDateTime = journeyData.object(forKey: DTConstants.kFromDateTime) as? String {
            journey.fromDateTime = DTUtils.date(from: journeyFromDateTime, withFormat: DTConstants.kDateTimeFormat)
        }
        
        if let journeyToDate = journeyData.object(forKey: DTConstants.kToDate) as? String {
            journey.toDate = DTUtils.date(from: journeyToDate, withFormat: DTConstants.kDateFormat)
        }
        if let journeyToDateTime = journeyData.object(forKey: DTConstants.kToDateTime) as? String {
            journey.toDateTime = DTUtils.date(from: journeyToDateTime, withFormat: DTConstants.kDateTimeFormat)
        }
        
        return journey
    }
    
    func operationFailed(_ data: NSObject!) {
        cleanup()
    }
    
    func parseXMLResponse(_ xmlData: Data!) -> [AnyHashable : Any]! {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        searchResult = NSMutableDictionary()
        searchResultArray = nil
        xmlCurrentDictionaryStack = NSMutableArray()
        xmlCurrentElementStack = NSMutableArray()
        
        if parser.parse() {
            return NSDictionary(dictionary: searchResult!) as! [AnyHashable : Any]
        }
        return nil
    }
    
    // NSXMLParser delegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
       NSLog("START element: \(elementName) nsURI: \(namespaceURI ?? "") qname: \(qName ?? "") attributes: \(attributeDict)")
        DTRestUtils.parseNamespacePrefix(attributeDict)
        xmlCurrentElementStack?.push(elementName)
        if kFindLocationResponse == elementName || kFindJourneysResponse == elementName {
            searchResult?.setObject(self, forKey: elementName as NSCopying)
        } else if DTConstants.kReturn == elementName {
            if searchResultArray == nil {
                searchResultArray = NSMutableArray()
                searchResult?.setObject(searchResultArray!, forKey: DTConstants.kResultData as NSCopying)
            }
            
            let currentDictionary = NSMutableDictionary()
            xmlCurrentDictionaryStack?.push(currentDictionary)
            currentDictionary.setObject(self, forKey: elementName as NSCopying)
            searchResultArray?.add(currentDictionary)
        } else if attributeDict[DTConstants.kAttributeKeyType] != nil {
            let newDictionary = NSMutableDictionary()
            // insert new dictionary into current dictionary
            let dict = xmlCurrentDictionaryStack?.peek() as? NSMutableDictionary
            dict?.setObject(newDictionary, forKey: elementName as NSCopying)
            xmlCurrentDictionaryStack?.push(newDictionary)
            
            // insert pop marker before current element
            _ = xmlCurrentElementStack?.pop()
            xmlCurrentElementStack?.push(DTConstants.kPopMarker)
            xmlCurrentElementStack?.push(elementName)
        } else {
            // insert element key with empty string value (more save than NSNull if parsed later)
            let dict = xmlCurrentDictionaryStack?.peek() as? NSMutableDictionary
            dict?.setObject(DTConstants.kEmptyString, forKey: elementName as NSCopying)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        NSLog("ELEMENT content: \(string)")
        if string.count > 0,
            let elementName = xmlCurrentElementStack?.peek() as? String{
            if kFindLocationResponse == elementName || kFindJourneysResponse == elementName {
                searchResult?.setObject(string, forKey: elementName as NSCopying)
            } else {
                let dict = xmlCurrentDictionaryStack?.peek() as? NSMutableDictionary
                dict?.setObject(string, forKey: elementName as NSCopying)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        NSLog("END element: \(elementName) nsURI: \(namespaceURI ?? "") qname: \(qName ?? "")")
        
        if let curStack = xmlCurrentElementStack {
            _ = curStack.pop()
            
            if let firstObj = curStack.firstObject as? String,
                curStack.count > 0 && DTConstants.kPopMarker == firstObj {
                _ = curStack.pop()
                _ = xmlCurrentDictionaryStack?.pop()
            } else if DTConstants.kReturn == elementName {
                _ = xmlCurrentDictionaryStack?.pop()
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
       NSLog("\(parseError.localizedDescription)")
    }
}
