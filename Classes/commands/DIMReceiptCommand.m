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

DIMReceiptCommand *DIMReceiptCommandCreate(NSString *text,
                                           _Nullable id<DKDEnvelope> head,
                                           _Nullable id<DKDContent> body) {
    NSMutableDictionary *info;
    if (!head) {
        info = nil;
    } else if (!body) {
        info = DIMReceiptCommandPurify(head);
    } else {
        info = DIMReceiptCommandPurify(head);
        [info setObject:@(body.serialNumber) forKey:@"sn"];
    }
    DIMReceiptCommand *command = [[DIMReceiptCommand alloc] initWithText:text
                                                                  origin:info];
    if (body) {
        // check group
        id<MKMID> group = [body group];
        if (group) {
            [command setGroup:group];
        }
    }
    return command;
}

NSMutableDictionary *DIMReceiptCommandPurify(id<DKDEnvelope> envelope) {
    NSMutableDictionary *info = [envelope dictionary:NO];
    if ([info objectForKey:@"data"]) {
        [info removeObjectForKey:@"data"];
        [info removeObjectForKey:@"key"];
        [info removeObjectForKey:@"keys"];
        [info removeObjectForKey:@"meta"];
        [info removeObjectForKey:@"visa"];
    }
    return info;
}

@interface DIMReceiptCommand () {
    
    // original message envelope
    id<DKDEnvelope> _env;
}

@end

@implementation DIMReceiptCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _env = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _env = nil;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text origin:(NSDictionary *)info {
    if (self = [self initWithCommandName:DIMCommand_Receipt]) {
        // text message
        [self setObject:text forKey:@"text"];
        // original envelope of message responding to,
        // includes 'sn' and 'signature'
        if (info) {
            NSAssert([info count] > 0 ||
                     [info objectForKey:@"data"] ||
                     [info objectForKey:@"key"] ||
                     [info objectForKey:@"keys"] ||
                     [info objectForKey:@"meta"] ||
                     [info objectForKey:@"visa"],
                     @"impure envelope: %@", info);
            [self setObject:info forKey:@"origin"];
        }

    }
    return self;
}

- (NSString *)text {
    return [self stringForKey:@"text" defaultValue:@""];
}

- (NSDictionary *)origin {
    id info = [self objectForKey:@"origin"];
    if ([info isKindOfClass:[NSDictionary class]]) {
        return info;
    }
    NSAssert(!info, @"origin info error: %@", info);
    return nil;
}

- (id<DKDEnvelope>)originalEnvelope {
    if (!_env) {
        // origin: { sender: "...", receiver: "...", time: 0 }
        _env = DKDEnvelopeParse([self origin]);
    }
    return _env;
}

- (unsigned long)originalSerialNumber {
    id sn = [self.origin objectForKey:@"sn"];
    return MKMConverterGetUnsignedLong(sn, 0);
}

- (NSString *)originalSignature {
    id signature = [self.origin objectForKey:@"signature"];
    return MKMConverterGetString(signature, nil);
}

@end
