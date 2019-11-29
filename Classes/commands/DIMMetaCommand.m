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

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic, nullable) DIMMeta *meta;

@end

@implementation DIMMetaCommand

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
        _ID = ID;
        
        // meta
        if (meta) {
            [_storeDictionary setObject:meta forKey:@"meta"];
        }
        _meta = meta;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        _meta = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMMetaCommand *cmd = [super copyWithZone:zone];
    if (cmd) {
        cmd.ID = _ID;
        cmd.meta = _meta;
    }
    return cmd;
}

- (NSString *)ID {
    if (!_ID) {
        _ID = [_storeDictionary objectForKey:@"ID"];
    }
    return _ID;
}

- (nullable DIMMeta *)meta {
    if (_meta) {
        return _meta;
    }
    NSDictionary *dict = [_storeDictionary objectForKey:@"meta"];
    DIMMeta *m = MKMMetaFromDictionary(dict);
    if (m != dict) {
        // replace the meta object
        NSAssert([m isKindOfClass:[DIMMeta class]], @"meta error: %@", dict);
        [_storeDictionary setObject:m forKey:@"meta"];
    }
    _meta = m;
    return _meta;
}

@end
