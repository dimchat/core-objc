// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  DIMTransceiver+Combination.m
//  DIMCore
//
//  Created by Albert Moky on 2021/2/2.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

#import "DIMBarrack.h"
#import "DIMPacker.h"
#import "DIMProcessor.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver (EntityDelegate)

- (nullable DIMUser *)selectLocalUserWithID:(id<MKMID>)receiver {
    return [self.barrack selectLocalUserWithID:receiver];
}

- (nullable __kindof DIMUser *)userWithID:(id<MKMID>)ID {
    return [self.barrack userWithID:ID];
}

- (nullable __kindof DIMGroup *)groupWithID:(id<MKMID>)ID {
    return [self.barrack groupWithID:ID];
}

@end

#pragma mark -

@implementation DIMTransceiver (CipherKeyDelegate)

- (nullable __kindof id<MKMSymmetricKey>)cipherKeyFrom:(id<MKMID>)sender
                                                    to:(id<MKMID>)receiver
                                              generate:(BOOL)create {
    return [self.keyCache cipherKeyFrom:sender to:receiver generate:create];
}

- (void)cacheCipherKey:(id<MKMSymmetricKey>)key
                  from:(id<MKMID>)sender
                    to:(id<MKMID>)receiver {
    return [self.keyCache cacheCipherKey:key from:sender to:receiver];
}

@end

#pragma mark -

@implementation DIMTransceiver (Packer)

- (nullable id<MKMID>)overtGroupForContent:(id<DKDContent>)content {
    return [self.packer overtGroupForContent:content];
}

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    return [self.packer encryptMessage:iMsg];
}

- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg {
    return [self.packer signMessage:sMsg];
}

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    return [self.packer serializeMessage:rMsg];
}

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    return [self.packer deserializeMessage:data];
}

- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
    return [self.packer verifyMessage:rMsg];
}

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg {
    return [self.packer decryptMessage:sMsg];
}

@end

#pragma mark -

@implementation DIMTransceiver (Processor)

- (NSArray<NSData *> *)processData:(NSData *)data {
    return [self.processor processData:data];
}

- (NSArray<id<DKDReliableMessage>> *)processMessage:(id<DKDReliableMessage>)rMsg {
    return [self.processor processMessage:rMsg];
}

- (NSArray<id<DKDSecureMessage>> *)processSecure:(id<DKDSecureMessage>)sMsg
                                     withMessage:(id<DKDReliableMessage>)rMsg {
    return [self.processor processSecure:sMsg withMessage:rMsg];
}

- (NSArray<id<DKDInstantMessage>> *)processInstant:(id<DKDInstantMessage>)iMsg
                                       withMessage:(id<DKDReliableMessage>)rMsg {
    return [self.processor processInstant:iMsg withMessage:rMsg];
}

- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    return [self.processor processContent:content withMessage:rMsg];
}

@end
