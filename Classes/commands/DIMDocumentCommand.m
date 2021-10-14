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

#import "DIMDocumentCommand.h"

@interface DIMDocumentCommand ()

@property (strong, nonatomic, nullable) id<MKMDocument> document;

@end

@implementation DIMDocumentCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _document = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _document = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID meta:nil document:nil];
}

- (instancetype)initWithID:(id<MKMID>)ID signature:(NSString *)signature {
    if (self = [self initWithID:ID meta:nil document:nil]) {
        if (signature) {
            [self setObject:signature forKey:@"signature"];
        }
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID document:(id<MKMDocument>)doc {
    return [self initWithID:ID meta:nil document:doc];
}

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(nullable id<MKMMeta>)meta
                  document:(nullable id<MKMDocument>)doc {
    if (self = [self initWithCommand:DIMCommand_Document]) {
        // ID
        if (ID) {
            [self setObject:[ID string] forKey:@"ID"];
        }
        // meta
        if (meta) {
            [self setObject:[meta dictionary] forKey:@"meta"];
        }
        
        // document
        if (doc) {
            [self setObject:[doc dictionary] forKey:@"profile"];
        }
        _document = doc;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMDocumentCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.document = _document;
    }
    return cmd;
}

- (nullable id<MKMDocument>)document {
    if (!_document) {
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
            [mDict setObject:[ID string] forKey:@"ID"];
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
            _document = MKMDocumentFromDictionary((NSDictionary *)data);
        }
    }
    return _document;
}

- (nullable NSString *)signature {
    return [self objectForKey:@"signature"];
}

@end
