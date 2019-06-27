//
//  DIMTransceiver.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMContentType.h"
#import "DIMFileContent.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
    }
    return self;
}

#pragma mark DKDInstantMessageDelegate

- (nullable NSData *)message:(DIMInstantMessage *)iMsg
              encryptContent:(DIMContent *)content
                     withKey:(NSDictionary *)password {
    
    DIMSymmetricKey *symmetricKey = MKMSymmetricKeyFromDictionary(password);
    NSAssert(symmetricKey == password, @"irregular symmetric key: %@", password);
    
    // check attachment for File/Image/Audio/Video message content
    switch (content.type) {
        case DIMContentType_File:
        case DIMContentType_Image:
        case DIMContentType_Audio:
        case DIMContentType_Video:
        {
            // upload file data onto CDN and save the URL in message content
            DIMFileContent *file = (DIMFileContent *)content;
            NSAssert(file.fileData != nil, @"content.fileData should not be empty");
            NSAssert(file.URL == nil, @"content.URL exists, already uploaded?");
            // encrypt and upload
            NSData *CT = [symmetricKey encrypt:file.fileData];
            NSURL *url = [_delegate uploadEncryptedFileData:CT
                                                 forMessage:iMsg];
            if (url) {
                // replace 'data' with 'URL'
                file.URL = url;
                file.fileData = nil;
            }
            //[iMsg setObject:file forKey:@"content"];
        }
            break;
            
        default:
            break;
    }
    
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
    DIMAccount *account = [_barrackDelegate accountWithID:ID];
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
    
    // check attachment for File/Image/Audio/Video message content
    switch (content.type) {
        case DIMContentType_File:
        case DIMContentType_Image:
        case DIMContentType_Audio:
        case DIMContentType_Video:
        {
            DIMInstantMessage *iMsg;
            iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                                     envelope:sMsg.envelope];
            // download from CDN
            DIMFileContent *file = (DIMFileContent *)content;
            NSAssert(file.URL != nil, @"content.URL should not be empty");
            NSAssert(file.fileData == nil, @"content.fileData already download");
            // download and decrypt
            NSData *fileData = [_delegate downloadEncryptedFileData:file.URL
                                                         forMessage:iMsg];
            if (fileData) {
                file.fileData = [symmetricKey decrypt:fileData];
                file.URL = nil;
            } else {
                // save the symmetric key for decrypte file data later
                file.password = symmetricKey;
            }
            //content = file;
        }
            break;
            
        default:
            break;
    }
    
    return content;
}

- (nullable NSDictionary *)message:(DIMSecureMessage *)sMsg
                    decryptKeyData:(nullable NSData *)key
                              from:(NSString *)sender
                                to:(NSString *)receiver {
    DIMSymmetricKey *PW = nil;
    
    DIMID *from = MKMIDFromString(sender);
    DIMID *to = MKMIDFromString(receiver);
    
    if (key) {
        // decrypt key data with the receiver's private key
        DIMID *ID = MKMIDFromString(sMsg.envelope.receiver);
        DIMUser *user = [_barrackDelegate userWithID:ID];
        NSAssert(user, @"failed to decrypt for receiver: %@", receiver);
        NSData *plaintext = [user decrypt:key];
        if (plaintext.length > 0) {
            // create symmetric key
            NSString *json = [plaintext UTF8String]; // remove garbage at end
            NSDictionary *dict = [[json data] jsonDictionary];
            PW = MKMSymmetricKeyFromDictionary(dict);
            if (PW) {
                // set the new key in key store
                [_cipherKeyDataSource cacheCipherKey:PW from:from to:to];
                NSLog(@"got key from %@ to %@", sender, receiver);
            }
        } else {
            NSAssert(false, @"failed to decrypt key in msg: %@", sMsg);
        }
    }
    
    if (!PW) {
        // if key data is empty, get it from key store
        PW = [_cipherKeyDataSource cipherKeyFrom:from to:to];
        NSAssert(PW, @"failed to get password from %@ to %@", sender, receiver);
    }
    
    return PW;
}

- (nullable NSData *)message:(DIMSecureMessage *)sMsg
                    signData:(NSData *)data
                   forSender:(NSString *)sender {
    DIMID *ID = MKMIDFromString(sender);
    DIMUser *user = [_barrackDelegate userWithID:ID];
    NSAssert(user, @"failed to sign with sender: %@", sender);
    return [user sign:data];
}

#pragma mark DKDReliableMessageDelegate

- (BOOL)message:(DIMReliableMessage *)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature
      forSender:(NSString *)sender {
    DIMID *ID = MKMIDFromString(sender);
    DIMAccount *account = [_barrackDelegate accountWithID:ID];
    NSAssert(account, @"failed to verify with sender: %@", sender);
    return [account verify:data withSignature:signature];
}

@end
