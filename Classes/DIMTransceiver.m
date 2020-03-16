// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMTextContent.h"
#import "DIMFileContent.h"
#import "DIMImageContent.h"
#import "DIMAudioContent.h"
#import "DIMVideoContent.h"
#import "DIMWebpageContent.h"

#import "DIMCommand.h"
#import "DIMHistoryCommand.h"
#import "DIMGroupCommand.h"

#import "DIMHandshakeCommand.h"
#import "DIMMetaCommand.h"
#import "DIMProfileCommand.h"

#import "DIMBarrack.h"
#import "DIMKeyCache.h"

#import "DIMFileContent.h"

#import "DIMTransceiver.h"

static inline void loadContentClasses(void) {
    // Text
    [DIMContent registerClass:[DIMTextContent class]
                      forType:DKDContentType_Text];
    
    // File
    [DIMContent registerClass:[DIMFileContent class]
                      forType:DKDContentType_File];
    // Image
    [DIMContent registerClass:[DIMImageContent class]
                      forType:DKDContentType_Image];
    // Audio
    [DIMContent registerClass:[DIMAudioContent class]
                      forType:DKDContentType_Audio];
    // Video
    [DIMContent registerClass:[DIMVideoContent class]
                      forType:DKDContentType_Video];
    
    // Web Page
    [DIMContent registerClass:[DIMWebpageContent class]
                      forType:DKDContentType_Page];
    
    // Command
    [DIMContent registerClass:[DIMCommand class]
                      forType:DKDContentType_Command];
    // History Command
    [DIMContent registerClass:[DIMHistoryCommand class]
                      forType:DKDContentType_History];
}

static inline void loadCommandClasses(void) {
    // handshake
    [DIMCommand registerClass:[DIMHandshakeCommand class]
                   forCommand:DIMCommand_Handshake];
    
    // meta
    [DIMCommand registerClass:[DIMMetaCommand class]
                   forCommand:DIMCommand_Meta];
    // profile
    [DIMCommand registerClass:[DIMProfileCommand class]
                   forCommand:DIMCommand_Profile];
}

static inline void loadGroupCommandClasses(void) {
    // invite
    [DIMGroupCommand registerClass:[DIMInviteCommand class]
                        forCommand:DIMGroupCommand_Invite];
    // expel
    [DIMGroupCommand registerClass:[DIMExpelCommand class]
                        forCommand:DIMGroupCommand_Expel];
    // join
    [DIMGroupCommand registerClass:[DIMJoinCommand class]
                        forCommand:DIMGroupCommand_Join];
    // quit
    [DIMGroupCommand registerClass:[DIMQuitCommand class]
                        forCommand:DIMGroupCommand_Quit];
    
    // reset
    [DIMGroupCommand registerClass:[DIMResetGroupCommand class]
                        forCommand:DIMGroupCommand_Reset];
    // query
    [DIMGroupCommand registerClass:[DIMQueryGroupCommand class]
                        forCommand:DIMGroupCommand_Query];
}

static inline BOOL isBroadcast(DIMMessage *msg,
                               id<DIMEntityDelegate> barrack) {
    NSString *receiver;
    if ([msg isKindOfClass:[DIMInstantMessage class]]) {
        DIMInstantMessage *iMsg = (DIMInstantMessage *)msg;
        receiver = iMsg.content.group;
    } else {
        receiver = msg.envelope.group;
    }
    if (!receiver) {
        receiver = msg.envelope.receiver;
    }
    DIMID *ID = [barrack IDWithString:receiver];
    return [ID isBroadcast];
}

static inline DIMID *overt_group(DIMContent *content, id<DIMEntityDelegate> barrack) {
    NSString *group = content.group;
    if (!group) {
        return nil;
    }
    DIMID *ID = [barrack IDWithString:group];
    if ([ID isBroadcast]) {
        // broadcast message is always overt
        return ID;
    }
    if ([content isKindOfClass:[DIMCommand class]]) {
        // group command should be sent to each member directly, so
        // don't expose group ID
        return nil;
    }
    return ID;
}


@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        
        // delegates
        _barrack = nil;
        _keyCache = nil;
        
        // register all command/contant classes
        SingletonDispatchOnce(^{
            // register content classes
            loadContentClasses();
            // register commands
            loadCommandClasses();
            // register group command classes
            loadGroupCommandClasses();
        });
    }
    return self;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key && key == password, @"irregular symmetric key: %@", password);
    // encrypt it with password
    NSData *data = [self message:iMsg serializeContent:content];
    return [key encrypt:data];
}

- (nullable NSObject *)message:(DIMInstantMessage *)iMsg
                    encodeData:(NSData *)data {
    if (isBroadcast(iMsg, _barrack)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so no need to encode to Base64 here
        return [data UTF8String];
    }
    return [data base64Encode];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                  encryptKey:(NSDictionary *)password
                 forReceiver:(NSString *)receiver {
    if (isBroadcast(iMsg, _barrack)) {
        // broadcast message has no key
        return nil;
    }
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    // TODO: check whether support reused key
    
    NSData *data = [self message:iMsg serializeKey:key];
    // encrypt with receiver's public key
    DIMID *ID = [_barrack IDWithString:receiver];
    DIMUser *contact = [_barrack userWithID:ID];
    NSAssert(contact, @"failed to get encrypt key for receiver: %@", receiver);
    return [contact encrypt:data];
}

- (nullable NSObject *)message:(DIMInstantMessage *)iMsg
                     encodeKey:(NSData *)data {
    NSAssert(!isBroadcast(iMsg, _barrack), @"broadcast message has no key: %@", iMsg);
    return [data base64Encode];
}

#pragma mark DKDSecureMessageDelegate

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                   decodeKey:(NSObject *)dataString {
    NSAssert(!isBroadcast(sMsg, _barrack), @"broadcast message has no key: %@", sMsg);
    return [(NSString *)dataString base64Decode];
}

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                        decryptKey:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver {
    NSAssert(!isBroadcast(sMsg, _barrack) || !key, @"broadcast message has no key: %@", sMsg);
    DIMID *from = [_barrack IDWithString:sender];
    DIMID *to = [_barrack IDWithString:receiver];
    
    DIMSymmetricKey *PW = nil;
    if (key) {
        // decrypt key data with the receiver/group member's private key
        DIMID *ID = [_barrack IDWithString:sMsg.envelope.receiver];
        DIMUser *user = [_barrack userWithID:ID];
        NSAssert(user, @"failed to get decrypt keys: %@", ID);
        NSData *plaintext = [user decrypt:key];
        if (plaintext.length == 0) {
            NSAssert(false, @"failed to decrypt key: %@", sMsg);
            return nil;
        }
        // deserialize it to symmetric key
        PW = [self message:sMsg deserializeKey:plaintext];
    } else {
        // get key from cache
        PW = [_keyCache cipherKeyFrom:from to:to];
    }
    NSAssert(PW, @"failed to get password from %@ to %@", sender, receiver);
    return PW;
}

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                  decodeData:(NSObject *)dataString {
    if (isBroadcast(sMsg, _barrack)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so return the string data directly
        return [(NSString *)dataString data];
    }
    return [(NSString *)dataString base64Decode];
}

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
                  decryptContent:(NSData *)data
                         withKey:(NSDictionary *)password {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    
    // decrypt message.data
    NSData *plaintext = [key decrypt:data];
    if (plaintext.length == 0) {
        //NSAssert(false, @"failed to decrypt data: %@, key: %@", data, password);
        return nil;
    }
    DIMContent *content = [self message:sMsg deserializeContent:plaintext];
    NSAssert([content isKindOfClass:[DIMContent class]], @"error: %@", sMsg);
    
    // check and cache key for reuse
    DIMID *sender = [self.barrack IDWithString:sMsg.envelope.sender];
    DIMID *group = overt_group(content, self.barrack);
    if (group) {
        // group message (excludes group command)
        // cache the key with direction (sender -> group)
        [_keyCache cacheCipherKey:key from:sender to:group];
    } else {
        DIMID *receiver = [self.barrack IDWithString:sMsg.envelope.receiver];
        // personal message or (group) command
        // cache key with direction (sender -> receiver)
        [_keyCache cacheCipherKey:key from:sender to:receiver];
    }
    
    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         after deserialize content, this job should be do in subclass
    return content;
}

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                    signData:(NSData *)data
                   forSender:(NSString *)sender {
    DIMID *ID = [_barrack IDWithString:sender];
    DIMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to get sign key for sender: %@", sender);
    return [user sign:data];
}

- (nullable NSObject *)message:(DIMSecureMessage *)sMsg
               encodeSignature:(NSData *)signature {
    return [signature base64Encode];
}

#pragma mark DKDReliableMessageDelegate

- (nullable NSData *)message:(DIMReliableMessage *)rMsg
             decodeSignature:(NSObject *)signatureString {
    return [(NSString *)signatureString base64Decode];
}

- (BOOL)message:(DIMReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender {
    DIMID *ID = [_barrack IDWithString:sender];
    DIMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to get verify key for sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end

#pragma mark - De/serialize message content and symmetric key

@implementation DIMTransceiver (Serialization)

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
            serializeContent:(DIMContent *)content {
    NSAssert(content == iMsg.content, @"message content not match: %@", content);
    NSString *json = [content jsonString];
    return [json data];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                serializeKey:(DIMSymmetricKey *)password {
    NSAssert(!isBroadcast(iMsg, _barrack), @"broadcast message has no key: %@", iMsg);
    NSString *json = [password jsonString];
    return [json data];
}

- (nullable NSData *)serializeMessage:(DIMReliableMessage *)rMsg {
    return [rMsg jsonData];
}

- (nullable DIMReliableMessage *)deserializeMessage:(NSData *)data {
    NSDictionary *dict = [data jsonDictionary];
    // TODO: translate short keys
    //       'S' -> 'sender'
    //       'R' -> 'receiver'
    //       'W' -> 'time'
    //       'T' -> 'type'
    //       'G' -> 'group'
    //       ------------------
    //       'D' -> 'data'
    //       'V' -> 'signature'
    //       'K' -> 'key'
    //       ------------------
    //       'M' -> 'meta'
    return DKDReliableMessageFromDictionary(dict);
}

- (nullable DIMSymmetricKey *)message:(DIMSecureMessage *)sMsg
                       deserializeKey:(NSData *)data {
    NSAssert(!isBroadcast(sMsg, _barrack), @"broadcast message has no key: %@", sMsg);
    NSDictionary *dict = [data jsonDictionary];
    // TODO: translate short keys
    //       'A' -> 'algorithm'
    //       'D' -> 'data'
    //       'V' -> 'iv'
    //       'M' -> 'mode'
    //       'P' -> 'padding'
    return MKMSymmetricKeyFromDictionary(dict);
}

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
              deserializeContent:(NSData *)data {
    NSDictionary *dict = [data jsonDictionary];
    // TODO: translate short keys
    //       'T' -> 'type'
    //       'N' -> 'sn'
    //       'G' -> 'group'
    return DKDContentFromDictionary(dict);
}

@end

#pragma mark - Transform

@implementation DIMTransceiver (Transform)

- (DIMSymmetricKey *)_passwordFrom:(DIMID *)sender to:(DIMID *)receiver {
    // get old key from store
    DIMSymmetricKey *key = [_keyCache cipherKeyFrom:sender to:receiver];
    if (!key) {
        // create new key and cache it
        key = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        NSAssert(key, @"failed to generate AES key");
        [_keyCache cacheCipherKey:key from:sender to:receiver];
    }
    return key;
}

- (nullable DIMSecureMessage *)encryptMessage:(DIMInstantMessage *)iMsg {
    DIMID *sender = [_barrack IDWithString:iMsg.envelope.sender];
    DIMID *receiver = [_barrack IDWithString:iMsg.envelope.receiver];
    // if 'group' exists and the 'receiver' is a group ID,
    // they must be equal
    
    // NOTICE: while sending group message, don't split it before encrypting.
    //         this means you could set group ID into message content, but
    //         keep the "receiver" to be the group ID;
    //         after encrypted (and signed), you could split the message
    //         with group members before sending out, or just send it directly
    //         to the group assistant to let it split messages for you!
    //    BUT,
    //         if you don't want to share the symmetric key with other members,
    //         you could split it (set group ID into message content and
    //         set contact ID to the "receiver") before encrypting, this usually
    //         for sending group command to assistant robot, which should not
    //         shared the symmetric key (group msg key) with other members.

    // 1. get symmetric key
    DIMID *group = overt_group(iMsg.content, self.barrack);
    DIMSymmetricKey *password;
    if (group) {
        // group message (excludes group command)
        password = [self _passwordFrom:sender to:group];
    } else {
        // personal message or (group) command
        password = [self _passwordFrom:sender to:receiver];
    }

    // check message delegate
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 2. encrypt 'content' to 'data' for receiver/group members
    DIMSecureMessage *sMsg = nil;
    if ([receiver isGroup]) {
        // group message
        DIMGroup *grp = [_barrack groupWithID:receiver];
        sMsg = [iMsg encryptWithKey:password forMembers:grp.members];
    } else {
        // personal message (or split group message)
        NSAssert([receiver isUser], @"receiver ID error: %@", receiver);
        sMsg = [iMsg encryptWithKey:password];
    }
    
    // overt group ID
    if (group && ![receiver isEqual:group]) {
        // NOTICE: this help the receiver knows the group ID
        //         when the group message separated to multi-messages,
        //         if don't want the others know you are the group members,
        //         remove it.
        sMsg.envelope.group = group;
    }
    
    // NOTICE: copy content type to envelope
    //         this help the intermediate nodes to recognize message type
    sMsg.envelope.type = iMsg.content.type;

    // OK
    return sMsg;
}

- (nullable DIMReliableMessage *)signMessage:(DIMSecureMessage *)sMsg {
    // check message delegate
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"message data cannot be empty");
    // sign 'data' by sender
    return [sMsg sign];
}

- (nullable DIMSecureMessage *)verifyMessage:(DIMReliableMessage *)rMsg {
    //
    //  TODO: check [Meta Protocol]
    //        make sure the sender's meta exists
    //        (do in by application)
    //
    
    // check message delegate
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    NSAssert(rMsg.signature, @"message signature cannot be empty");
    // verify 'data' with 'signature'
    return [rMsg verify];
}

- (nullable DIMInstantMessage *)decryptMessage:(DIMSecureMessage *)sMsg {
    //
    //  NOTICE: make sure the receiver is YOU!
    //          which means the receiver's private key exists;
    //          if the receiver is a group ID, split it first
    //
    
    // check message delegate
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"message data cannot be empty");
    // decrypt 'data' to 'content'
    return [sMsg decrypt];
    
    // TODO: check: top-secret message
    //       (do it by application)
}

@end
