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

- (DIMSymmetricKey *)passwordFrom:(DIMID *)sender to:(DIMID *)receiver {
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

- (DIMSymmetricKey *)password:(NSDictionary *)pw from:(DIMID *)sender to:(DIMID *)receiver {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(pw);
    if (key) {
        // cache the new key in key store
        [_keyCache cacheCipherKey:key from:sender to:receiver];
        NSLog(@"got key from %@ to %@", sender, receiver);
    }
    return key;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    
    // encrypt it with password
    NSString *json = [content jsonString];
    NSData *data = [json data];
    return [symmetricKey encrypt:data];
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
    // TODO: check whether support reused key
    
    // encrypt with receiver's public key
    DIMID *ID = [_barrack IDWithString:receiver];
    DIMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to encrypt with receiver: %@", receiver);
    NSString *json = [password jsonString];
    NSData *data = [json data];
    return [user encrypt:data];
}

- (nullable NSObject *)message:(DIMInstantMessage *)iMsg
                 encodeKeyData:(NSData *)keyData {
    NSAssert(!isBroadcast(iMsg, _barrack) || !keyData, @"broadcast message has no key");
    // encode to Base64
    return [keyData base64Encode];
}

#pragma mark DKDSecureMessageDelegate

- (nullable DIMContent *)message:(DIMSecureMessage *)sMsg
                     decryptData:(NSData *)data
                         withKey:(NSDictionary *)password {
    DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    
    // decrypt message.data
    NSData *plaintext = [symmetricKey decrypt:data];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt data: %@, key: %@", data, password);
        return nil;
    }
    
    // build Content with JsON
    NSDictionary *dict = [plaintext jsonDictionary];
    return DKDContentFromDictionary(dict);
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

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                    decryptKeyData:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver {
    NSAssert(!isBroadcast(sMsg, _barrack) || !key, @"broadcast message has no key");
    DIMID *from = [_barrack IDWithString:sender];
    DIMID *to = [_barrack IDWithString:receiver];
    
    DIMSymmetricKey *PW = nil;
    if (key) {
        // decrypt key data with the receiver's private key
        DIMID *ID = [_barrack IDWithString:sMsg.envelope.receiver];
        DIMLocalUser *user = [_barrack userWithID:ID];
        NSAssert(user, @"failed to decrypt for receiver: %@", receiver);
        NSData *plaintext = [user decrypt:key];
        NSAssert(plaintext.length > 0, @"failed to decrypt key in msg: %@", sMsg);
        // create symmetric key from JsON data
        NSString *json = [plaintext UTF8String]; // remove garbage at end
        NSDictionary *dict = [[json data] jsonDictionary];
        PW = [self password:dict from:from to:to];
    }
    if (!PW) {
        // if key data is empty, get it from key store
        PW = [self passwordFrom:from to:to];
        NSAssert(PW, @"failed to get password from %@ to %@", sender, receiver);
    }
    return PW;
}

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
               decodeKeyData:(NSObject *)keyString {
    NSAssert(!isBroadcast(sMsg, _barrack) || !keyString, @"broadcast message has no key");
    return [(NSString *)keyString base64Decode];
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

- (BOOL)message:(DIMReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender {
    DIMID *ID = [_barrack IDWithString:sender];
    DIMUser *user = [_barrack userWithID:ID];
    NSAssert(user, @"failed to verify with sender: %@", sender);
    return [user verify:data withSignature:signature];
}

- (nullable NSData *)message:(DIMReliableMessage *)rMsg
             decodeSignature:(NSObject *)signatureString {
    return [(NSString *)signatureString base64Decode];
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