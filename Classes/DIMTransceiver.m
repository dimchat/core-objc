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

#import "DIMContentType.h"
#import "DIMFileContent.h"

#import "DIMBarrack.h"
#import "DIMKeyCache.h"

#import "DIMTransceiver.h"

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

@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
    }
    return self;
}

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

- (DIMSymmetricKey *)_password:(NSDictionary *)password
                          from:(DIMID *)sender
                            to:(DIMID *)receiver {
    DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(password);
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
    
    // check attachment for File/Image/Audio/Video message content
    if ([content isKindOfClass:[DIMFileContent class]]) {
        DIMFileContent *file = (DIMFileContent *)content;
        NSAssert(file.fileData != nil, @"content.fileData should not be empty");
        NSAssert(file.URL == nil, @"content.URL exists, already uploaded?");
        // encrypt and upload file data onto CDN and save the URL in message content
        NSData *CT = [symmetricKey encrypt:file.fileData];
        NSURL *url = [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
        if (url) {
            // replace 'data' with 'URL'
            file.URL = url;
            file.fileData = nil;
        }
        //[iMsg setObject:file forKey:@"content"];
    }
    
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
    DIMContent *content = DKDContentFromDictionary(dict);
    NSAssert([content isKindOfClass:[DIMContent class]], @"error: %@", plaintext);
    
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
            file.fileData = [symmetricKey decrypt:fileData];
            file.URL = nil;
        } else {
            // save the symmetric key for decrypte file data later
            file.password = symmetricKey;
        }
        //content = file;
    }
    
    return content;
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
        PW = [self _password:dict from:from to:to];
    }
    if (!PW) {
        // if key data is empty, get it from key store
        PW = [self _passwordFrom:from to:to];
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
