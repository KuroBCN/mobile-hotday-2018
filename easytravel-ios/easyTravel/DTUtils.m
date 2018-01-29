//
//  DTUtils.m
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2011-12-28.
//  Copyright (c) 2011 dynaTrace software. All rights reserved.
//

#import "DTUtils.h"

@implementation DTUtils

+ (void)initUserDefaults
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 EASYTRAVEL_HOST_DEFAULT, EASYTRAVEL_HOST,
                                 [NSNumber numberWithBool:REMEMBER_USER_DEFAULT], REMEMBER_USER,
                                 [NSNumber numberWithBool:CRASH_ON_LOGIN_DEFAULT], CRASH_ON_LOGIN,
                                 [NSNumber numberWithBool:ERRORS_ON_SEARCH_AND_BOOKING_DEFAULT], ERRORS_ON_SEARCH_AND_BOOKING,
                                 [NSNumber numberWithBool:FRONTEND_NOT_REACHABLE_DEFAULT], FRONTEND_NOT_REACHABLE,
                                 [NSNumber numberWithBool:YES], FIRST_LAUNCH,
                                 @"", ADK_MONITOR_SIGNAL_DESTINATION,
                                 nil];
    [standardUserDefaults registerDefaults:appDefaults];
}

+ (long long)secondsForTimeInterval:(NSTimeInterval)timeInterval
{
    return (long long)(timeInterval *1000);
}

+ (void)showErrorMessage:(NSString*)errorMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (NSDate*)dateFromString:(NSString*)dateString withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

static UIImage *sharedMissingImage = nil;   //display for PHAImage if no image is found (only alloc once)
+ (UIImage *)missingImage{
    if(sharedMissingImage == nil){
        sharedMissingImage = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"missingimage.png"]];   //only allocate once
    }
    return sharedMissingImage;
}

+ (NSString*)appName
{
    return @"easyTravel mobile";
}

#pragma mark -
#pragma mark global values for this app

static NSString *_userName = nil;

+ (NSString*)userName
{
    return _userName;
}

+ (void)setUserName:(NSString*)userName
{
    _userName = userName;
}

@end
