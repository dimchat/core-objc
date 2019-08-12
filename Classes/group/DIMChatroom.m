//
//  DIMChatroom.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMChatroom.h"

@implementation DIMChatroom

#pragma mark Admins of Chatroom

- (NSArray<DIMID *> *)admins {
    NSAssert(_dataSource, @"chatroom data source not set yet");
    NSArray *list = [_dataSource adminsOfChatroom:_ID];
    return [list copy];
}

- (BOOL)existsAdmin:(DIMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(_dataSource, @"chatroom data source not set yet");
    NSArray<DIMID *> *admins = [self admins];
    NSInteger count = [admins count];
    if (count <= 0) {
        return NO;
    }
    DIMID *admin;
    while (--count >= 0) {
        admin = [admins objectAtIndex:count];
        if ([admin isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
