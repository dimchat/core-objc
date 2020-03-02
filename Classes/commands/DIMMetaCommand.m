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

@property (strong, nonatomic, nullable) DIMMeta *meta;

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
- (instancetype)initWithType:(UInt8)type {
    if (self = [super initWithType:type]) {
        _meta = nil;
    }
    return self;
}

- (instancetype)initWithID:(DIMID *)ID {
    return [self initWithID:ID meta:nil];
}

- (instancetype)initWithID:(DIMID *)ID
                      meta:(nullable DIMMeta *)meta {
    if (self = [self initWithCommand:DIMCommand_Meta]) {
        // ID
        if (ID) {
            [_storeDictionary setObject:ID forKey:@"ID"];
        }
        
        // meta
        if (meta) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        _meta = meta;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMMetaCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.meta = _meta;
    }
    return cmd;
}

- (NSString *)ID {
    return [_storeDictionary objectForKey:@"ID"];
}

- (nullable DIMMeta *)meta {
    if (!_meta) {
        NSDictionary *dict = [_storeDictionary objectForKey:@"meta"];
        _meta = MKMMetaFromDictionary(dict);
    }
    return _meta;
}

@end
