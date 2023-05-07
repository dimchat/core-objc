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

@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) id<MKMID> ID;

@property (strong, nonatomic) NSString *data;    // JsON.encode(properties)
@property (strong, nonatomic) NSData *signature; // User(ID).sign(data)

@property (strong, nonatomic) NSMutableDictionary *properties;

@property (nonatomic) NSInteger status;          // 1 for valid, -1 for invalid

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
        _type = nil;
        
        _ID = nil;
        
        _data = nil;
        _signature = nil;
        
        _properties = nil;

        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)sig {
    NSDictionary *dict = @{
        @"ID": [ID string],
        @"data": json,
        @"signature": sig
    };
    if (self = [super initWithDictionary:dict]) {
        _type = nil;
        
        _ID = ID;

        _data = json;
        _signature = MKMBase64Decode(sig);
        
        _properties = nil;

        // all documents must be verified before saving into local storage
        _status = 1;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    if (self = [super initWithDictionary:@{@"ID": [ID string]}]) {
        _type = type;
        
        _ID = ID;
        
        _data = nil;
        _signature = nil;
        
        if (type.length > 0) {
            _properties = [[NSMutableDictionary alloc] init];
            [_properties setObject:type forKey:@"type"];
        } else {
            _properties = nil;
        }

        _status = 0;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMDocument *doc = [super copyWithZone:zone];
    if (doc) {
        doc.type = _type;
        doc.ID = _ID;
        doc.data = _data;
        doc.signature = _signature;
        doc.properties = _properties;
        doc.status = _status;
    }
    return doc;
}

- (BOOL)isValid {
    return _status > 0;
}

- (NSString *)type {
    if (!_type) {
        _type = [self propertyForKey:@"type"];
        if (!_type) {
            _type = [self objectForKey:@"type"];
        }
    }
    return _type;
}

- (id<MKMID>)ID {
    if (!_ID) {
        _ID = MKMIDParse([self objectForKey:@"ID"]);
    }
    return _ID;
}

- (NSString *)data {
    if (!_data) {
        _data = [self stringForKey:@"data"];
    }
    return _data;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *base64 = [self stringForKey:@"signature"];
        if (base64) {
            _signature = MKMBase64Decode(base64);
        }
    }
    return _signature;
}

- (NSMutableDictionary *)properties {
    if (_status < 0) {
        // document invalid
        return nil;
    }
    if (!_properties) {
        NSString *data = [self data];
        if ([data length] > 0) {
            NSDictionary *dict = MKMJSONDecode(data);
            NSAssert(dict, @"document data error: %@", data);
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                _properties = (NSMutableDictionary *)dict;
            } else {
                _properties = [dict mutableCopy];
            }
        } else {
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
    _signature = nil;
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
    if (_status > 0) {
        // already signed/verified
        NSAssert([_data length] > 0, @"document data error");
        NSAssert([_signature length] > 0, @"document signature error");
        return _signature;
    }
    // 1. update sign time
    NSDate *now = [[NSDate alloc] init];
    [self setProperty:@([now timeIntervalSince1970]) forKey:@"time"];
    // 2. encode & sign
    NSString *data = MKMJSONEncode(self.properties);
    if ([data length] == 0) {
        // properties error
        return nil;
    }
    NSData *signature = [SK sign:MKMUTF8Encode(data)];
    if ([signature length] == 0) {
        // signature error
        return nil;
    }
    // 3. update 'data' & 'signature' fields
    [self setObject:data forKey:@"data"];
    [self setObject:MKMBase64Encode(signature) forKey:@"signature"];
    _data = data;
    _signature = signature;
    // 4. update status
    _status = 1;
    return signature;
}

#pragma mark properties getter/setter

- (NSDate *)time {
    // timestamp
    id seconds = [self propertyForKey:@"time"];
    return MKMConverterGetDate(seconds);
}

- (NSString *)name {
    return [self propertyForKey:@"name"];
}

- (void)setName:(NSString *)name {
    [self setProperty:name forKey:@"name"];
}

@end

#pragma mark -

@implementation DIMDocumentFactory

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (NSString *)typeForID:(id<MKMID>)ID {
    if ([_type isEqualToString:@"*"]) {
        if (MKMIDIsGroup(ID)) {
            return MKMDocument_Bulletin;
        } else if (MKMIDIsUser(ID)) {
            return MKMDocument_Visa;
        }
        return MKMDocument_Profile;
    }
    return _type;
}

- (id<MKMDocument>)createDocument:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)sig {
    NSString *type = [self typeForID:ID];
    if ([type isEqualToString:MKMDocument_Visa]) {
        return [[DIMVisa alloc] initWithID:ID data:json signature:sig];
    }
    if ([type isEqualToString:MKMDocument_Bulletin]) {
        return [[DIMBulletin alloc] initWithID:ID data:json signature:sig];
    }
    return [[DIMDocument alloc] initWithID:ID data:json signature:sig];
}

// create a new empty document with entity ID
- (id<MKMDocument>)createDocument:(id<MKMID>)ID {
    NSString *type = [self typeForID:ID];
    if ([type isEqualToString:MKMDocument_Visa]) {
        return [[DIMVisa alloc] initWithID:ID];
    }
    if ([type isEqualToString:MKMDocument_Bulletin]) {
        return [[DIMBulletin alloc] initWithID:ID];
    }
    return [[DIMDocument alloc] initWithID:ID type:type];
}

- (nullable id<MKMDocument>)parseDocument:(NSDictionary *)doc {
    id<MKMID> ID = MKMIDParse([doc objectForKey:@"ID"]);
    if (!ID) {
        return nil;
    }
    NSString *type = [doc objectForKey:@"type"];
    if (type.length == 0) {
        if (MKMIDIsGroup(ID)) {
            type = MKMDocument_Bulletin;
        } else {
            type = MKMDocument_Visa;
        }
    }
    if ([type isEqualToString:MKMDocument_Visa]) {
        return [[DIMVisa alloc] initWithDictionary:doc];
    }
    if ([type isEqualToString:MKMDocument_Bulletin]) {
        return [[DIMBulletin alloc] initWithDictionary:doc];
    }
    return [[DIMDocument alloc] initWithDictionary:doc];
}

@end
