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

#import "DKDInstantMessage+Extension.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMTransceiver+Transform.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark DKDInstantMessageDelegate

- (NSURL *)message:(const DKDInstantMessage *)iMsg
            upload:(const NSData *)data
          filename:(nullable const NSString *)name
           withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    NSData *CT = [symmetricKey encrypt:data];
    NSLog(@"encrypt file %@: %lu bytes -> %lu bytes", name, data.length, CT.length);
    
    return [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
}

- (nullable NSData *)message:(const DKDInstantMessage *)iMsg
                    download:(const NSURL *)url
                     withKey:(NSDictionary *)password {
    
    NSData *CT = [_delegate downloadEncryptedFileData:url forMessage:iMsg];
    if (CT) {
        DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
        NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
        return [symmetricKey decrypt:CT];
    }
    return nil;
}

- (nullable NSData *)message:(const DKDInstantMessage *)iMsg
              encryptContent:(const DKDMessageContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    
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
    return [PK encrypt:data];
}

#pragma mark DKDSecureMessageDelegate

- (nullable DKDMessageContent *)message:(const DKDSecureMessage *)sMsg
                            decryptData:(const NSData *)data
                                withKey:(const NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = [DIMSymmetricKey keyWithKey:password];
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    // decrypt message.data
    NSData *plaintext = [symmetricKey decrypt:data];
    if (plaintext.length == 0) {
        NSAssert(false, @"failed to decrypt data: %@, key: %@", data, password);
        return nil;
    }
    NSString *json = [plaintext UTF8String]; // remove garbage at end
    NSDictionary *dict = [[json data] jsonDictionary];
    // pack message content
    return [[DKDMessageContent alloc] initWithDictionary:dict];
}

- (nullable NSDictionary *)message:(const DKDSecureMessage *)sMsg
                    decryptKeyData:(nullable const NSData *)key
                        fromSender:(const NSString *)sender
                        toReceiver:(const NSString *)receiver
                           inGroup:(nullable const NSString *)group {
    DIMSymmetricKey *PW = nil;
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMID *from = [DIMID IDWithID:sender];
    DIMID *to = [DIMID IDWithID:receiver];
    DIMID *groupID = [DIMID IDWithID:group];
    
    if (key) {
        // decrypt key data with the receiver's private key
        DIMUser *user = DIMUserWithID(to);
        DIMPrivateKey *SK = user.privateKey;
        NSAssert(SK, @"failed to get private key for receiver: %@", receiver);
        NSData *plaintext = [SK decrypt:key];
        NSAssert(plaintext.length > 0, @"failed to decrypt key in msg: %@", sMsg);
        
        // create symmetric key
        NSString *json = [plaintext UTF8String]; // remove garbage at end
        NSDictionary *dict = [[json data] jsonDictionary];
        PW = [[DIMSymmetricKey alloc] initWithDictionary:dict];
        NSAssert(PW, @"invalid key: %@", dict);
        
        // set the new key in key store
        if (group) {
            [store setCipherKey:PW
                     fromMember:[DIMID IDWithID:sender]
                        inGroup:[DIMID IDWithID:group]];
            NSLog(@"got key from group member: %@, %@", sender, group);
        } else {
            [store setCipherKey:PW
                    fromAccount:[DIMID IDWithID:sender]];
            NSLog(@"got key from contact: %@", sender);
        }
    }
    
    if (!PW) {
        // if key data is empty, get it from key store
        if (group) {
            PW = [store cipherKeyFromMember:from inGroup:groupID];
        } else {
            PW = [store cipherKeyFromAccount:from];
        }
        NSAssert(PW, @"failed to get symmetric from %@, group: %@", from, group);
    }
    
    return PW;
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

#pragma mark DKDReliableMessageDelegate

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

#pragma mark - Convenience

@implementation DIMTransceiver (Send)

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    // transforming
    const DIMID *receiver = [DIMID IDWithID:iMsg.envelope.receiver];
    const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
    DIMReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        iMsg.state = DIMMessageState_Error;
        iMsg.error = @"Encryption failed.";
        return NO;
    }
    
    // trying to send out
    BOOL OK = YES;
    if (split && MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([receiver isEqual:groupID], @"group ID error: %@", iMsg);
        DIMGroup *group = DIMGroupWithID(groupID);
        NSArray *messages = [rMsg splitForMembers:group.members];
        if (messages.count == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            OK = [self sendReliableMessage:rMsg callback:callback];
        } else {
            for (rMsg in messages) {
                if ([self sendReliableMessage:rMsg callback:callback]) {
                    //NSLog(@"group message sent to %@", rMsg.envelope.receiver);
                } else {
                    OK = NO;
                }
            }
        }
    } else {
        OK = [self sendReliableMessage:rMsg callback:callback];
    }
    
    // sending status
    if (OK) {
        iMsg.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        iMsg.state = DIMMessageState_Waiting;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(DIMTransceiverCallback)callback {
    NSData *data = [rMsg jsonData];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(const NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

@end
