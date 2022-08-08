// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMForwardContent.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMForwardContent.h"

/**
 *  Convert message list from dictionary array
 */
NSArray<id<DKDReliableMessage>> *DIMReliableMessageConvert(NSArray<NSDictionary *> *messages) {
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    id<DKDMessage> msg;
    for (NSDictionary *item in messages) {
        msg = DKDReliableMessageParse(item);
        if (msg) {
            [mArray addObject:msg];
        }
    }
    return mArray;
}

/**
 *  Revert message list to dictionary array
 */
NSArray<NSDictionary *> *DIMReliableMessageRevert(NSArray<id<DKDReliableMessage>> *messages) {
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    for (id<DKDMessage> msg in messages) {
        [mArray addObject:[msg dictionary]];
    }
    return mArray;
}

@interface DIMForwardContent ()

@property (nonatomic) id<DKDReliableMessage> forward;
@property (nonatomic) NSArray<id<DKDReliableMessage>> *secrets;

@end

@implementation DIMForwardContent

- (instancetype)initWithMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert(rMsg, @"forward message cannot be empty");
    if (self = [self initWithType:DKDContentType_Forward]) {
        _forward = rMsg;
        _secrets = nil;
        [self setObject:[rMsg dictionary] forKey:@"forward"];
    }
    return self;
}

- (instancetype)initWithMessages:(NSArray<id<DKDReliableMessage>> *)secrets {
    NSAssert(secrets, @"secret messages cannot be empty");
    if (self = [self initWithType:DKDContentType_Forward]) {
        _forward = nil;
        _secrets = secrets;
        [self setObject:DIMReliableMessageRevert(secrets) forKey:@"secrets"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _forward = nil;
        _secrets = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMForwardContent *content = [super copyWithZone:zone];
    if (content) {
        content.forward = _forward;
        content.secrets = _secrets;
    }
    return content;
}

- (id<DKDReliableMessage>)forward {
    if (!_forward) {
        id info = [self objectForKey:@"forward"];
        _forward = DKDReliableMessageFromDictionary(info);
    }
    return _forward;
}

- (NSArray<id<DKDReliableMessage>> *)secrets {
    if (!_secrets) {
        id info = [self objectForKey:@"secrets"];
        if (info) {
            // get from 'secrets'
            _secrets = DIMReliableMessageConvert(info);
        } else {
            // get from 'forward'
            id<DKDReliableMessage> msg = [self forward];
            if (msg) {
                _secrets = @[msg];
            }
        }
    }
    return _secrets;
}

@end
