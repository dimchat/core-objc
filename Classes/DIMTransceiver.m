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
//  DIMTransceiver.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

#import "DIMTransceiver.h"

static inline BOOL isBroadcast(id<DKDMessage> msg) {
    id<MKMID> receiver = msg.group;
    if (!receiver) {
        receiver = msg.receiver;
    }
    return MKMIDIsBroadcast(receiver);
}

@implementation DIMTransceiver

- (id<DIMEntityDelegate>)barrack {
    NSAssert(_barrack, @"barrack not set yet!");
    return _barrack;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
            serializeContent:(id<DKDContent>)content
                     withKey:(id<MKMSymmetricKey>)password {
    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         before serialize content, this job should be do in subclass
    
    NSAssert(content == iMsg.content, @"message content not match: %@", content);
    return MKMUTF8Encode(MKMJSONEncode(content));
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
              encryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password {
    return [password encrypt:data];
}

- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                    encodeData:(NSData *)data {
    if (isBroadcast(iMsg)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so no need to encode to Base64 here
        return MKMUTF8Decode(data);
    }
    return MKMBase64Encode(data);
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    if (isBroadcast(iMsg)) {
        // broadcast message has no key
        return nil;
    }
    return MKMUTF8Encode(MKMJSONEncode(password));
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    NSAssert(!isBroadcast(iMsg), @"broadcast message has no key: %@", iMsg);
    // TODO: make sure the receiver's public key exists
    id<DIMUser> contact = [self.barrack userWithID:receiver];
    NSAssert(contact, @"failed to get encrypt key for receiver: %@", receiver);
    // encrypt with receiver's public key
    return [contact encrypt:data];
}

- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                     encodeKey:(NSData *)data {
    NSAssert(!isBroadcast(iMsg), @"broadcast message has no key: %@", iMsg);
    return MKMBase64Encode(data);
}

#pragma mark DKDSecureMessageDelegate

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                   decodeKey:(NSObject *)dataString {
    NSAssert(!isBroadcast(sMsg), @"broadcast message has no key: %@", sMsg);
    return MKMBase64Decode((NSString *)dataString);
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decryptKey:(NSData *)key
                        from:(id<MKMID>)sender
                          to:(id<MKMID>)receiver {
    // NOTICE: the receiver will be group ID in a group message here
    NSAssert(!isBroadcast(sMsg), @"broadcast message has no key: %@", sMsg);
    // decrypt key data with the receiver/group member's private key
    id<MKMID> ID = sMsg.receiver;
    id<DIMUser> user = [self.barrack userWithID:ID];
    NSAssert(user, @"failed to get decrypt keys: %@", ID);
    return [user decrypt:key];
}

- (nullable id<MKMSymmetricKey>)message:(id<DKDSecureMessage>)sMsg
                       deserializeKey:(nullable NSData *)data
                                 from:(id<MKMID>)sender
                                   to:(id<MKMID>)receiver {
    // NOTICE: the receiver will be group ID in a group message here
    NSAssert(!isBroadcast(sMsg), @"broadcast message has no key: %@", sMsg);
    NSAssert([data length] > 0, @"check key data by sub-class: %@", sMsg);
    id dict = MKMJSONDecode(MKMUTF8Decode(data));
    // TODO: translate short keys
    //       'A' -> 'algorithm'
    //       'D' -> 'data'
    //       'V' -> 'iv'
    //       'M' -> 'mode'
    //       'P' -> 'padding'
    return MKMSymmetricKeyParse(dict);
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decodeData:(NSObject *)dataString {
    if (isBroadcast(sMsg)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so return the string data directly
        NSString *string = (NSString *)dataString;
        return MKMUTF8Encode(string);
    }
    return MKMBase64Decode((NSString *)dataString);
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
              decryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password {
    return [password decrypt:data];
}

- (nullable id<DKDContent>)message:(id<DKDSecureMessage>)sMsg
                deserializeContent:(NSData *)data
                           withKey:(id<MKMSymmetricKey>)password {
    NSAssert([data length] > 0, @"content data should not be empty: %@", sMsg);
    id dict = MKMJSONDecode(MKMUTF8Decode(data));
    // TODO: translate short keys
    //       'T' -> 'type'
    //       'N' -> 'sn'
    //       'W' -> 'time'
    //       'G' -> 'group'
    return DKDContentParse(dict);
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                    signData:(NSData *)data
                   forSender:(id<MKMID>)sender {
    id<DIMUser> user = [self.barrack userWithID:sender];
    NSAssert(user, @"failed to get sign key for sender: %@", sender);
    return [user sign:data];
}

- (nullable NSObject *)message:(id<DKDSecureMessage>)sMsg
               encodeSignature:(NSData *)signature {
    return MKMBase64Encode(signature);
}

#pragma mark DKDReliableMessageDelegate

- (nullable NSData *)message:(id<DKDReliableMessage>)rMsg
             decodeSignature:(NSObject *)signatureString {
    return MKMBase64Decode((NSString *)signatureString);
}

- (BOOL)message:(id<DKDReliableMessage>)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(id<MKMID>)sender {
    id<DIMUser> user = [self.barrack userWithID:sender];
    NSAssert(user, @"failed to get verify key for sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end
