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
#import "DIMProfileCommand.h"

#import "DIMBarrack.h"

#import "DIMFileContent.h"

#import "DIMTransceiver.h"

static inline void loadContentClasses(void) {
    // Top-Secret
    DKDContentParserRegister(DKDContentType_Forward, DIMForwardContent);
    
    // Text
    DKDContentParserRegister(DKDContentType_Text, DIMTextContent);
    
    // File
    DKDContentParserRegister(DKDContentType_File, DIMFileContent);
    // Image
    DKDContentParserRegister(DKDContentType_Image, DIMImageContent);
    // Audio
    DKDContentParserRegister(DKDContentType_Audio, DIMAudioContent);
    // Video
    DKDContentParserRegister(DKDContentType_Video, DIMVideoContent);
    
    // Web Page
    DKDContentParserRegister(DKDContentType_Page, DIMWebpageContent);
    
    // Command
    DKDContentParserRegisterCall(DKDContentType_Command, DIMCommand);
    // History Command
    DKDContentParserRegisterCall(DKDContentType_History, DIMHistoryCommand);
}

static inline void loadCommandClasses(void) {
    // meta
    DIMCommandParserRegister(DIMCommand_Meta, DIMMetaCommand);
    // profile
    DIMCommandParserRegister(DIMCommand_Profile, DIMProfileCommand);
}

static inline void loadGroupCommandClasses(void) {
    // invite
    DIMCommandParserRegister(DIMGroupCommand_Invite, DIMInviteCommand);
    // expel
    DIMCommandParserRegister(DIMGroupCommand_Expel, DIMExpelCommand);
    // join
    DIMCommandParserRegister(DIMGroupCommand_Join, DIMJoinCommand);
    // quit
    DIMCommandParserRegister(DIMGroupCommand_Quit, DIMQuitCommand);
    
    // reset
    DIMCommandParserRegister(DIMGroupCommand_Reset, DIMResetGroupCommand);
    // query
    DIMCommandParserRegister(DIMGroupCommand_Query, DIMQueryGroupCommand);
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
    return [MKMID isBroadcast:receiver];
}

static inline id<MKMID>overt_group(id<DKDContent> content) {
    id<MKMID>group = content.group;
    if (!group) {
        return nil;
    }
    if ([MKMID isBroadcast:group]) {
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
            // register group command classes
            loadGroupCommandClasses();
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
    if ([MKMID isBroadcast:group]) {
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
        id<MKMID>group = overt_group(content);
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

#pragma mark -

@implementation DIMTransceiver (Serialization)

- (nullable NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    return MKMJSONEncode(rMsg);
}

- (nullable id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    NSDictionary *dict = MKMJSONDecode(data);
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

@end

@implementation DIMTransceiver (Transform)

- (id<MKMSymmetricKey>)_passwordFrom:(id<MKMID>)sender to:(id<MKMID>)receiver {
    // get old key from store
    id<MKMSymmetricKey>key = [_keyCache cipherKeyFrom:sender to:receiver];
    if (!key) {
        // create new key and cache it
        key = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        NSAssert(key, @"failed to generate AES key");
        [_keyCache cacheCipherKey:key from:sender to:receiver];
    }
    return key;
}

- (nullable id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    // check message delegate
    if (!iMsg.delegate) {
        iMsg.delegate = self;
    }
    id<MKMID>sender = iMsg.envelope.sender;
    id<MKMID>receiver = iMsg.envelope.receiver;
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
    //         share the symmetric key (group msg key) with other members.

    // 1. get symmetric key
    id<MKMID>group = overt_group(iMsg.content);
    id<MKMSymmetricKey> password;
    if (group) {
        // group message (excludes group command)
        password = [self _passwordFrom:sender to:group];
    } else {
        // personal message or (group) command
        password = [self _passwordFrom:sender to:receiver];
    }

    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 2. encrypt 'content' to 'data' for receiver/group members
    id<DKDSecureMessage>sMsg = nil;
    if ([MKMID isGroup:receiver]) {
        // group message
        MKMGroup *grp = [_barrack groupWithID:receiver];
        sMsg = [iMsg encryptWithKey:password forMembers:grp.members];
    } else {
        // personal message (or split group message)
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

- (nullable id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg {
    // check message delegate
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"message data cannot be empty");
    // sign 'data' by sender
    return [sMsg sign];
}

- (nullable id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
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

- (nullable id<DKDInstantMessage>)decryptMessage:(id<DKDSecureMessage>)sMsg {
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
