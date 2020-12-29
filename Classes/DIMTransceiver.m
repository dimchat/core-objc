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

#import "DIMCommand.h"

#import "DIMBarrack.h"

#import "DIMTransceiver.h"

static inline BOOL isBroadcast(id<DKDMessage> msg, DIMTransceiver *tranceiver) {
    id<MKMID> receiver = msg.group;
    if (!receiver) {
        receiver = msg.receiver;
    }
    return MKMIDIsBroadcast(receiver);
}

@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        
        // delegates
        _barrack = nil;
        _keyCache = nil;
    }
    return self;
}

#pragma mark DKDMessageDelegate

- (id<MKMID>)overtGroupForContent:(id<DKDContent>)content {
    id<MKMID> group = content.group;
    if (!group) {
        return nil;
    }
    if (MKMIDIsBroadcast(group)) {
        // broadcast message is always overt
        return group;
    }
    if ([content isKindOfClass:[DIMCommand class]]) {
        // group command should be sent to each member directly, so
        // don't expose group ID
        return nil;
    }
    return group;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
            serializeContent:(id<DKDContent>)content
                     withKey:(id<MKMSymmetricKey>)password {
    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         before serialize content, this job should be do in subclass
    
    NSAssert(content == iMsg.content, @"message content not match: %@", content);
    return MKMJSONEncode(content);
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
              encryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password {
    return [password encrypt:data];
}

- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                    encodeData:(NSData *)data {
    if (isBroadcast(iMsg, self)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so no need to encode to Base64 here
        return MKMUTF8Decode(data);
    }
    return MKMBase64Encode(data);
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    if (isBroadcast(iMsg, self)) {
        // broadcast message has no key
        return nil;
    }
    return MKMJSONEncode(password);
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    NSAssert(!isBroadcast(iMsg, self), @"broadcast message has no key: %@", iMsg);
    // encrypt with receiver's public key
    DIMUser *contact = [_barrack userWithID:receiver];
    NSAssert(contact, @"failed to get encrypt key for receiver: %@", receiver);
    return [contact encrypt:data];
}

- (nullable NSObject *)message:(id<DKDInstantMessage>)iMsg
                     encodeKey:(NSData *)data {
    NSAssert(!isBroadcast(iMsg, self), @"broadcast message has no key: %@", iMsg);
    return MKMBase64Encode(data);
}

#pragma mark DKDSecureMessageDelegate

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                   decodeKey:(NSObject *)dataString {
    NSAssert(!isBroadcast(sMsg, self), @"broadcast message has no key: %@", sMsg);
    return MKMBase64Decode((NSString *)dataString);
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decryptKey:(NSData *)key
                        from:(id<MKMID>)sender
                          to:(id<MKMID>)receiver {
    // NOTICE: the receiver will be group ID in a group message here
    NSAssert(!isBroadcast(sMsg, self), @"broadcast message has no key: %@", sMsg);
    // decrypt key data with the receiver/group member's private key
    id<MKMID> ID = sMsg.receiver;
    DIMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to get decrypt keys: %@", ID);
    return [user decrypt:key];
}

- (nullable id<MKMSymmetricKey>)message:(id<DKDSecureMessage>)sMsg
                       deserializeKey:(nullable NSData *)data
                                 from:(id<MKMID>)sender
                                   to:(id<MKMID>)receiver {
    // NOTICE: the receiver will be group ID in a group message here
    if (data) {
        NSAssert(!isBroadcast(sMsg, self), @"broadcast message has no key: %@", sMsg);
        NSDictionary *dict = MKMJSONDecode(data);
        // TODO: translate short keys
        //       'A' -> 'algorithm'
        //       'D' -> 'data'
        //       'V' -> 'iv'
        //       'M' -> 'mode'
        //       'P' -> 'padding'
        return MKMSymmetricKeyFromDictionary(dict);
    } else {
        // get key from cache
        return [_keyCache cipherKeyFrom:sender to:receiver generate:NO];
    }
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decodeData:(NSObject *)dataString {
    if (isBroadcast(sMsg, self)) {
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
    NSDictionary *dict = MKMJSONDecode(data);
    // TODO: translate short keys
    //       'T' -> 'type'
    //       'N' -> 'sn'
    //       'G' -> 'group'
    id<DKDContent> content = DKDContentFromDictionary(dict);
    
    if (!isBroadcast(sMsg, self)) {
        // check and cache key for reuse
        id<MKMID> sender = sMsg.sender;
        id<MKMID> group = [self overtGroupForContent:content];
        if (group) {
            // group message (excludes group command)
            // cache the key with direction (sender -> group)
            [_keyCache cacheCipherKey:password from:sender to:group];
        } else {
            id<MKMID> receiver = sMsg.receiver;
            // personal message or (group) command
            // cache key with direction (sender -> receiver)
            [_keyCache cacheCipherKey:password from:sender to:receiver];
        }
    }

    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         after deserialize content, this job should be do in subclass
    return content;
}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                    signData:(NSData *)data
                   forSender:(id<MKMID>)sender {
    DIMUser *user = [_barrack userWithID:sender];
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
    DIMUser *user = [_barrack userWithID:sender];
    NSAssert(user, @"failed to get verify key for sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end
