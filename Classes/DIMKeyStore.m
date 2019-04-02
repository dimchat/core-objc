//
//  DIMKeyStore.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "DIMKeyStore+CacheFile.h"

#import "DIMKeyStore.h"

// receiver -> key
typedef NSMutableDictionary<const DIMAddress *, DIMSymmetricKey *> KeyMap;
// sender -> map<receiver, key>
typedef NSMutableDictionary<const DIMAddress *, KeyMap *> KeyTable;

@interface DIMKeyStore ()

@property (strong, nonatomic) KeyTable *keyTable;

@property (nonatomic, getter=isDirty) BOOL dirty;

@end

@implementation DIMKeyStore

SingletonImplementations(DIMKeyStore, sharedInstance)

- (void)dealloc {
    [self flush];
    //[super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _keyTable = [[KeyTable alloc] init];
        
        _dirty = NO;
    }
    return self;
}

- (void)setCurrentUser:(DIMUser *)currentUser {
    if (![_currentUser isEqual:currentUser]) {
        // 1. save key store files for current user
        [self flush];
        
        // 2. flush & clear
        [self flush];
        [_keyTable removeAllObjects];
        
        // 3. replace current user
        _currentUser = currentUser;
        
        // 4. load key store files for new user
        [self reload];
    }
}

- (DIMSymmetricKey *)cipherKeyFrom:(const MKMID *)sender
                                to:(const MKMID *)receiver {
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    KeyMap *keyMap = [_keyTable objectForKey:sender.address];
    return [keyMap objectForKey:receiver.address];
}

- (void)cacheCipherKey:(MKMSymmetricKey *)key
                  from:(const MKMID *)sender
                    to:(const MKMID *)receiver {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    KeyMap *keyMap = [_keyTable objectForKey:sender.address];
    if (!keyMap) {
        keyMap = [[KeyMap alloc] init];
        [_keyTable setObject:keyMap forKey:sender.address];
    }
    if (key) {
        [keyMap setObject:key forKey:receiver.address];
        _dirty = YES;
    }
}

#pragma mark - Cipher key to encpryt message for account(contact)

- (DIMSymmetricKey *)cipherKeyForAccount:(const DIMID *)receiver {
    const DIMID *sender =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    NSAssert(MKMNetwork_IsCommunicator(receiver.type), @"account error: %@", receiver);
    DIMSymmetricKey *scKey = [self cipherKeyFrom:sender to:receiver];
    if (!scKey) {
        // create a new key & save it into the Key Store
        scKey = [[DIMSymmetricKey alloc] init];
        [self setCipherKey:scKey forAccount:receiver];
    }
    return scKey;
}

- (void)setCipherKey:(DIMSymmetricKey *)key forAccount:(const DIMID *)receiver {
    const DIMID *sender =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    NSAssert(MKMNetwork_IsCommunicator(receiver.type), @"account error: %@", receiver);
    [self cacheCipherKey:key from:sender to:receiver];
}

#pragma mark - Cipher key from account(contact) to decrypt message

- (DIMSymmetricKey *)cipherKeyFromAccount:(const DIMID *)sender {
    const DIMID *receiver =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(receiver.type), @"receiver error: %@", receiver);
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"account error: %@", sender);
    return [self cipherKeyFrom:sender to:receiver];
}

- (void)setCipherKey:(DIMSymmetricKey *)key fromAccount:(const DIMID *)sender {
    const DIMID *receiver =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(receiver.type), @"receiver error: %@", receiver);
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"account error: %@", sender);
    [self cacheCipherKey:key from:sender to:receiver];
}

#pragma mark - Cipher key to encrypt message for all group members

- (DIMSymmetricKey *)cipherKeyForGroup:(const DIMID *)group {
    const DIMID *sender =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    DIMSymmetricKey *scKey = [self cipherKeyFrom:sender to:group];
    if (!scKey) {
        // create a new key & save it into the Key Store
        scKey = [[DIMSymmetricKey alloc] init];
        [self setCipherKey:scKey forGroup:group];
    }
    return scKey;
}

- (void)setCipherKey:(DIMSymmetricKey *)key forGroup:(const DIMID *)group {
    const DIMID *sender =_currentUser.ID;
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    [self cacheCipherKey:key from:sender to:group];
}

#pragma mark - Cipher key from a member in the group to decrypt message

- (DIMSymmetricKey *)cipherKeyFromMember:(const DIMID *)sender inGroup:(const DIMID *)group {
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"member error: %@", sender);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    return [self cipherKeyFrom:sender to:group];
}

- (void)setCipherKey:(DIMSymmetricKey *)key fromMember:(const DIMID *)sender inGroup:(const DIMID *)group {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"member error: %@", sender);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group error: %@", group);
    [self cacheCipherKey:key from:sender to:group];
}

#pragma mark - Private key encrpyted by a password for user

- (NSData *)privateKeyStoredForUser:(const DIMUser *)user
                         passphrase:(const DIMSymmetricKey *)scKey {
    DIMPrivateKey *SK = [user privateKey];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
