//
//  DIMMetaCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

@implementation DIMCommand (Meta)

- (const DIMID *)ID {
    NSString *str = [_storeDictionary objectForKey:@"ID"];
    return [DIMID IDWithID:str];
}

- (nullable const DIMMeta *)meta {
    NSDictionary *dict = [_storeDictionary objectForKey:@"meta"];
    DIMMeta *m = [DIMMeta metaWithMeta:dict];
    if ([m matchID:self.ID]) {
        return m;
    } else {
        NSAssert(m == nil, @"meta not match ID: %@, %@", self.ID, m);
        return nil;
    }
}

@end

@implementation DIMMetaCommand

- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta {
    if (self = [self initWithCommand:DIMSystemCommand_Meta]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        // meta
        if ([meta matchID:ID]) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
    }
    return self;
}

@end
