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
//  DIMMetaCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

@interface DIMMetaCommand ()

@property (strong, nonatomic, nullable) id<MKMMeta> meta;

@end

@implementation DIMMetaCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _meta = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _meta = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID {
    return [self initWithID:ID meta:nil];
}

- (instancetype)initWithID:(id<MKMID>)ID
                      meta:(nullable id<MKMMeta>)meta {
    if (self = [self initWithCommand:DIMCommand_Meta]) {
        // ID
        if (ID) {
            [self setObject:ID forKey:@"ID"];
        }
        
        // meta
        if (meta) {
            [self setObject:[meta dictionary] forKey:@"meta"];
        }
        _meta = meta;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMMetaCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.meta = _meta;
    }
    return cmd;
}

- (id<MKMID>)ID {
    id string = [self objectForKey:@"ID"];
    return MKMIDFromString(string);
}

- (nullable id<MKMMeta>)meta {
    if (!_meta) {
        NSDictionary *dict = [self objectForKey:@"meta"];
        _meta = MKMMetaFromDictionary(dict);
    }
    return _meta;
}

@end
