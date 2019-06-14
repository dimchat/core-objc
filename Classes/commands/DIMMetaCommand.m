//
//  DIMMetaCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

@interface DIMMetaCommand ()

@property (strong, nonatomic) const DIMID *ID;
@property (strong, nonatomic, nullable) const DIMMeta *meta;

@end

@implementation DIMMetaCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        _meta = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [super initWithCommand:cmd]) {
        // lazy
        _ID = nil;
        _meta = nil;
    }
    return self;
}

- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta {
    if (self = [self initWithCommand:DKDSystemCommand_Meta]) {
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

- (id)copyWithZone:(NSZone *)zone {
    DIMMetaCommand *command = [super copyWithZone:zone];
    if (command) {
        command.ID = _ID;
        command.meta = _meta;
    }
    return command;
}

- (const DIMID *)ID {
    if (!_ID) {
        NSString *str = [_storeDictionary objectForKey:@"ID"];
        _ID = [DIMID IDWithID:str];
        
        if (_ID != str) {
            if (_ID) {
                // replace the ID object
                [_storeDictionary setObject:_ID forKey:@"ID"];
            } else {
                NSAssert(false, @"ID error: %@", str);
                //[_storeDictionary removeObjectForKey:@"ID"];
            }
        }
    }
    return _ID;
}

- (nullable const DIMMeta *)meta {
    if (!_meta) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"meta"];
        DIMMeta *m = [DIMMeta metaWithMeta:dict];
        if (![m matchID:self.ID]) {
            NSAssert(m == nil, @"meta not match ID: %@, %@", self.ID, m);
            return nil;
        }
        if (m != dict) {
            // replace the meta object
            [_storeDictionary setObject:m forKey:@"meta"];
        }
        
        _meta = m;
    }
    return _meta;
}

@end
