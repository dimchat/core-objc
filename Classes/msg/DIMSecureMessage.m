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
//  DIMSecureMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMReliableMessage.h"

#import "DIMSecureMessage.h"

@interface DIMSecureMessage ()

@property (strong, nonatomic) NSData *data;

@property (strong, nonatomic, nullable) NSData *encryptedKey;
@property (strong, nonatomic, nullable) NSDictionary *encryptedKeys;

@end

@implementation DIMSecureMessage

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(false, @"DON'T call me");
    return [self initWithDictionary:env.dictionary];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _data = nil;
        _encryptedKey = nil;
        _encryptedKeys = nil;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMSecureMessage *sMsg = [super copyWithZone:zone];
    if (sMsg) {
        sMsg.data = _data;
        sMsg.encryptedKey = _encryptedKey;
        sMsg.encryptedKeys = _encryptedKeys;
    }
    return sMsg;
}

- (NSData *)data {
    if (!_data) {
        NSObject *b64 = [self objectForKey:@"data"];
        NSAssert(b64, @"content data cannot be empty");
        id<DKDSecureMessageDelegate> transceiver;
        transceiver = (id<DKDSecureMessageDelegate>)[self delegate];
        NSAssert(transceiver, @"message delegate not set yet");
        _data = [transceiver message:self decodeData:b64];
        NSAssert(_data, @"message data error: %@", b64);
    }
    return _data;
}

- (NSData *)encryptedKey {
    if (!_encryptedKey) {
        NSObject *b64 = [self objectForKey:@"key"];
        if (!b64) {
            // check 'keys'
            NSDictionary *keys = self.encryptedKeys;
            b64 = [keys objectForKey:[self.receiver string]];
        }
        if (b64) {
            id<DKDSecureMessageDelegate> transceiver;
            transceiver = (id<DKDSecureMessageDelegate>)[self delegate];
            NSAssert(transceiver, @"message delegate not set yet");
            _encryptedKey = [transceiver message:self decodeKey:b64];
            NSAssert(_encryptedKey, @"message key error: %@", b64);
        }
    }
    return _encryptedKey;
}

- (NSDictionary *)encryptedKeys {
    if (!_encryptedKeys) {
        _encryptedKeys = [self objectForKey:@"keys"];
    }
    return _encryptedKeys;
}

- (nullable id<DKDInstantMessage>)decrypt {
    id<MKMID> sender = [self sender];
    id<MKMID> receiver;
    id<MKMID> group = [self group];
    if (group) {
        receiver = group;
    } else {
        // personal message
        // not split group message
        receiver = [self receiver];
    }

    // 1. decrypt 'message.key' to symmetric key
    id<DKDSecureMessageDelegate> transceiver;
    transceiver = (id<DKDSecureMessageDelegate>)[self delegate];
    NSAssert(transceiver, @"message delegate not set yet");
    // 1.1. decode encrypted key data
    NSData *key = self.encryptedKey;
    // 1.2. decrypt key data
    if (key.length > 0) {
        key = [transceiver message:self decryptKey:key from:sender to:receiver];
        if (key.length == 0) {
            //@throw [NSException exceptionWithName:@"ReceiverError" reason:@"failed to decrypt key in msg" userInfo:[self dictionary]];
            // TODO: check whether my visa key is changed, push new visa to this contact
            return nil;
        }
    }
    // 1.3. deserialize key
    //      if key is empty, means it should be reused, get it from key cache
    id<MKMSymmetricKey> password = [transceiver message:self deserializeKey:key
                                                   from:sender to:receiver];
    NSAssert(password, @"failed to get msg key: %@ -> %@, %@", sender, receiver, self);
    
    // 2. decrypt 'message.data' to 'message.content'
    // 2.1. decode encrypted content data
    NSData *ciphertext = [self data];
    NSAssert(ciphertext.length > 0, @"failed to decode content data: %@", self);
    // 2.2. decrypt content data
    NSData *plaintext = [transceiver message:self decryptContent:ciphertext
                                     withKey:password];
    if (!plaintext) {
        NSAssert(false, @"failed to decrypt data with key: %@", password);
        return nil;
    }
    // 2.3. deserialize content
    id<DKDContent> content = [transceiver message:self deserializeContent:plaintext withKey:password];
    if (!content) {
        NSAssert(false, @"content data error: [%@]", MKMUTF8Decode(plaintext));
        return nil;
    }
    // 2.4. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in application level)
    
    // 3. pack message
    NSMutableDictionary *mDict = [self dictionary:NO];
    [mDict removeObjectForKey:@"key"];
    [mDict removeObjectForKey:@"keys"];
    [mDict removeObjectForKey:@"data"];
    [mDict setObject:[content dictionary] forKey:@"content"];
    return DKDInstantMessageParse(mDict);
}

- (id<DKDReliableMessage>)sign {
    id<DKDSecureMessageDelegate> transceiver;
    transceiver = (id<DKDSecureMessageDelegate>)[self delegate];
    NSAssert(transceiver, @"message delegate not set yet");
    // 1. sign with sender's private key
    NSData *signature = [transceiver message:self signData:self.data forSender:self.sender];
    NSAssert(signature, @"failed to sign message: %@", self);
    NSObject *b64 = [transceiver message:self encodeSignature:signature];
    NSAssert(b64, @"failed to encode signature: %@", signature);
    // 2. pack message
    NSMutableDictionary *mDict = [self dictionary:NO];
    [mDict setObject:b64 forKey:@"signature"];
    return DKDReliableMessageParse(mDict);
}

- (NSArray<id<DKDSecureMessage>> *)splitForMembers:(NSArray<id<MKMID>> *)members {
    NSMutableDictionary *msg = [self dictionary:NO];
    // check 'keys'
    NSDictionary *keyMap = self.encryptedKeys;
    if (keyMap) {
        [msg removeObjectForKey:@"keys"];
    }
    
    // 1. move the receiver(group ID) to 'group'
    //    this will help the receiver knows the group ID
    //    when the group message separated to multi-messages;
    //    if don't want the others know your membership,
    //    DON'T do this.
    id<MKMID> receiver = [self receiver];
    NSAssert([receiver isGroup], @"receiver error: %@", receiver);
    [msg setObject:[receiver string] forKey:@"group"];
    
    NSMutableArray *messages;
    messages = [[NSMutableArray alloc] initWithCapacity:members.count];
    NSString *b64;
    id<DKDSecureMessage> item;
    for (id<MKMID> mem in members) {
        // 2. change receiver to each group member
        [msg setObject:[mem string] forKey:@"receiver"];
        // 3. get encrypted key
        b64 = [keyMap objectForKey:[mem string]];
        if (b64) {
            [msg setObject:b64 forKey:@"key"];
        } else {
            [msg removeObjectForKey:@"key"];
        }
        // 4. repack message
        item = DKDSecureMessageParse(MKMCopyMap(msg));
        if (item) {
            [messages addObject:item];
        }
    }
    return messages;
}

- (id<DKDSecureMessage>)trimForMember:(id<MKMID>)member {
    NSMutableDictionary *mDict = [self dictionary:NO];
    // check 'keys'
    NSDictionary *keys = [mDict objectForKey:@"keys"];
    if (keys) {
        NSString *b64 = [keys objectForKey:[member string]];
        if (b64) {
            [mDict setObject:b64 forKey:@"key"];
        }
        [mDict removeObjectForKey:@"keys"];
    }
    // check 'group'
    id<MKMID> group = [self group];
    if (!group) {
        // if 'group' not exists, the 'receiver' must be a group ID here, and
        // it will not be equal to the member of course,
        // so move 'receiver' to 'group'
        id<MKMID> receiver = [self receiver];
        NSAssert([receiver isGroup], @"receiver error: %@", receiver);
        [mDict setObject:[receiver string] forKey:@"group"];
    }
    // replace receiver
    [mDict setObject:[member string] forKey:@"receiver"];
    // repack
    return DKDSecureMessageParse(mDict);
}

@end

#pragma mark -

@implementation DIMSecureMessageFactory

- (nullable id<DKDSecureMessage>)parseSecureMessage:(NSDictionary *)msg {
    // check 'sender', 'data'
    id sender = [msg objectForKey:@"sender"];
    id data = [msg objectForKey:@"data"];
    if (!sender || !data) {
        // msg.sender should not be empty
        // msg.data should not be empty
        return nil;
    }
    // check 'signature'
    id signature = [msg objectForKey:@"signature"];
    if ([signature length] > 0) {
        return [[DIMReliableMessage alloc] initWithDictionary:msg];
    }
    return [[DIMSecureMessage alloc] initWithDictionary:msg];
}

@end
