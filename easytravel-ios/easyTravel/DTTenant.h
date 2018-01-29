//
//  DTTenant.h
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2012-01-05.
//  Copyright (c) 2012 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTTenant : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* tenantDescription;    //description would override readonly NSObject.description
@property (strong, nonatomic) NSDate* created;
@property (strong, nonatomic) NSDate* lastLogin;
          
@end
