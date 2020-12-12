// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMDocumentCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

#import "DIMDocumentCommand.h"

@interface DIMDocumentCommand ()

@property (strong, nonatomic, nullable) id<MKMDocument> profile;

@end

@implementation DIMDocumentCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _profile = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _profile = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID meta:nil profile:nil];
}

- (instancetype)initWithID:(id<MKMID>)ID signature:(NSString *)signature {
    if (self = [self initWithID:ID meta:nil profile:nil]) {
        if (signature) {
            [self setObject:signature forKey:@"signature"];
        }
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID profile:(id<MKMDocument>)profile {
    return [self initWithID:ID meta:nil profile:profile];
}

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(nullable id<MKMMeta>)meta
                   profile:(nullable id<MKMDocument>)profile {
    if (self = [self initWithCommand:DIMCommand_Profile]) {
        // ID
        if (ID) {
            [self setObject:ID forKey:@"ID"];
        }
        // meta
        if (meta) {
            [self setObject:meta forKey:@"meta"];
        }
        
        // profile
        if (profile) {
            [self setObject:profile forKey:@"profile"];
        }
        _profile = profile;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMDocumentCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.profile = _profile;
    }
    return cmd;
}

- (nullable id<MKMDocument>)document {
    if (!_profile) {
        NSObject *data = [self objectForKey:@"profile"];
        if ([data isKindOfClass:[NSString class]]) {
            // compatible with v1.0
            //    "ID"        : "{ID}",
            //    "profile"   : "{JsON}",
            //    "signature" : "{BASE64}"
            id<MKMID> ID = self.ID;
            NSString *signature = [self objectForKey:@"signature"];
            if (!ID || !signature) {
                NSAssert(false, @"profile ID & signature should not be empty: %@", self);
                return nil;
            }
            NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            [mDict setObject:ID forKey:@"ID"];
            [mDict setObject:data forKey:@"data"];
            [mDict setObject:signature forKey:@"signature"];
            data = mDict;
        } else {
            if (!data) {
                data = [self objectForKey:@"document"];
            }
            // (v1.1)
            //    "ID"      : "{ID}",
            //    "profile" : {
            //        "ID"        : "{ID}",
            //        "data"      : "{JsON}",
            //        "signature" : "{BASE64}"
            //    }
            NSAssert(!data || [data isKindOfClass:[NSDictionary class]], @"profile data error: %@", data);
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            _profile = MKMDocumentFromDictionary((NSDictionary *)data);
        }
    }
    return _profile;
}

- (nullable NSString *)signature {
    return [self objectForKey:@"signature"];
}

@end
