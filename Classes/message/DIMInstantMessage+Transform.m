//
//  DIMInstantMessage+Transform.m
//  DIMCore
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMBarrack.h"
#import "DIMKeyStore.h"

#import "DIMInstantMessage+Transform.h"

static inline DIMSymmetricKey *encrypt_key(const DIMID *receiver,
                                           const DIMID * _Nullable group) {
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMSymmetricKey *scKey = nil;
    
    if (group) {
        assert(MKMNetwork_IsGroup(group.type));
        receiver = group;
    }
    
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        scKey = [store cipherKeyForAccount:receiver];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[DIMSymmetricKey alloc] init];
            [store setCipherKey:scKey forAccount:receiver];
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        scKey = [store cipherKeyForGroup:receiver];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[DIMSymmetricKey alloc] init];
            [store setCipherKey:scKey forGroup:receiver];
        }
    } else {
        // receiver type not supported
        assert(false);
    }
    return scKey;
}

static inline DIMEncryptedKeyMap *pack_keys(const DIMGroup *group,
                                            const NSData *json) {
    NSArray *members = group.members;
    DIMEncryptedKeyMap *map;
    map = [[DIMEncryptedKeyMap alloc] initWithCapacity:members.count];
    
    DIMMember *member;
    NSData *data;
    for (DIMID *ID in members) {
        member = DIMMemberWithID(ID, group.ID);
        assert(member.publicKey);
        data = [member.publicKey encrypt:json];
        assert(data);
        [map setEncryptedKey:data forID:ID];
    }
    return map;
}

@implementation DIMInstantMessage (Transform)

- (DIMSecureMessage *)encrypt {
    const DIMID *receiver = [DIMID IDWithID:self.envelope.receiver];
    const DIMID *group = [DIMID IDWithID:self.content.group];
    
    // 1. symmetric key
    DIMSymmetricKey *scKey = encrypt_key(receiver, group);
    
    // 2. encrypt 'content' to 'data'
    NSData *json = [self.content jsonData];
    NSData *CT = [scKey encrypt:json];
    if (!CT) {
        NSAssert(false, @"failed to encrypt data: %@", self);
        return nil;
    }
    
    // 3. rebuild message info
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:self];
    // 3.1. replace content with data
    [mDict removeObjectForKey:@"content"];
    [mDict setObject:[CT base64Encode] forKey:@"data"];
    
    // 3.2. encrypt 'key'
    NSData *key = [scKey jsonData];
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        DIMAccount *contact = DIMAccountWithID(receiver);
        key = [contact.publicKey encrypt:key]; // pack_key()
        if (!key) {
            NSAssert(false, @"failed to encrypt key: %@", self);
            return nil;
        }
        [mDict setObject:[key base64Encode] forKey:@"key"];
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([group isEqual:receiver], @"group/receiver error: %@, %@", group, receiver);
        DIMEncryptedKeyMap *keys;
        keys = pack_keys(DIMGroupWithID(receiver), key); // pack_keys()
        if (!keys) {
            NSAssert(false, @"failed to pack keys: %@", self);
            return nil;
        }
        [mDict setObject:keys forKey:@"keys"];
    } else {
        NSAssert(false, @"receiver error: %@", receiver);
    }
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithDictionary:mDict];
}

@end
