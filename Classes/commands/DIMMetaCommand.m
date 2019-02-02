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

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        _meta = nil;
    }
    return self;
}

- (instancetype)initWithID:(MKMID *)ID meta:(nullable MKMMeta *)meta {
    if (self = [self initWithCommand:@"meta"]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        _ID = ID;
        // meta
        if (meta) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        _meta = nil;
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

- (DIMID *)ID {
    if (!_ID) {
        id obj = [_storeDictionary objectForKey:@"ID"];
        if (!obj) {
            obj = [_storeDictionary objectForKey:@"identifier"];
        }
        _ID = [DIMID IDWithID:obj];
    }
    return _ID;
}

- (nullable DIMMeta *)meta {
    if (!_meta) {
        id obj = [_storeDictionary objectForKey:@"meta"];
        if (obj) {
            DIMMeta *meta = [DIMMeta metaWithMeta:obj];
            if ([meta matchID:self.ID]) {
                _meta = meta;
            }
        }
    }
    return _meta;
}

@end
