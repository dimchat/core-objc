//
//  DIMProtocol.m
//  DIMCore
//
//  Created by Albert Moky on 2019/8/14.
//  Copyright © 2019 DIM Group. All rights reserved.
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

#import "DIMBarrack.h"
#import "DIMKeyCache.h"

#import "DIMProtocol.h"

static inline BOOL isBroadcast(DIMMessage *msg,
                               id<DIMSocialNetworkDataSource> barrack) {
    DIMID *receiver = [barrack IDWithString:[msg group]];
    if (receiver) {
        // group message
        return MKMIsEveryone(receiver);
    }
    receiver = [barrack IDWithString:msg.envelope.receiver];
    // group or split message
    return MKMIsBroadcast(receiver);
}

@implementation DIMProtocol

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
    NSAssert(contact, @"failed to encrypt key for receiver: %@", receiver);
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
    return [self message:sMsg deserializeContent:plaintext];
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

@implementation DIMContent (Plugins)

+ (void)loadContentClasses {
    
    // Text
    [self registerClass:[DIMTextContent class] forType:DKDContentType_Text];
    
    // File
    [self registerClass:[DIMFileContent class] forType:DKDContentType_File];
    // Image
    [self registerClass:[DIMImageContent class] forType:DKDContentType_Image];
    // Audio
    [self registerClass:[DIMAudioContent class] forType:DKDContentType_Audio];
    // Video
    [self registerClass:[DIMVideoContent class] forType:DKDContentType_Video];
    
    // Web Page
    [self registerClass:[DIMWebpageContent class] forType:DKDContentType_Page];
    
    // Top-Secret
    [self registerClass:[DIMForwardContent class] forType:DKDContentType_Forward];
    
    // Command
    [self registerClass:[DIMCommand class] forType:DKDContentType_Command];
    // (Group) History Command
    [self registerClass:[DIMHistoryCommand class] forType:DKDContentType_History];
}

@end
