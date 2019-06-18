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

- (nullable DIMProfile *)profile {
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
    } else if ([data isKindOfClass:[NSString class]]) {
        const DIMID *ID = [self ID];
        NSAssert(ID, @"ID not found");
        NSString *signature = [_storeDictionary objectForKey:@"signature"];
        NSAssert(signature, @"signature not found");
        // (v1.0)
        //  'ID'        : '{ID}',
        //  'profile'   : '{JsON}',
        //  'signature' : '{BASE64}'
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [mDict setObject:[self ID] forKey:@"ID"];
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
    return p;
}

@end
