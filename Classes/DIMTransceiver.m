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

#import "DIMBarrack.h"
#import "DIMMessage.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

- (id<MKMEntityDelegate>)barrack {
    NSAssert(false, @"implement me!");
    return nil;
}

#pragma mark DKDInstantMessageDelegate

- (NSData *)message:(id<DKDInstantMessage>)iMsg
   serializeContent:(id<DKDContent>)content
            withKey:(id<MKMSymmetricKey>)password {
    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         before serialize content, this job should be do in subclass
    return MKMUTF8Encode(MKMJSONEncode(content.dictionary));
}

- (NSData *)message:(id<DKDInstantMessage>)iMsg
     encryptContent:(NSData *)data
            withKey:(id<MKMSymmetricKey>)password {
    // store 'IV' in iMsg for AES decryption
    return [password encrypt:data params:iMsg.dictionary];
}

//- (NSObject *)message:(id<DKDInstantMessage>)iMsg
//           encodeData:(NSData *)data {
//    if ([DIMMessage isBroadcast:iMsg]) {
//        // broadcast message content will not be encrypted (just encoded to JsON),
//        // so no need to encode to Base64 here
//        return MKMUTF8Decode(data);
//    }
//    // message content had been encrypted by a symmetric key,
//    // so the data should be encoded here (with algorithm 'base64' as default).
//    return MKMTransportableDataEncode(data);
//}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKMSymmetricKey>)password {
    if ([DIMMessage isBroadcast:iMsg]) {
        // broadcast message has no key
        return nil;
    }
    return MKMUTF8Encode(MKMJSONEncode(password.dictionary));
}

- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    NSAssert(![DIMMessage isBroadcast:iMsg], @"broadcast message has no key: %@", iMsg);
    // TODO: make sure the receiver's public key exists
    id<MKMUser> contact = [self.barrack userWithID:receiver];
    NSAssert(contact, @"failed to get encrypt key for receiver: %@", receiver);
    // encrypt with receiver's public key
    return [contact encrypt:data];
}

//- (NSObject *)message:(id<DKDInstantMessage>)iMsg
//            encodeKey:(NSData *)data {
//    NSAssert(![DIMMessage isBroadcast:iMsg], @"broadcast message has no key: %@", iMsg);
//    return MKMTransportableDataEncode(data);
//}

#pragma mark DKDSecureMessageDelegate

//- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
//                   decodeKey:(NSObject *)dataString {
//    NSAssert(![DIMMessage isBroadcast:sMsg], @"broadcast message has no key: %@", sMsg);
//    return MKMTransportableDataDecode(dataString);
//}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
                  decryptKey:(NSData *)key
                 forReceiver:(id<MKMID>)receiver {
    // NOTICE: the receiver must be a member ID
    //         if it's a group message
    NSAssert(![DIMMessage isBroadcast:sMsg], @"broadcast message has no key: %@", sMsg);
    NSAssert([receiver isUser], @"receiver error: %@", receiver);
    id<MKMUser> user = [self.barrack userWithID:receiver];
    NSAssert(user, @"failed to get decrypt keys: %@", receiver);
    // decrypt with private key of the receiver (or group member)
    return [user decrypt:key];
}

- (nullable id<MKMSymmetricKey>)message:(id<DKDSecureMessage>)sMsg
                         deserializeKey:(nullable NSData *)data {
    NSAssert(![DIMMessage isBroadcast:sMsg], @"broadcast message has no key: %@", sMsg);
    if ([data length] == 0) {
        NSAssert(false, @"reused key? get it from cache: %@ => %@, %@",
                 sMsg.sender, sMsg.receiver, sMsg.group);
        return nil;
    }
    id dict = MKMJSONDecode(MKMUTF8Decode(data));
    // TODO: translate short keys
    //       'A' -> 'algorithm'
    //       'D' -> 'data'
    //       'V' -> 'iv'
    //       'M' -> 'mode'
    //       'P' -> 'padding'
    return MKMSymmetricKeyParse(dict);
}

//- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
//                  decodeData:(NSObject *)dataString {
//    if ([DIMMessage isBroadcast:sMsg]) {
//        // broadcast message content will not be encrypted (just encoded to JsON),
//        // so return the string data directly
//        if ([dataString isKindOfClass:[NSString class]]) {
//            NSString *string = (NSString *)dataString;
//            return MKMUTF8Encode(string);
//        }
//        NSAssert(false, @"content data error: %@", dataString);
//        return nil;
//    }
//    // message content had been encrypted by a symmetric key,
//    // so the data should be encoded here (with algorithm 'base64' as default).
//    return MKMTransportableDataDecode(dataString);
//}

- (nullable NSData *)message:(id<DKDSecureMessage>)sMsg
              decryptContent:(NSData *)data
                     withKey:(id<MKMSymmetricKey>)password {
    // TODO: check 'IV' in sMsg for AES decryption
    return [password decrypt:data params:sMsg.dictionary];
}

- (nullable id<DKDContent>)message:(id<DKDSecureMessage>)sMsg
                deserializeContent:(NSData *)data
                           withKey:(id<MKMSymmetricKey>)password {
    //NSAssert([sMsg.data length] > 0, @"message data empty");
    id dict = MKMJSONDecode(MKMUTF8Decode(data));
    // TODO: translate short keys
    //       'T' -> 'type'
    //       'N' -> 'sn'
    //       'W' -> 'time'
    //       'G' -> 'group'
    return DKDContentParse(dict);
}

- (NSData *)message:(id<DKDSecureMessage>)sMsg
           signData:(NSData *)data {
    id<MKMID> sender = sMsg.sender;
    id<MKMUser> user = [self.barrack userWithID:sender];
    NSAssert(user, @"failed to get sign key for sender: %@", sender);
    return [user sign:data];
}

//- (NSObject *)message:(id<DKDSecureMessage>)sMsg
//      encodeSignature:(NSData *)signature {
//    return MKMTransportableDataEncode(signature);
//}

#pragma mark DKDReliableMessageDelegate

//- (nullable NSData *)message:(id<DKDReliableMessage>)rMsg
//             decodeSignature:(NSObject *)signatureString {
//    return MKMTransportableDataDecode(signatureString);
//}

- (BOOL)message:(id<DKDReliableMessage>)rMsg
     verifyData:(NSData *)data
  withSignature:(NSData *)signature {
    id<MKMID> sender = rMsg.sender;
    id<MKMUser> user = [self.barrack userWithID:sender];
    NSAssert(user, @"failed to get verify key for sender: %@", sender);
    return [user verify:data withSignature:signature];
}

@end
