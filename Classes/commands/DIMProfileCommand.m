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

- (instancetype)initWithID:(DIMID *)ID {
    return [self initWithID:ID meta:nil profile:nil];
}

- (instancetype)initWithID:(DIMID *)ID profile:(DIMProfile *)profile {
    return [self initWithID:ID meta:nil profile:profile];
}

- (instancetype)initWithID:(DIMID *)ID
                      meta:(nullable DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile {
    if (self = [self initWithCommand:DIMSystemCommand_Profile]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        // meta
        if (meta) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        
        // profile
        if (profile) {
            [_storeDictionary setObject:profile forKey:@"profile"];
        }
        _profile = profile;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _profile = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMProfileCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.profile = _profile;
    }
    return cmd;
}

- (nullable DIMProfile *)profile {
    if (_profile) {
        return _profile;
    }
    DIMProfile *p = nil;
    NSObject *data = [_storeDictionary objectForKey:@"profile"];
    if ([data isKindOfClass:[NSDictionary class]]) {
        // (v1.1)
        //  'ID'      : '{ID}',
        //  'profile' : {
        //      "ID"        : "{ID}",
        //      "data"      : "{JsON}",
        //      "signature" : "{BASE64}"
        //  }
        p = MKMProfileFromDictionary(data);
        if (![p.ID isEqual:self.ID]) {
            NSAssert(false, @"profile error: %@", self);
            return nil;
        }
        
        if (p != data) {
            // replace the profile object
            NSAssert([p isKindOfClass:[DIMProfile class]], @"profile error: %@", data);
            [_storeDictionary setObject:p forKey:@"profile"];
        }
    } else if ([data isKindOfClass:[NSString class]]) {
        DIMID *ID = self.ID;
        NSString *signature = [_storeDictionary objectForKey:@"signature"];
        if (![ID isValid] || [signature length] == 0) {
            NSAssert(false, @"profile ID/signature error: %@", self);
            return nil;
        }
        // (v1.0)
        //  'ID'        : '{ID}',
        //  'profile'   : '{JsON}',
        //  'signature' : '{BASE64}'
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [mDict setObject:ID forKey:@"ID"];
        [mDict setObject:data forKey:@"data"];
        [mDict setObject:signature forKey:@"signature"];
        p = MKMProfileFromDictionary(mDict);
    }
    /*
    // verify profile
    if (_profile) {
        DIMBarrack *barrack = [DIMBarrack sharedInstance];
        DIMMeta *meta = DIMMetaWithID(_ID);
        if (![_profile verify:meta.key]) {
            NSAssert(false, @"profile's signature not match: %@", _storeDictionary);
            p = nil;
        }
    }
     */
    _profile = p;
    return _profile;
}

@end
