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

#import "DIMBarrack.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - DKDInstantMessageDelegate

- (nullable NSData *)message:(const DKDInstantMessage *)iMsg
              encryptContent:(const DKDMessageContent *)content
                     withKey:(NSDictionary *)password {
    DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
    NSAssert(symmetricKey == password, @"invalid symmetric key: %@", password);
    
    NSString *json = [content jsonString];
    NSData *data = [json data];
    return [symmetricKey encrypt:data];
}

- (nullable NSData *)message:(const DKDInstantMessage *)iMsg
                  encryptKey:(const NSDictionary *)password
                 forReceiver:(const NSString *)receiver {
    NSString *json = [password jsonString];
    NSData *data = [json data];
    DIMID *ID = [DIMID IDWithID:receiver];
    DIMPublicKey *PK = DIMPublicKeyForID(ID);
    NSAssert(PK, @"failed to get public key for receiver: %@", receiver);
    return [PK encrypt:data];
}

#pragma mark - DKDSecureMessageDelegate

- (nullable DKDMessageContent *)message:(const DKDSecureMessage *)sMsg
                            decryptData:(const NSData *)data
                                withKey:(const NSDictionary *)password {
    DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
    NSAssert(symmetricKey, @"invalid symmetric key: %@", password);
    
    NSData *plaintext = [symmetricKey decrypt:data];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt data: %@, key: %@", data, password);
        return nil;
    }
    NSString *json = [plaintext UTF8String];
    return [[DKDMessageContent alloc] initWithJSONString:json];
}

- (nullable NSDictionary *)message:(const DKDSecureMessage *)sMsg
                    decryptKeyData:(nullable const NSData *)key
                       forReceiver:(const NSString *)receiver {
    DIMID *ID = [DIMID IDWithID:receiver];
    DIMUser *user = DIMUserWithID(ID);
    DIMPrivateKey *SK = user.privateKey;
    NSAssert(SK, @"failed to get private key for receiver: %@", receiver);
    NSData *plaintext = [SK decrypt:key];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt key: %@, user: %@", key, user);
        return nil;
    }
    return [plaintext jsonDictionary];
}

- (nullable NSData *)message:(const DKDSecureMessage *)sMsg
                    signData:(const NSData *)data
                   forSender:(const NSString *)sender {
    DIMID *ID = [DIMID IDWithID:sender];
    DIMUser *user = DIMUserWithID(ID);
    DIMPrivateKey *SK = user.privateKey;
    NSAssert(SK, @"failed to get private key for sender: %@", sender);
    return [SK sign:data];
}

#pragma mark - DKDReliableMessageDelegate

- (BOOL)message:(const DKDReliableMessage *)rMsg
     verifyData:(const NSData *)data
  withSignature:(const NSData *)signature
      forSender:(const NSString *)sender {
    DIMID *ID = [DIMID IDWithID:sender];
    DIMPublicKey *PK = DIMPublicKeyForID(ID);
    NSAssert(PK, @"failed to get public key for sender: %@", sender);
    return [PK verify:data withSignature:signature];
}

@end
