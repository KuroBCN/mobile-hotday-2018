//
//  DTResultHandler.h
//  easyTravel
//
//  Created by Patrick Haruksteiner on 2011-12-27.
//  Copyright (c) 2011 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTResultHandler <NSXMLParserDelegate>

- (void)operationFinished:(NSObject*)data;
- (void)operationFailed:(NSObject*)data;
- (NSDictionary*)parseXMLResponse:(NSData *)xmlData;  

@end
