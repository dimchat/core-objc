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

#import "DIMDocs.h"

#import "DIMDocument.h"

@interface DIMDocument ()

@property (strong, nonatomic) id<MKMID> ID;

// JsON.encode(properties)
@property (strong, nonatomic) NSString *data;
// User(ID).sign(data)
@property (strong, nonatomic) id<MKMTransportableData> CT;

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
        _ID = nil;
        
        _data = nil;
        _CT = nil;
        
        _properties = nil;

        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID
                      data:(NSString *)json
                 signature:(id<MKMTransportableData>)CT {
    NSDictionary *dict = @{
        @"ID": [ID string],
        @"data": json,
        @"signature": [CT object],
    };
    if (self = [super initWithDictionary:dict]) {
        _ID = ID;

        _data = json;
        _CT = CT;
        
        _properties = nil;  // lazy

        // all documents must be verified before saving into local storage
        _status = 1;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    NSDictionary *dict = @{
        @"ID": [ID string],
    };
    if (self = [super initWithDictionary:dict]) {
        _ID = ID;
        
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
        doc.ID = _ID;
        doc.data = _data;
        doc.CT = _CT;
        doc.properties = _properties;
        doc.status = _status;
    }
    return doc;
}

- (BOOL)isValid {
    return _status > 0;
}

- (NSString *)type {
    NSString *docType = [self propertyForKey:@"type"];  // deprecated
    if (!docType) {
        MKMFactoryManager *man = [MKMFactoryManager sharedManager];
        docType = [man.generalFactory documentType:self.dictionary
                                      defaultValue:nil];
    }
    return docType;
}

- (id<MKMID>)ID {
    if (!_ID) {
        _ID = MKMIDParse([self objectForKey:@"ID"]);
    }
    return _ID;
}

- (NSString *)data {
    if (!_data) {
        _data = [self stringForKey:@"data" defaultValue:nil];
    }
    return _data;
}

- (NSData *)signature {
    id<MKMTransportableData> ted = _CT;
    if (!ted) {
        id text = [self objectForKey:@"signature"];
        _CT = ted = MKMTransportableDataParse(text);
    }
    return [ted data];
}

- (NSMutableDictionary *)properties {
    if (_status < 0) {
        // document invalid
        return nil;
    }
    if (!_properties) {
        NSString *data = [self data];
        if ([data length] > 0) {
            NSDictionary *dict = MKMJSONMapDecode(data);
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

- (NSArray *)propertyKeys {
    return [self.properties allKeys];
}

- (nullable id)propertyForKey:(NSString *)key {
    NSObject *property = [self.properties objectForKey:key];
    if (property == [NSNull null]) {
        return nil;
    }
    return property;
}

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

- (BOOL)verify:(id<MKMVerifyKey>)PK {
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
    } else if ([PK verify:MKMUTF8Encode(data) withSignature:signature]) {
        // signature matched
        _status = 1;
    }
    // NOTICE: if status is 0, it doesn't mean the document is invalid,
    //         try another key
    return _status == 1;
}

- (NSData *)sign:(id<MKMSignKey>)SK {
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
    NSString *data = MKMJSONEncode(info);
    if ([data length] == 0) {
        NSAssert(false, @"should not happen: %@", info);
        return nil;
    }
    sig = [SK sign:MKMUTF8Encode(data)];
    if ([sig length] == 0) {
        NSAssert(false, @"should not happen");
        return nil;
    }
    id<MKMTransportableData> ted = MKMTransportableDataCreate(sig, nil);
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

- (NSDate *)time {
    // timestamp
    id seconds = [self propertyForKey:@"time"];
    return MKMConverterGetDate(seconds, nil);
}

- (NSString *)name {
    id name = [self propertyForKey:@"name"];
    return MKMConverterGetString(name, nil);
}

- (void)setName:(NSString *)name {
    [self setProperty:name forKey:@"name"];
}

@end
