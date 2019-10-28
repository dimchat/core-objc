//
//  DIMMetaCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

@interface DIMMetaCommand ()

@property (strong, nonatomic) DIMID *ID;
@property (strong, nonatomic, nullable) DIMMeta *meta;

@end

@implementation DIMMetaCommand

- (instancetype)initWithID:(DIMID *)ID {
    return [self initWithID:ID meta:nil];
}

- (instancetype)initWithID:(DIMID *)ID
                      meta:(nullable DIMMeta *)meta {
    if (self = [self initWithCommand:DIMCommand_Meta]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        _ID = ID;
        
        // meta
        if (meta) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        _meta = meta;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        _meta = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMMetaCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.ID = _ID;
        cmd.meta = _meta;
    }
    return cmd;
}

- (DIMID *)ID {
    if (!_ID) {
        _ID = MKMIDFromString([_storeDictionary objectForKey:@"ID"]);
    }
    return _ID;
}

- (nullable DIMMeta *)meta {
    if (_meta) {
        return _meta;
    }
    NSDictionary *dict = [_storeDictionary objectForKey:@"meta"];
    DIMMeta *m = MKMMetaFromDictionary(dict);
    // check whether match ID
    if (![m matchID:self.ID]) {
        NSAssert(m == nil, @"meta not match ID: %@, %@", self.ID, m);
        return nil;
    }
    if (m != dict) {
        // replace the meta object
        NSAssert([m isKindOfClass:[DIMMeta class]], @"meta error: %@", dict);
        [_storeDictionary setObject:m forKey:@"meta"];
    }
    _meta = m;
    return _meta;
}

@end
