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

@implementation DIMCommand (Profile)

- (nullable DIMProfile *)profile {
    DIMProfile *p;
    NSObject *data = [_storeDictionary objectForKey:@"profile"];
    if ([data isKindOfClass:[NSDictionary class]]) {
        // (v1.1)
        //  profile (dictionary): {
        //      "ID"        : "{ID}",
        //      "data"      : "{...}",
        //      "signature" : "{BASE64}"
        //  }
        p = [DIMProfile profileWithProfile:data];
    } else if ([data isKindOfClass:[NSString class]]) {
        // (v1.0)
        //  profile data (JsON)
        //  profile signature (Base64)
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [mDict setObject:[self ID] forKey:@"ID"];
        [mDict setObject:data forKey:@"data"];
        NSString *sig = [_storeDictionary objectForKey:@"signature"];
        NSAssert(sig, @"signature not found");
        [mDict setObject:sig forKey:@"signature"];
        p = [DIMProfile profileWithProfile:mDict];
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
    return p;
}

@end

@implementation DIMProfileCommand

- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile {
    if (self = [self initWithCommand:DIMSystemCommand_Profile]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        // meta
        if ([meta matchID:ID]) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        
        // profile
        if ([profile.ID isEqual:ID]) {
            [_storeDictionary setObject:profile forKey:@"profile"];
        }
    }
    return self;
}

@end
