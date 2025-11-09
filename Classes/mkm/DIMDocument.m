// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMDocument.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMVisa.h"
#import "DIMBulletin.h"

#import "DIMDocument.h"

NSString * const MKMDocumentType_Visa     = @"visa";
NSString * const MKMDocumentType_Profile  = @"profile";
NSString * const MKMDocumentType_Bulletin = @"bulletin";

@interface DIMDocument ()

@property (strong, nonatomic) id<MKMID> identifier;

// JsON.encode(properties)
@property (strong, nonatomic) NSString *data;
// User(ID).sign(data)
@property (strong, nonatomic) id<MKTransportableData> CT;

@property (strong, nonatomic) NSMutableDictionary *properties;

// 1 for valid, -1 for invalid
@property (nonatomic) NSInteger status;

@end

@implementation DIMDocument

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _identifier = nil;
        
        _data = nil;
        _CT = nil;
        
        _properties = nil;

        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithIdentifier:(id<MKMID>)did
                              data:(NSString *)json
                         signature:(id<MKTransportableData>)CT {
    NSDictionary *dict = @{
        @"did": [did string],
        @"data": json,
        @"signature": [CT object],
    };
    if (self = [super initWithDictionary:dict]) {
        _identifier = did;

        _data = json;
        _CT = CT;
        
        _properties = nil;  // lazy

        // all documents must be verified before saving into local storage
        _status = 1;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithIdentifier:(id<MKMID>)did type:(NSString *)type {
    NSDictionary *dict = @{
        @"did": [did string],
    };
    if (self = [super initWithDictionary:dict]) {
        _identifier = did;
        
        _data = nil;
        _CT = nil;
        
        // initialize properties with created time
        NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        [info setObject:type forKey:@"type"];  // deprecated
        [info setObject:@(now) forKey:@"created_time"];
        _properties = info;

        _status = 0;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMDocument *doc = [super copyWithZone:zone];
    if (doc) {
        doc.identifier = _identifier;
        doc.data = _data;
        doc.CT = _CT;
        doc.properties = _properties;
        doc.status = _status;
    }
    return doc;
}

// Override
- (BOOL)isValid {
    return _status > 0;
}

// Override
- (id<MKMID>)identifier {
    if (!_identifier) {
        _identifier = MKMIDParse([self objectForKey:@"did"]);
    }
    return _identifier;
}

// Get serialized properties
- (NSString *)data {
    if (!_data) {
        _data = [self stringForKey:@"data" defaultValue:nil];
    }
    return _data;
}

// Get signature for serialized properties
- (NSData *)signature {
    id<MKTransportableData> ted = _CT;
    if (!ted) {
        id text = [self objectForKey:@"signature"];
        _CT = ted = MKTransportableDataParse(text);
    }
    return [ted data];
}

// Override
- (NSMutableDictionary *)properties {
    if (_status < 0) {
        // document invalid
        return nil;
    }
    if (!_properties) {
        NSString *data = [self data];
        if ([data length] > 0) {
            NSDictionary *dict = MKJsonMapDecode(data);
            NSAssert(dict, @"document data error: %@", data);
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                _properties = (NSMutableDictionary *)dict;
            } else {
                _properties = [dict mutableCopy];
            }
        } else {
            // create new properties
            _properties = [[NSMutableDictionary alloc] init];
        }
    }
    return _properties;
}

// Override
- (NSArray *)propertyKeys {
    return [self.properties allKeys];
}

// Override
- (nullable id)propertyForKey:(NSString *)key {
    NSObject *property = [self.properties objectForKey:key];
    if (property == [NSNull null]) {
        return nil;
    }
    return property;
}

// Override
- (void)setProperty:(nullable id)value forKey:(NSString *)key {
    // 1. reset status
    NSAssert(_status >= 0, @"status error: %@", self);
    _status = 0;
    
    // 2. update property value with name
    NSMutableDictionary *mDict = self.properties;
    NSAssert(mDict, @"failed to get properties: %@", self);
    if (value) {
        [mDict setObject:value forKey:key];
    } else {
        [mDict removeObjectForKey:key];
    }
    
    // 3. clear data signature after properties changed
    [self removeObjectForKey:@"data"];
    [self removeObjectForKey:@"signature"];
    _data = nil;
    _CT = nil;
}

// Override
- (BOOL)verify:(id<MKVerifyKey>)PK {
    if (_status > 0) {
        // already verify OK
        return YES;
    }
    NSString *data = self.data;
    NSData *signature = self.signature;
    if ([data length] == 0) {
        // NOTICE: if data is empty, signature should be empty at the same time
        //         this happen while document not found
        if ([signature length] == 0) {
            _status = 0;
        } else {
            // data signature error
            _status = -1;
        }
    } else if ([signature length] == 0) {
        // signature error
        _status = -1;
    } else if ([PK verify:MKUTF8Encode(data) withSignature:signature]) {
        // signature matched
        _status = 1;
    }
    // NOTICE: if status is 0, it doesn't mean the document is invalid,
    //         try another key
    return _status == 1;
}

// Override
- (NSData *)sign:(id<MKSignKey>)SK {
    NSData *sig;
    if (_status > 0) {
        // already signed/verified
        NSAssert([_data length] > 0, @"document data error");
        sig = [self signature];
        NSAssert([sig length] > 0, @"document signature error");
        return sig;
    }
    // 1. update sign time
    NSTimeInterval now = [[[NSDate alloc] init] timeIntervalSince1970];
    [self setProperty:@(now) forKey:@"time"];
    // 2. encode & sign
    NSDictionary *info = [self properties];
    if (!info) {
        NSAssert(false, @"document invalid: %@", self.dictionary);
        return nil;
    }
    NSString *data = MKJsonEncode(info);
    if ([data length] == 0) {
        NSAssert(false, @"should not happen: %@", info);
        return nil;
    }
    sig = [SK sign:MKUTF8Encode(data)];
    if ([sig length] == 0) {
        NSAssert(false, @"should not happen");
        return nil;
    }
    id<MKTransportableData> ted = MKTransportableDataCreate(sig, nil);
    // 3. update 'data' & 'signature' fields
    [self setObject:data forKey:@"data"];
    [self setObject:ted.object forKey:@"signature"];
    _data = data;
    _CT = ted;
    // 4. update status
    _status = 1;
    return sig;
}

#pragma mark properties getter/setter

// Override
- (NSDate *)time {
    // timestamp
    id seconds = [self propertyForKey:@"time"];
    return MKConvertDate(seconds, nil);
}

// Override
- (NSString *)name {
    id text = [self propertyForKey:@"name"];
    return MKConvertString(text, nil);
}

// Override
- (void)setName:(NSString *)name {
    [self setProperty:name forKey:@"name"];
}

@end
