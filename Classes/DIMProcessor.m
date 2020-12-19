// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMProcessor.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMContent.h"
#import "DIMBarrack.h"
#import "DIMTransceiver.h"

#import "DIMProcessor.h"

@interface DIMProcessor ()

@property (weak, nonatomic) id<DIMEntityDelegate> barrack;
@property (weak, nonatomic) id<DKDMessageDelegate> transceiver;
@property (weak, nonatomic) DIMPacker *packer;

@end

@implementation DIMProcessor

- (instancetype)initWithEntityDelegate:(id<DIMEntityDelegate>)barrack
                       messageDelegate:(id<DKDMessageDelegate>)transceiver
                                packer:(DIMPacker *)messagePacker {
    if (self = [super init]) {
        self.barrack = barrack;
        self.transceiver = transceiver;
        self.packer = messagePacker;
    }
    return self;
}

- (nullable NSData *)processData:(NSData *)data {
    // 1. deserialize message
    id<DKDReliableMessage>rMsg = [self.packer deserializeMessage:data];
    if (!rMsg) {
        // no message received
        return nil;
    }
    // 2. process message
    rMsg = [self processMessage:rMsg];
    if (!rMsg) {
        // nothing to response
        return nil;
    }
    // serialize message
    return [self.packer serializeMessage:rMsg];
}

- (nullable id<DKDReliableMessage>)processMessage:(id<DKDReliableMessage>)rMsg {
    // 1. verify message
    id<DKDSecureMessage> sMsg = [self.packer verifyMessage:rMsg];
    if (!sMsg) {
        // waiting for sender's meta if not eixsts
        return nil;
    }
    // 2. process message
    sMsg = [self processSecure:sMsg withMessage:rMsg];
    if (!sMsg) {
        // nothing to respond
        return nil;
    }
    // 3. sign message
    return [self.packer signMessage:sMsg];
}

- (nullable id<DKDSecureMessage>)processSecure:(id<DKDSecureMessage>)sMsg
                                   withMessage:(id<DKDReliableMessage>)rMsg {
    // 1. decrypt message
    id<DKDInstantMessage> iMsg = [self.packer decryptMessage:sMsg];
    if (!iMsg) {
        // cannot decrypt this message, not for you?
        // delivering message to other receiver?
        return nil;
    }
    // 2. process message
    iMsg = [self processInstant:iMsg withMessage:rMsg];
    if (!iMsg) {
        // nothing to respond
        return nil;
    }
    // 3. encrypt message
    return [self.packer encryptMessage:iMsg];
}

- (nullable id<DKDInstantMessage>)processInstant:(id<DKDInstantMessage>)iMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg {
    // check message delegate
    if (!iMsg.delegate) {
        iMsg.delegate = self.transceiver;
    }
    
    // process content from sender
    id<DKDContent> content = iMsg.content;
    id<DKDContent>res = [self processContent:content withMessage:rMsg];
    if (!res) {
        // nothing to respond
        return nil;
    }
    
    // check receiver
    id<MKMID> sender = iMsg.sender;
    id<MKMID>receiver = iMsg.receiver;
    MKMUser *user = [self.barrack selectLocalUserWithID:receiver];
    NSAssert(user, @"receiver error: %@", receiver);
    
    // pack message
    id<DKDEnvelope> env = DKDEnvelopeCreate(user.ID, sender, nil);
    return DKDInstantMessageCreate(env, res);
}

- (nullable id<DKDContent>)processContent:(id<DKDContent>)content
                              withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert(false, @"implements me!");
    return nil;
}

@end
