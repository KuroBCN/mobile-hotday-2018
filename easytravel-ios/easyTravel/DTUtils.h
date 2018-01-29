//
//  DTUtils.h
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2011-12-28.
//  Copyright (c) 2011 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTRestUtils.h"

#define EASYTRAVEL_HOST @"easyTravelHost"
#define EASYTRAVEL_HOST_DEFAULT @"localhost"
#define EASYTRAVEL_PORT @"easyTravelServicePort"
#define EASYTRAVEL_PORT_DEFAULT 8080
#define ADK_MONITOR_SIGNAL_DESTINATION @"adkMonitorSignalDestination"
#define REMEMBER_USER @"rememberUser"
#define REMEMBER_USER_DEFAULT NO
#define CRASH_ON_LOGIN @"crashOnLogin"
#define CRASH_ON_LOGIN_DEFAULT NO
#define ERRORS_ON_SEARCH_AND_BOOKING @"errorsOnSearchAndBooking"
#define ERRORS_ON_SEARCH_AND_BOOKING_DEFAULT NO
#define FRONTEND_NOT_REACHABLE @"frontendNotReachable"
#define FRONTEND_NOT_REACHABLE_DEFAULT NO
#define REQUEST_ID @"reuestId"
#define OPERATION_KEY @"operationKey"
#define RESULT_SIZE @"resultSize"
#define RESULT_SKIPPED @"resultSkipped"
#define FIRST_LAUNCH @"firstLaunch"

@interface DTUtils : NSObject

@property NSString *userName;   //can be nil if not logged in

+ (void)initUserDefaults;
+ (long long)secondsForTimeInterval:(NSTimeInterval)timeInterval;
+ (void)showErrorMessage:(NSString*)errorMessage;
+ (NSDate*)dateFromString:(NSString*)dateString withFormat:(NSString*)format;
+ (UIImage*)missingImage;

+ (NSString*)appName;

//global values for this app
+ (NSString*)userName;
+ (void)setUserName:(NSString*)userName;

@end

