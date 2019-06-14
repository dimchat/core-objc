//
//  DIMProfileCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMBarrack.h"

#import "DIMProfileCommand.h"

@interface DIMProfileCommand ()

@property (strong, nonatomic, nullable) DIMProfile *profile;

@end

@implementation DIMProfileCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _profile = nil;
    }
    return self;
}

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [super initWithCommand:cmd]) {
        // lazy
        _profile = nil;
    }
    return self;
}

- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile {
    if (self = [self initWithCommand:DKDSystemCommand_Profile]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        // meta
        _meta = meta;
        if ([meta matchID:ID]) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        
        // profile
        _profile = profile;
        if ([profile.ID isEqual:ID]) {
            [_storeDictionary setObject:profile forKey:@"profile"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMProfileCommand *command = [super copyWithZone:zone];
    if (command) {
        command.profile = _profile;
    }
    return command;
}

- (nullable DIMProfile *)profile {
    if (!_profile) {
        NSObject *data = [_storeDictionary objectForKey:@"profile"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            // (v1.1)
            //  profile (dictionary): {
            //      "ID"        : "{ID}",
            //      "data"      : "{...}",
            //      "signature" : "{BASE64}"
            //  }
            _profile = [DIMProfile profileWithProfile:data];
        } else if ([data isKindOfClass:[NSString class]]) {
            // (v1.0)
            //  profile data (JsON)
            //  profile signature (Base64)
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            [mDict setObject:_ID forKey:@"ID"];
            [mDict setObject:data forKey:@"data"];
            NSString *sig = [_storeDictionary objectForKey:@"signature"];
            NSAssert(sig, @"signature not found");
            [mDict setObject:sig forKey:@"signature"];
            _profile = [DIMProfile profileWithProfile:mDict];
        }
    }
    /*
    // verify profile
    if (_profile) {
        DIMBarrack *barrack = [DIMBarrack sharedInstance];
        DIMMeta *meta = DIMMetaWithID(_ID);
        if (![_profile verify:meta.key]) {
            NSAssert(false, @"profile's signature not match: %@", _storeDictionary);
            _profile = nil;
        }
    }
     */
    return _profile;
}

@end
