//
//  DIMSecureMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMSecureMessage+Transform.h"

@implementation DIMSecureMessage (Transform)

- (DIMInstantMessage *)decrypt {
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    const DIMID *sender = [DIMID IDWithID:self.envelope.sender];
    const DIMID *receiver = [DIMID IDWithID:self.envelope.receiver];
    
    // 1. symmetric key
    DIMSymmetricKey *scKey = nil;
    NSData *key = nil;
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        key = self.encryptedKey;
        if (key) {
            // 1.1. decrypt passphrase with user's private key
            DIMUser *user = DIMUserWithID(receiver);
            key = [user.privateKey decrypt:key];
            if (key) {
                NSString *json = [key UTF8String];
                scKey = [[DIMSymmetricKey alloc] initWithJSONString:json];
            } else {
                NSAssert(false, @"decrypt key failed: %@", self);
            }
        } else {
            // 1.2. get passphrase from the Key Store
            const DIMID *group = [DIMID IDWithID:self.group];
            if (group) {
                scKey = [store cipherKeyFromMember:sender inGroup:group];
            } else {
                scKey = [store cipherKeyFromAccount:sender];
            }
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert(false, @"trim group message for a member first");
        return nil;
    } else {
        NSAssert(false, @"receiver type not supported: %@", receiver);
        return nil;
    }
    NSAssert(scKey, @"failed to get decrypt key for receiver: %@", receiver);
    
    // 2. decrypt 'data' to 'content'
    NSData *data = [scKey decrypt:self.data];
    if (!data) {
        NSAssert(false, @"failed to decrypt secure data: %@", self);
        return nil;
    }
    NSString *json = [data UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 2.1. Check group
    // if message.group exists, it must equal to content.group
    NSAssert(!self.group || [self.group isEqual:content.group],
             @"group error: %@, %@", self.group, content.group);
    // if content.group exists, it should equal to the message.receiver
    // or the message.receiver must be a member of this group
    NSAssert(MKMNetwork_IsCommunicator(receiver.type) ||
             [content.group isEqual:receiver],
             @"group/receiver error: %@, %@", content.group, receiver);
    
    // 3. update encrypted key for contact/group.member
    if (key) {
        const DIMID *group = [DIMID IDWithID:content.group];
        if (group) {
            [store setCipherKey:scKey fromMember:sender inGroup:group];
        } else {
            [store setCipherKey:scKey fromAccount:sender];
        }
    }
    
    // 4. create instant message
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:self];
    [mDict removeObjectForKey:@"data"];
    [mDict removeObjectForKey:@"key"];
    [mDict removeObjectForKey:@"keys"];
    [mDict setObject:content forKey:@"content"];
    return [[DIMInstantMessage alloc] initWithDictionary:mDict];
}

- (DIMReliableMessage *)sign {
    const DIMID *sender = [DIMID IDWithID:self.envelope.sender];
    NSAssert(MKMNetwork_IsPerson(sender.type), @"sender error: %@", sender);
    DIMUser *user = DIMUserWithID(sender);
    
    // 1. sign the content data with user's private key
    NSData *CT = [user.privateKey sign:self.data];
    if (!CT) {
        NSAssert(false, @"failed to sign data: %@", self);
        return nil;
    }
    
    // 2. create reliable message
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:self];
    [mDict setObject:[CT base64Encode] forKey:@"signature"];
    return [[DIMReliableMessage alloc] initWithDictionary:mDict];
}

@end
