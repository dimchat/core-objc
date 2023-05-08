// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMReliableMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMReliableMessage.h"

@interface DIMReliableMessage () {
    
    id<MKMMeta> _meta;
    id<MKMVisa> _visa;
}

@property (strong, nonatomic) NSData *signature;

@end

@implementation DIMReliableMessage

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _signature = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMReliableMessage *rMsg = [super copyWithZone:zone];
    if (rMsg) {
        rMsg.signature = _signature;
    }
    return rMsg;
}

- (NSData *)signature {
    if (!_signature) {
        NSObject *b64 = [self objectForKey:@"signature"];
        NSAssert(b64, @"signature cannot be empty");
        id<DKDReliableMessageDelegate> transceiver;
        transceiver = (id<DKDReliableMessageDelegate>)[self delegate];
        NSAssert(transceiver, @"message delegate not set yet");
        _signature = [transceiver message:self decodeSignature:b64];
        NSAssert(_signature, @"message signature error: %@", b64);
    }
    return _signature;
}

- (nullable id<DKDSecureMessage>)verify {
    id<DKDReliableMessageDelegate> transceiver;
    transceiver = (id<DKDReliableMessageDelegate>)[self delegate];
    NSAssert(transceiver, @"message delegate not set yet");
    // 1. verify data signature with sender's public key
    if ([transceiver message:self
                  verifyData:self.data withSignature:self.signature
                   forSender:self.sender]) {
        // 2. pack message
        NSMutableDictionary *mDict = [self dictionary:NO];
        [mDict removeObjectForKey:@"signature"];
        return DKDSecureMessageParse(mDict);
    } else {
        NSAssert(false, @"message signature not match: %@", self);
        // TODO: check whether visa is expired, query new document for this contact
        return nil;
    }
}

- (id<MKMMeta>)meta {
    if (!_meta) {
        id dict = [self objectForKey:@"meta"];
        _meta = MKMMetaParse(dict);
    }
    return _meta;
}

- (void)setMeta:(id<MKMMeta>)meta {
    [self setDictionary:meta forKey:@"meta"];
    _meta = meta;
}

- (id<MKMVisa>)visa {
    if (!_visa) {
        id dict = [self objectForKey:@"visa"];
        id<MKMDocument> doc = MKMDocumentParse(dict);
        if ([doc conformsToProtocol:@protocol(MKMVisa)]) {
            _visa = (id<MKMVisa>) doc;
        } else {
            NSAssert(!doc, @"visa document error: %@", doc);
        }
    }
    return _visa;
}

- (void)setVisa:(id<MKMVisa>)visa {
    [self setDictionary:visa forKey:@"visa"];
    _visa = visa;
}

@end

@implementation DIMReliableMessageFactory

- (nullable id<DKDReliableMessage>)parseReliableMessage:(NSDictionary *)msg {
    // check 'sender', 'data', 'signature'
    id sender = [msg objectForKey:@"sender"];
    id data = [msg objectForKey:@"data"];
    id signature = [msg objectForKey:@"signature"];
    if (!sender || !data || !signature) {
        // msg.sender should not be empty
        // msg.data should not be empty
        // msg.signature should not be empty
        return nil;
    }
    return [[DIMReliableMessage alloc] initWithDictionary:msg];
}

@end
