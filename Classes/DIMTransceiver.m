//
//  DIMTransceiver.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

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

#import "DIMBarrack.h"
#import "DIMKeyCache.h"

#import "DIMFileContent.h"

#import "DIMTransceiver.h"

static inline void loadContentClasses(void) {
    
    // Text
    [DIMContent registerClass:[DIMTextContent class] forType:DKDContentType_Text];
    
    // File
    [DIMContent registerClass:[DIMFileContent class] forType:DKDContentType_File];
    // Image
    [DIMContent registerClass:[DIMImageContent class] forType:DKDContentType_Image];
    // Audio
    [DIMContent registerClass:[DIMAudioContent class] forType:DKDContentType_Audio];
    // Video
    [DIMContent registerClass:[DIMVideoContent class] forType:DKDContentType_Video];
    
    // Web Page
    [DIMContent registerClass:[DIMWebpageContent class] forType:DKDContentType_Page];
    
    // Command
    [DIMContent registerClass:[DIMCommand class] forType:DKDContentType_Command];
    // (Group) History Command
    [DIMContent registerClass:[DIMHistoryCommand class] forType:DKDContentType_History];
}

static inline void loadGroupCommandClasses(void) {
    
    // invite
    [DIMCommand registerClass:[DIMInviteCommand class] forCommand:DIMGroupCommand_Invite];
    // expel
    [DIMCommand registerClass:[DIMExpelCommand class] forCommand:DIMGroupCommand_Expel];
    // join
    [DIMCommand registerClass:[DIMJoinCommand class] forCommand:DIMGroupCommand_Join];
    // quit
    [DIMCommand registerClass:[DIMQuitCommand class] forCommand:DIMGroupCommand_Quit];
    
    // reset
    [DIMCommand registerClass:[DIMResetGroupCommand class] forCommand:DIMGroupCommand_Reset];
    // query
    [DIMCommand registerClass:[DIMQueryGroupCommand class] forCommand:DIMGroupCommand_Query];
}

static inline BOOL isBroadcast(DIMMessage *msg,
                               id<DIMSocialNetworkDataSource> barrack) {
    DIMID *receiver = [barrack IDWithString:msg.envelope.group];
    if (!receiver) {
        receiver = [barrack IDWithString:msg.envelope.receiver];
    }
    return [receiver isBroadcast];
}

@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        
        // delegates
        _barrack = nil;
        _keyCache = nil;
        _delegate = nil;
        
        // register all content classes
        loadContentClasses();
        // register group command classes
        loadGroupCommandClasses();
    }
    return self;
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
            serializeContent:(DIMContent *)content {
    NSString *json = [content jsonString];
    return [json data];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                serializeKey:(DIMSymmetricKey *)password {
    if (isBroadcast(iMsg, _barrack)) {
        // broadcast message has no key
        NSAssert(false, @"should not call this");
        return nil;
    }
    NSString *json = [password jsonString];
    return [json data];
}

- (nullable DIMSymmetricKey *)message:(DIMSecureMessage *)sMsg
                       deserializeKey:(NSData *)data {
    NSDictionary *dict = [data jsonDictionary];
    // TODO: translate short keys
    //       'A' -> 'algorithm'
    //       'D' -> 'data'
    //       'M' -> 'mode'
    //       'P' -> 'padding'
    return MKMSymmetricKeyFromDictionary(dict);
}

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
              deserializeContent:(NSData *)data {
    NSDictionary *dict = [data jsonDictionary];
    // TODO: translate short keys
    //       'S' -> 'sender'
    //       'R' -> 'receiver'
    //       'T' -> 'time'
    //       'D' -> 'data'
    //       'V' -> 'signature'
    //       'K' -> 'key'
    //       'M' -> 'meta'
    return DKDContentFromDictionary(dict);
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
    NSAssert(key == password, @"irregular symmetric key: %@", password);
    
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.fileData != nil, @"content.fileData should not be empty");
        NSAssert(file.URL == nil, @"content.URL exists, already uploaded?");
        // encrypt and upload file data onto CDN and save the URL in message content
        NSData *CT = [key encrypt:file.fileData];
        NSURL *url = [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
        if (url) {
            // replace 'data' with 'URL'
            file.URL = url;
            file.fileData = nil;
        }
        //[iMsg setObject:file forKey:@"content"];
    }
    
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
    //NSAssert(contact, @"failed to encrypt key for receiver: %@", receiver);
    return [contact encrypt:data];
}

- (nullable NSObject *)message:(DIMInstantMessage *)iMsg
                     encodeKey:(NSData *)data {
    if (isBroadcast(iMsg, _barrack)) {
        NSAssert(false, @"broadcast message has no key");
        return nil;
    }
    return [data base64Encode];
}

#pragma mark DKDSecureMessageDelegate

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                   decodeKey:(NSObject *)dataString {
    if (isBroadcast(sMsg, _barrack)) {
        NSAssert(false, @"broadcast message has no key");
        return nil;
    }
    return [(NSString *)dataString base64Decode];
}

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                        decryptKey:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver {
    NSAssert(!isBroadcast(sMsg, _barrack) || !key, @"broadcast message has no key");
    DIMID *from = [_barrack IDWithString:sender];
    DIMID *to = [_barrack IDWithString:receiver];
    
    DIMSymmetricKey *PW = nil;
    if (key) {
        // decrypt key data with the receiver/group member's private key
        DIMID *ID = [_barrack IDWithString:sMsg.envelope.receiver];
        DIMLocalUser *user = [_barrack userWithID:ID];
        NSAssert(user, @"failed to decrypt key for receiver: %@, %@", receiver, ID);
        NSData *plaintext = [user decrypt:key];
        NSAssert(plaintext.length > 0, @"failed to decrypt key in msg: %@", sMsg);
        // deserialize it to symmetric key
        PW = [self message:sMsg deserializeKey:plaintext];
        // cache the new key in key store
        [_keyCache cacheCipherKey:PW from:from to:to];
        //NSLog(@"got key from %@ to %@", sender, receiver);
    }
    if (!PW) {
        // if key data is empty, get it from key store
        PW = [_keyCache cipherKeyFrom:from to:to];
        NSAssert(PW, @"failed to get password from %@ to %@", sender, receiver);
    }
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
        NSAssert(false, @"failed to decrypt data: %@, key: %@", data, password);
        return nil;
    }
    DIMContent *content = [self message:sMsg deserializeContent:plaintext];
    NSAssert([content isKindOfClass:[DIMContent class]], @"error: %@", sMsg);
    
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.URL != nil, @"content.URL should not be empty");
        NSAssert(file.fileData == nil, @"content.fileData already download");
        DIMInstantMessage *iMsg;
        iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                                 envelope:sMsg.envelope];
        // download from CDN
        NSData *fileData = [_delegate downloadEncryptedFileData:file.URL
                                                     forMessage:iMsg];
        if (fileData) {
            // decrypt file data
            file.fileData = [key decrypt:fileData];
            file.URL = nil;
        } else {
            // save the symmetric key for decrypte file data later
            file.password = key;
        }
        //content = file;
    }
    
    return content;
}

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                    signData:(NSData *)data
                   forSender:(NSString *)sender {
    DIMID *ID = [_barrack IDWithString:sender];
    DIMLocalUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to sign with sender: %@", sender);
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
    NSAssert(user, @"failed to verify with sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end

@implementation DIMTransceiver (Transform)

- (DIMSymmetricKey *)_passwordFrom:(DIMID *)sender to:(DIMID *)receiver {
    // 1. get old key from store
    DIMSymmetricKey *reusedKey;
    reusedKey = [_keyCache cipherKeyFrom:sender to:receiver];
    // 2. get new key from delegate
    DIMSymmetricKey *newKey;
    newKey = [_keyCache reuseCipherKey:reusedKey from:sender to:receiver];
    if (!newKey) {
        if (!reusedKey) {
            // 3. create a new key
            newKey = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        } else {
            newKey = reusedKey;
        }
    }
    // 4. update new key into the key store
    if (![newKey isEqual:reusedKey]) {
        [_keyCache cacheCipherKey:newKey from:sender to:receiver];
    }
    return newKey;
}

- (nullable DIMSecureMessage *)encryptMessage:(DIMInstantMessage *)iMsg {
    DIMID *sender = [_barrack IDWithString:iMsg.envelope.sender];
    DIMID *receiver = [_barrack IDWithString:iMsg.envelope.receiver];
    // if 'group' exists and the 'receiver' is a group ID,
    // they must be equal
    DIMID *group = [_barrack IDWithString:iMsg.content.group];

    // 1. get symmetric key
    DIMSymmetricKey *password = nil;
    if (group) {
        // group message
        password = [self _passwordFrom:sender to:group];
    } else {
        password = [self _passwordFrom:sender to:receiver];
    }
    
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 2. encrypt 'content' to 'data' for receiver/group members
    DIMSecureMessage *sMsg = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group message
        DIMGroup *grp = [_barrack groupWithID:receiver];
        sMsg = [iMsg encryptWithKey:password forMembers:grp.members];
    } else {
        // personal message (or split group message)
        NSAssert(MKMNetwork_IsUser(receiver.type), @"error ID: %@", receiver);
        sMsg = [iMsg encryptWithKey:password];
    }
    
    // OK
    sMsg.delegate = self;
    return sMsg;
}

- (nullable DIMReliableMessage *)signMessage:(DIMSecureMessage *)sMsg {
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 1. sign 'data' by sender
    DIMReliableMessage *rMsg = [sMsg sign];
    
    // OK
    rMsg.delegate = self;
    return rMsg;
}

- (nullable DIMSecureMessage *)verifyMessage:(DIMReliableMessage *)rMsg {
    //
    //  TODO: check [Meta Protocol]
    //        make sure the sender's meta exists
    //        (do in by application)
    //
    
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    NSAssert(rMsg.signature, @"signature cannot be empty");
    
    // 1. verify 'data' with 'signature'
    DIMSecureMessage *sMsg = [rMsg verify];
    
    // OK
    sMsg.delegate = self;
    return sMsg;
}

- (nullable DIMInstantMessage *)decryptMessage:(DIMSecureMessage *)sMsg {
    //
    //  NOTICE: make sure the receiver is YOU!
    //          which means the receiver's private key exists;
    //          if the receiver is a group ID, split it first
    //
    
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    
    // 1. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = [sMsg decrypt];
    
    // TODO: check: top-secret message
    //       (do it by application)
    
    // OK
    iMsg.delegate = self;
    return iMsg;
}

@end
