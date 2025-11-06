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
//  DIMQuoteContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/Type.h>

#import "DKDContentType.h"

#import "DIMQuoteContent.h"

@interface DIMQuoteContent () {
    
    id<DKDEnvelope> _env;
}

@end

@implementation DIMQuoteContent

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        // lazy load
        _env = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _env = nil;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text origin:(NSDictionary *)env {
    if (self = [self initWithType:DKDContentType_Quote]) {
        // text message
        [self setObject:text forKey:@"text"];
        // original envelope of message quote with,
        // includes 'sender', 'receiver', 'type' and 'sn'
        [self setObject:env forKey:@"origin"];
    }
    return self;
}

// Override
- (NSString *)text {
    return [self stringForKey:@"text" defaultValue:@""];
}

// protected
- (NSDictionary *)origin {
    id info = [self objectForKey:@"origin"];
    if ([info isKindOfClass:[NSDictionary class]]) {
        return info;
    }
    NSAssert(info == nil, @"origin error: %@", info);
    return nil;
}

// Override
- (id<DKDEnvelope>) originalEnvelope {
    id<DKDEnvelope> env = _env;
    if (!env) {
        id dict = [self origin];
        if ([dict isKindOfClass:[NSMutableDictionary class]]) {
            env = DKDEnvelopeParse([self origin]);
        } else if ([dict isKindOfClass:[NSDictionary class]]) {
            env = DKDEnvelopeParse([self origin]);
            [self setObject:env.dictionary forKey:@"origin"];
        } else {
            NSAssert(dict == nil, @"original envelope error: %@, %@", dict, self);
        }
        _env = env;
    }
    return env;
}

// Override
- (DKDSerialNumber)originalSerialNumber {
    NSDictionary *env = [self origin];
    id sn = [env objectForKey:@"sn"];
    return MKConvertUnsignedInt(sn, 0);
}

@end

#pragma mark - Conveniences

DIMQuoteContent *DIMQuoteContentCreate(NSString *text,
                                       id<DKDEnvelope> head,
                                       id<DKDContent> body) {
    NSMutableDictionary *origin = DIMQuoteContentPurify(head);
    [origin setObject:body.type forKey:@"type"];
    [origin setObject:@(body.sn) forKey:@"sn"];
    // update: receiver -> group
    id<MKMID> group = [body group];
    if (group) {
        [origin setObject:[group string] forKey:@"receiver"];
    }
    return [[DIMQuoteContent alloc] initWithText:text origin:origin];
}

NSMutableDictionary<NSString *, id> *DIMQuoteContentPurify(id<DKDEnvelope> env) {
    id<MKMID> from = [env sender];
    id<MKMID> to = [env group];
    if (!to) {
        to = [env receiver];
    }
    // build origin info
    NSMutableDictionary *origin = [[NSMutableDictionary alloc] initWithCapacity:2];
    [origin setObject:[from string] forKey:@"sender"];
    [origin setObject:[to string] forKey:@"receiver"];
    return origin;
}
