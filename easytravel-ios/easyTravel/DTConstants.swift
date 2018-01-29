//
//  Constants.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

class DTConstants {
    static let kKeychainIdentifier = "com.dynaTrace.easyTravel.login"
    
    static let LOGIN_ERROR = "LoginError"
    static let LOGIN_FAILED = "LoginFailed"
    static let LOGIN_SUCCESSFUL = "LoginSuccessful"
    static let LOGIN_ACTION = "performLogin"
    static let LOGIN_ANIMATION_ACTION = "animateLogin"
    
    static let BOOK_JOURNEY = "bookJourney"
    static let BOOKING_PRICE = "bookJourneyAmount"
    static let BOOKING_DESTINATION = "bookJourneyDestination"
    static let BOOKING_ERROR = "BookingError"
    static let BOOKING_FAILED = "BookingFailed"
    
    static let kDateFormat = "yyyy'-'mm'-'dd"
    static let kDateTimeFormat = "yyyy'-'mm'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    
    static let SEARCH_PARENT_ACTION = "performSearch"
    static let SEARCH_JOURNEY = "performSearchForDestination"
    static let SEARCH_JOURNEY_NAMES_PARENT_ACTION = "performSearchForDestinationNamesParent"
    static let SEARCH_JOURNEY_NAMES_AS_YOU_TYPE = "performSearchAsYouTypeForDestinationNames"
    static let SEARCH_CANCELED = "searchCanceled"
    static let JOURNEYS_FOUND = "JourneysFound"
    static let NO_JOURNEYS_FOUND = "NoJourneysFound"
    static let SEARCH_ERROR = "SearchError"
    
    static let kResultData = "resultData";
    static let kPopMarker = "popRequired";
    static let kEmptyString = "";
    
    // DTRestUtils -> no macros in Swift
    static let SERVICES_PATH = "/services"
    static let AUTH_SERVICE = "AuthenticationService"
    static let JOURNEY_SERVICE = "JourneyService"
    static let BOOKING_SERVICE = "BookingService"
    static let AUTHENTICATE = "authenticate"
    static let FIND_LOCATIONS = "findLocations"
    static let FIND_JOURNEYS = "findJourneys"
    static let STORE_BOOKING = "storeBooking"
    
    static let NAMESPACE_URL_BUSINESS_JPA = "http://business.jpa.easytravel.dynatrace.com/xsd"  //currently xmlns:ax212
    static let NAMESPACE_URL_JPA = "http://jpa.easytravel.dynatrace.com/xsd"   //currently xmlns:ax213
    static let NAMESPACE_URL_TRANSFEROBJ_WEBSERVICE_BUSINESS = "http://transferobj.webservice.business.easytravel.dynatrace.com/xsd"   //currently xmlns:ax216
    static let NAMESPACE_URL_WEBSERVICE_BUSINESS = "http://webservice.business.easytravel.dynatrace.com"   //xmlns:ns
    
    static let kFindLocationResponse = "ns:findLocationsResponse"
    static let kFindJourneysResponse = "ns:findJourneysResponse"
    static let kAuthentictionResponse = "ns:authenticateResponse"
    static let kStoreBookingResponse = "ns:storeBookingResponse"
    
    static let kReturn = String(format: "%@:return", DTRestUtils.nsWebserviceBusinessPrefix())
    static let kName = String(format: "%@:name", DTRestUtils.nsBusinessJpaPrefix())
    static let kDestination = String(format: "%@:destination", DTRestUtils.nsBusinessJpaPrefix())
    static let kPassword = String(format: "%@:password", DTRestUtils.nsBusinessJpaPrefix())
    static let kId = String(format: "%@:id", DTRestUtils.nsBusinessJpaPrefix())
    static let kPicture = String(format: "%@:picture", DTRestUtils.nsBusinessJpaPrefix())
    static let kStart = String(format: "%@:start", DTRestUtils.nsBusinessJpaPrefix())
    static let kAmount = String(format: "%@:amount", DTRestUtils.nsBusinessJpaPrefix())
    static let kFromDate = String(format: "%@:fromDate", DTRestUtils.nsBusinessJpaPrefix())
    static let kFromDateTime = String(format: "%@:fromDateTime", DTRestUtils.nsBusinessJpaPrefix())
    static let kToDate = String(format: "%@:toDate", DTRestUtils.nsBusinessJpaPrefix())
    static let kToDateTime = String(format: "%@:toDateTime", DTRestUtils.nsBusinessJpaPrefix())
    static let kTenant = String(format: "%@:tenant", DTRestUtils.nsBusinessJpaPrefix())
    static let kDescription = String(format: "%@:description", DTRestUtils.nsBusinessJpaPrefix())
    static let kLastLogin = String(format: "%@:lastLogin", DTRestUtils.nsBusinessJpaPrefix())
    static let kCreated = String(format: "%@:created", DTRestUtils.nsJpaPrefix())
    
    static let kAttributeKeyType = "xsi:type"
    static let kPrefixXMLNS = "xmlns:"
    static let kAttributeTenant = String(format: "%=:Tenant", DTRestUtils.nsBusinessJpaPrefix())
    static let kAttributeLocation = String(format: "%=:Location", DTRestUtils.nsBusinessJpaPrefix())
}
