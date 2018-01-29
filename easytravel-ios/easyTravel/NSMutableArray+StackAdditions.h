//
//  NSMutbaleArray+StackAdditions.h
//  CompuwareUEM
//
//  Created by Patrick Haruksteiner on 2011-10-24.
//  Copyright 2011 dynaTrace software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (StackAdditions)

- (void)push:(id)object;
- (id)pop;
- (NSArray *)pop:(NSUInteger)count;
- (id)peek;
- (BOOL)isEmpty;

@end
