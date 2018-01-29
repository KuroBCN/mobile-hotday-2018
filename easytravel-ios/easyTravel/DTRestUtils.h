//
//  DTRestUtils.h
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2011-12-22.
//  Copyright (c) 2011 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResultHandler.h"

#define SERVICES_PATH @"/services"
#define AUTH_SERVICE @"AuthenticationService"
#define JOURNEY_SERVICE @"JourneyService"
#define BOOKING_SERVICE @"BookingService"
#define AUTHENTICATE @"authenticate"
#define FIND_LOCATIONS @"findLocations"
#define FIND_JOURNEYS @"findJourneys"
#define STORE_BOOKING @"storeBooking"

#define NAMESPACE_URL_BUSINESS_JPA @"http://business.jpa.easytravel.dynatrace.com/xsd"  //currently xmlns:ax212
#define NAMESPACE_URL_JPA @"http://jpa.easytravel.dynatrace.com/xsd"   //currently xmlns:ax213
#define NAMESPACE_URL_TRANSFEROBJ_WEBSERVICE_BUSINESS @"http://transferobj.webservice.business.easytravel.dynatrace.com/xsd"   //currently xmlns:ax216
#define NAMESPACE_URL_WEBSERVICE_BUSINESS @"http://webservice.business.easytravel.dynatrace.com"   //xmlns:ns

#define kFindLocationResponse @"ns:findLocationsResponse"
#define kFindJourneysResponse @"ns:findJourneysResponse"
#define kAuthentictionResponse @"ns:authenticateResponse"
#define kStoreBookingResponse @"ns:storeBookingResponse"

#define kReturn() [NSString stringWithFormat:@"%@:return", [DTRestUtils nsWebserviceBusinessPrefix]]
#define kName() [NSString stringWithFormat:@"%@:name", [DTRestUtils nsBusinessJpaPrefix]]
#define kDestination() [NSString stringWithFormat:@"%@:destination", [DTRestUtils nsBusinessJpaPrefix]]
#define kPassword() [NSString stringWithFormat:@"%@:password", [DTRestUtils nsBusinessJpaPrefix]]
#define kId() [NSString stringWithFormat:@"%@:id", [DTRestUtils nsBusinessJpaPrefix]]
#define kPicture() [NSString stringWithFormat:@"%@:picture", [DTRestUtils nsBusinessJpaPrefix]]
#define kStart() [NSString stringWithFormat:@"%@:start", [DTRestUtils nsBusinessJpaPrefix]]
#define kAmount() [NSString stringWithFormat:@"%@:amount", [DTRestUtils nsBusinessJpaPrefix]]
#define kFromDate() [NSString stringWithFormat:@"%@:fromDate", [DTRestUtils nsBusinessJpaPrefix]]
#define kFromDateTime() [NSString stringWithFormat:@"%@:fromDateTime", [DTRestUtils nsBusinessJpaPrefix]]
#define kToDate() [NSString stringWithFormat:@"%@:toDate", [DTRestUtils nsBusinessJpaPrefix]]
#define kToDateTime() [NSString stringWithFormat:@"%@:toDateTime", [DTRestUtils nsBusinessJpaPrefix]]
#define kTenant() [NSString stringWithFormat:@"%@:tenant", [DTRestUtils nsBusinessJpaPrefix]]
#define kDescription() [NSString stringWithFormat:@"%@:description", [DTRestUtils nsBusinessJpaPrefix]]
#define kLastLogin() [NSString stringWithFormat:@"%@:lastLogin", [DTRestUtils nsBusinessJpaPrefix]]
#define kCreated() [NSString stringWithFormat:@"%@:created", [DTRestUtils nsJpaPrefix]]

#define kAttributeKeyType @"xsi:type"
#define kPrefixXMLNS @"xmlns:"
#define kAttributeTenant() [NSString stringWithFormat:@"%@:Tenant", [DTRestUtils nsBusinessJpaPrefix]]
#define kAttributeLocation() [NSString stringWithFormat:@"%@:Location", [DTRestUtils nsBusinessJpaPrefix]]

@interface DTRestUtils : NSObject {
@private
    unsigned long long _requestId;  //used to prevent mixup of request order for parallel reqests returning in other order as they were sent (e.g. different speed of autocomplete results, depending on result size)
    NSString* _operationKey;
}

@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableData* data;
@property (strong, nonatomic) NSObject<DTResultHandler>* delegate;
@property BOOL silent;
@property (nonatomic) SEL finishedSelecteor;
@property (nonatomic) SEL failedSelecteor;

- (id)initWithDelegate:(NSObject<DTResultHandler>*)delegate showErrors:(BOOL)silent;

+ (NSString*)nsBusinessJpaPrefix;
+ (NSString*)nsJpaPrefix;
+ (NSString*)nsTransferobjWebserviceBusinessPrefix;
+ (NSString*)nsWebserviceBusinessPrefix;

+ (NSString*)urlEncode:(NSString *)str;
+ (NSURL*)createURLformHost:(NSString*)host withPort:(NSString*)port forService:(NSString*)service forOperation:(NSString*)operation withParameters:(NSDictionary*)params;
+ (void)parseNamespacePrefix:(NSDictionary *)attributeDict;

+ (NSString*)getEasyTravelHost;
+ (NSString*)getEasyTravelPort;

- (void)performOperation:(NSString*)operation ofService:(NSString*)service withParameters:(NSDictionary*)params withKey:(NSString*)key;
- (void)handleError:(NSError *)error;

@end
