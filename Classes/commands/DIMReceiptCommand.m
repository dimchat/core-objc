// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMReceiptCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

@interface DIMReceiptCommand () {
    
    id<DKDEnvelope> _env;
}

@end

@implementation DIMReceiptCommand

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

- (instancetype)initWithText:(NSString *)text origin:(nullable NSDictionary *)env {
    if (self = [self initWithCmd:DKDCommand_Receipt]) {
        // text message
        [self setObject:text forKey:@"text"];
        // original envelope of message quote with,
        // includes 'sender', 'receiver', 'type' and 'sn'
        if (env) {
            NSAssert(!([env count] == 0 ||
                       [env objectForKey:@"data"] ||
                       [env objectForKey:@"key"] ||
                       [env objectForKey:@"keys"] ||
                       [env objectForKey:@"meta"] ||
                       [env objectForKey:@"visa"]), @"impure envelope: %@", env);
            [self setObject:env forKey:@"origin"];
        }
    }
    return self;
}

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

- (DKDSerialNumber)originalSerialNumber {
    NSDictionary *env = [self origin];
    id sn = [env objectForKey:@"sn"];
    return MKConvertUnsignedLong(sn, 0);
}

- (NSString *)originalSignature {
    NSDictionary *env = [self origin];
    id signature = [env objectForKey:@"signature"];
    return MKConvertString(signature, nil);
}

@end

#pragma mark - Conveniences

DIMReceiptCommand *DIMReceiptCommandCreate(NSString *text,
                                           _Nullable id<DKDEnvelope> head,
                                           _Nullable id<DKDContent> body) {
    NSMutableDictionary *origin;
    if (!head) {
        origin = nil;
    } else if (!body) {
        origin = DIMReceiptCommandPurify(head);
    } else {
        origin = DIMReceiptCommandPurify(head);
        [origin setObject:@(body.sn) forKey:@"sn"];
    }
    DIMReceiptCommand *command = [[DIMReceiptCommand alloc] initWithText:text
                                                                  origin:origin];
    if (body) {
        // check group
        id<MKMID> group = [body group];
        if (group) {
            [command setGroup:group];
        }
    }
    return command;
}

NSMutableDictionary<NSString *, id> *DIMReceiptCommandPurify(id<DKDEnvelope> env) {
    NSMutableDictionary *origin = [env dictionary:NO];
    if ([origin objectForKey:@"data"]) {
        [origin removeObjectForKey:@"data"];
        [origin removeObjectForKey:@"key"];
        [origin removeObjectForKey:@"keys"];
        [origin removeObjectForKey:@"meta"];
        [origin removeObjectForKey:@"visa"];
    }
    return origin;
}
