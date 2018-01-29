//
//  DTJourney.h
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2012-01-02.
//  Copyright (c) 2012 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DTLocation.h"
#import "DTTenant.h"

@interface DTJourney : NSObject

@property (strong, nonatomic) NSString* name;
@property NSInteger idNumber;
@property double amount;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) DTLocation* start;
@property (strong, nonatomic) DTLocation* destination;
@property (strong, nonatomic) DTTenant* tenant;
@property (strong, nonatomic) NSDate* fromDate;
@property (strong, nonatomic) NSDate* fromDateTime;
@property (strong, nonatomic) NSDate* toDate;
@property (strong, nonatomic) NSDate* toDateTime;

@end
