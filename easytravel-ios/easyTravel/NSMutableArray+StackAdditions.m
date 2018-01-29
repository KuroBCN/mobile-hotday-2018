//
//  NSMutbaleArray+StackAdditions.m
//  CompuwareUEM
//
//  Created by Patrick Haruksteiner on 2011-10-24.
//  Copyright 2011 dynaTrace software. All rights reserved.
//

#import "NSMutableArray+StackAdditions.h"


@implementation NSMutableArray (StackAdditions)

- (void)push:(id)object
{
    [self insertObject:object atIndex:0];
}

/*
 * return value is retained - caller has to take care of release
 */
- (id)pop
{
    id element = [self peek];
    [self removeObjectAtIndex:0];
    return element;
}

/*
 * return value is retained - caller has to take care of release
 */
- (NSArray *)pop:(NSUInteger)count
{
    NSRange range = NSMakeRange(0, count);
    NSArray *elementsToPop = [self subarrayWithRange:range];
    [self removeObjectsInRange:range];
    return elementsToPop;
}

- (id)peek
{
    if([self isEmpty]){
        [NSException raise:@"EmptyStack" format:@"stack %@ is empty", self];
    }
    return [self objectAtIndex:0];
}

- (BOOL)isEmpty
{
    return ([self count] < 1);
}

@end
