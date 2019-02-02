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

#import "DIMProfileCommand.h"

@interface DIMProfileCommand ()

@property (strong, nonatomic) DIMID *ID;
@property (strong, nonatomic, nullable) DIMProfile *profile;
@property (strong, nonatomic, nullable) NSData *signature;

@end

@implementation DIMProfileCommand

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        _profile = nil;
        _signature = nil;
    }
    return self;
}

- (instancetype)initWithID:(DIMID *)ID
                   profile:(nullable NSString *)profileString
                 signature:(nullable NSString *)signatureString {
    if (self = [self initWithCommand:@"profile"]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        _ID = ID;
        // profile
        if (profileString) {
            [_storeDictionary setObject:profileString forKey:@"profile"];
        }
        _profile = nil;
        // signature
        if (signatureString) {
            [_storeDictionary setObject:signatureString forKey:@"signature"];
        }
        _signature = nil;
    }
    return self;
}

- (instancetype)initWithID:(DIMID *)ID
                privateKey:(DIMPrivateKey *)SK
                   profile:(DIMProfile *)profile {
    NSString *jsonString = [profile jsonString];
    NSData *data = [jsonString data];
    data = [SK sign:data];
    NSString *signature = [data base64Encode];
    if (self = [self initWithID:ID profile:jsonString signature:signature]) {
        _profile = profile;
        _signature = data;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMProfileCommand *command = [super copyWithZone:zone];
    if (command) {
        command.ID = _ID;
        command.profile = _profile;
        command.signature = _signature;
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

- (nullable DIMProfile *)profile {
    if (!_profile) {
        NSString *json = [_storeDictionary objectForKey:@"profile"];
        NSString *base64 = [_storeDictionary objectForKey:@"signature"];
        if (json && base64) {
            DIMID *ID = self.ID;
            DIMMeta *meta = MKMMetaForID(ID);
            NSData *data = [json data];
            NSData *sig = [base64 base64Decode];
            if ([meta.key verify:data withSignature:sig]) {
                _profile = [DIMProfile profileWithProfile:json];
                _signature = sig;
            }
        }
    }
    return _profile;
}

- (nullable NSData *)signature {
    if (!_signature) {
        if ([self profile]) {
            //
        }
    }
    return _signature;
}

@end
