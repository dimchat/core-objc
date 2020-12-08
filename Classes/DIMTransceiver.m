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

#import "DIMForwardContent.h"
#import "DIMTextContent.h"
#import "DIMFileContent.h"
#import "DIMImageContent.h"
#import "DIMAudioContent.h"
#import "DIMVideoContent.h"
#import "DIMWebpageContent.h"

#import "DIMCommand.h"
#import "DIMHistoryCommand.h"
#import "DIMGroupCommand.h"

#import "DIMMetaCommand.h"
#import "DIMDocumentCommand.h"

#import "DIMBarrack.h"

#import "DIMFileContent.h"

#import "DIMTransceiver.h"

static inline void loadContentClasses(void) {
    DIMContentParser *parser = [[DIMContentParser alloc] init];
    
    // Top-Secret
    [DKDContentFactory registerParser:parser forType:DKDContentType_Forward];
    
    // Text
    [DKDContentFactory registerParser:parser forType:DKDContentType_Text];
    
    // File
    [DKDContentFactory registerParser:parser forType:DKDContentType_File];
    // Image
    [DKDContentFactory registerParser:parser forType:DKDContentType_Image];
    // Audio
    [DKDContentFactory registerParser:parser forType:DKDContentType_Audio];
    // Video
    [DKDContentFactory registerParser:parser forType:DKDContentType_Video];
    
    // Web Page
    [DKDContentFactory registerParser:parser forType:DKDContentType_Page];
    
    // Command
    [DKDContentFactory registerParser:parser forType:DKDContentType_Command];
    // History Command
    [DKDContentFactory registerParser:parser forType:DKDContentType_History];
}

static inline void loadCommandClasses(void) {
    DIMCommandParser *parser = [[DIMCommandParser alloc] init];
    
    // meta
    [DIMCommand registerParser:parser forCommand:DIMCommand_Meta];
    // document
    [DIMCommand registerParser:parser forCommand:DIMCommand_Document];
    [DIMCommand registerParser:parser forCommand:DIMCommand_Profile];
}

static inline BOOL isBroadcast(id<DKDMessage> msg, DIMTransceiver *tranceiver) {
    if (!msg.delegate) {
        msg.delegate = tranceiver;
    }
    id<MKMID>receiver;
    if ([msg conformsToProtocol:@protocol(DKDInstantMessage)]) {
        id<DKDInstantMessage>iMsg = (id<DKDInstantMessage>)msg;
        receiver = iMsg.content.group;
    } else {
        receiver = msg.envelope.group;
    }
    if (!receiver) {
        receiver = msg.envelope.receiver;
    }
    return MKMIDIsBroadcast(receiver);
}

@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        
        // delegates
        _barrack = nil;
        _keyCache = nil;
        
        // register all command/contant classes
        //SingletonDispatchOnce(^{
            // register content classes
            loadContentClasses();
            // register commands
            loadCommandClasses();
        //});
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
    MKMUser *contact = [_barrack userWithID:receiver];
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
                  decryptKey:(nullable NSData *)key
                        from:(id<MKMID>)sender
                          to:(id<MKMID>)receiver {
    if (!key) {
        return nil;
    }
    NSAssert(!isBroadcast(sMsg, self), @"broadcast message has no key: %@", sMsg);
    // decrypt key data with the receiver/group member's private key
    id<MKMID>ID = sMsg.envelope.receiver;
    MKMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to get decrypt keys: %@", ID);
    NSData *plaintext = [user decrypt:key];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt key: %@", sMsg);
        return nil;
    }
    return plaintext;
}

- (nullable id<MKMSymmetricKey>)message:(id<DKDSecureMessage>)sMsg
                       deserializeKey:(NSData *)data
                                 from:(id<MKMID>)sender
                                   to:(id<MKMID>)receiver {
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
        return [_keyCache cipherKeyFrom:sender to:receiver];
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
    // decrypt message.data
    NSData *plaintext = [password decrypt:data];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt data: %@, key: %@, env: %@", data, password, sMsg.envelope);
        return nil;
    }
    return plaintext;
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
        id<MKMID>sender = sMsg.envelope.sender;
        id<MKMID>group = [self overtGroupForContent:content];
        if (group) {
            // group message (excludes group command)
            // cache the key with direction (sender -> group)
            [_keyCache cacheCipherKey:password from:sender to:group];
        } else {
            id<MKMID>receiver = sMsg.envelope.receiver;
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
    MKMUser *user = [_barrack userWithID:sender];
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
    MKMUser *user = [_barrack userWithID:sender];
    NSAssert(user, @"failed to get verify key for sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end
