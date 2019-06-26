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
#import "DIMContentType.h"
#import "DIMFileContent.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMTransceiver+Transform.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
    }
    return self;
}

#pragma mark DKDInstantMessageDelegate

- (NSURL *)message:(DIMInstantMessage *)iMsg
            upload:(NSData *)data
          filename:(nullable NSString *)name
           withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    NSData *CT = [symmetricKey encrypt:data];
    NSLog(@"encrypt file %@: %lu bytes -> %lu bytes", name, data.length, CT.length);
    
    return [_delegate uploadEncryptedFileData:CT forMessage:iMsg];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                    download:(NSURL *)url
                     withKey:(NSDictionary *)password {
    
    NSData *CT = [_delegate downloadEncryptedFileData:url forMessage:iMsg];
    if (CT) {
        DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
        NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
        return [symmetricKey decrypt:CT];
    }
    return nil;
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    
    NSString *json = [content jsonString];
    NSData *data = [json data];
    return [symmetricKey encrypt:data];
}

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
                  encryptKey:(NSDictionary *)password
                 forReceiver:(NSString *)receiver {
    
    NSString *json = [password jsonString];
    NSData *data = [json data];
    DIMID *ID = MKMIDFromString(receiver);
    DIMAccount *account = DIMAccountWithID(ID);
    NSAssert(account, @"failed to encrypt with receiver: %@", receiver);
    return [account encrypt:data];
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
    NSString *json = [plaintext UTF8String]; // remove garbage at end
    NSDictionary *dict = [[json data] jsonDictionary];
    
    // pack message with content
    DIMContent *content = DKDContentFromDictionary(dict);
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:sMsg.envelope];
    
    // check attachment for File/Image/Audio/Video message content
    switch (content.type) {
        case DIMContentType_File:
        case DIMContentType_Image:
        case DIMContentType_Audio:
        case DIMContentType_Video:
        {
            DIMFileContent *file = (DIMFileContent *)content;
            NSAssert(file.URL != nil, @"content.URL should not be empty");
            NSAssert(file.fileData == nil, @"content.fileData already download");
            
            NSData *fileData = [self message:iMsg
                                    download:file.URL
                                     withKey:symmetricKey];
            if (fileData) {
                file.fileData = fileData;
                file.URL = nil;
            } else {
                // save the symmetric key for decrypte file data later
                [file setObject:symmetricKey forKey:@"password"];
            }
            content = file;
        }
            break;
            
        default:
            break;
    }
    
    return content;
}

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                    decryptKeyData:(nullable NSData *)key
                        fromSender:(NSString *)sender
                        toReceiver:(NSString *)receiver
                           inGroup:(nullable NSString *)group {
    DIMSymmetricKey *PW = nil;
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMID *from = MKMIDFromString(sender);
    DIMID *to = MKMIDFromString(receiver);
    DIMID *groupID = MKMIDFromString(group);
    
    if (key) {
        // decrypt key data with the receiver's private key
        DIMUser *user = DIMUserWithID(to);
        NSAssert(user, @"failed to decrypt for receiver: %@", receiver);
        NSData *plaintext = [user decrypt:key];
        NSAssert(plaintext.length > 0, @"failed to decrypt key in msg: %@", sMsg);
        
        // create symmetric key
        NSString *json = [plaintext UTF8String]; // remove garbage at end
        NSDictionary *dict = [[json data] jsonDictionary];
        PW = MKMSymmetricKeyFromDictionary(dict);
        NSAssert(PW, @"invalid key: %@", dict);
        
        // set the new key in key store
        if (group) {
            [store setCipherKey:PW
                     fromMember:MKMIDFromString(sender)
                        inGroup:MKMIDFromString(group)];
            NSLog(@"got key from group member: %@, %@", sender, group);
        } else {
            [store setCipherKey:PW
                    fromAccount:MKMIDFromString(sender)];
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

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                    signData:(NSData *)data
                   forSender:(NSString *)sender {
    DIMID *ID = MKMIDFromString(sender);
    DIMUser *user = DIMUserWithID(ID);
    NSAssert(user, @"failed to sign with sender: %@", sender);
    return [user sign:data];
}

#pragma mark DKDReliableMessageDelegate

- (BOOL)message:(DIMReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender {
    DIMID *ID = MKMIDFromString(sender);
    DIMAccount *account = DIMAccountWithID(ID);
    NSAssert(account, @"failed to verify with sender: %@", sender);
    return [account verify:data withSignature:signature];
}

@end

#pragma mark - Convenience

@implementation DIMTransceiver (Send)

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    // transforming
    DIMID *receiver = MKMIDFromString(iMsg.envelope.receiver);
    DIMID *groupID = MKMIDFromString(iMsg.content.group);
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
                    completionHandler:^(NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

@end
