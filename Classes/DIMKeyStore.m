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

typedef NSMutableDictionary<const DIMAddress *, DIMSymmetricKey *> KeyTableM;
typedef NSMutableDictionary<const DIMAddress *, KeyTableM *> KeyTableTableM;

@interface DIMKeyStore ()

@property (strong, nonatomic) KeyTableM *keysForAccounts;
@property (strong, nonatomic) KeyTableM *keysFromAccounts;

@property (strong, nonatomic) KeyTableM *keysForGroups;
@property (strong, nonatomic) KeyTableTableM *tablesFromGroups;

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
        _keysForAccounts = [[KeyTableM alloc] init];
        _keysFromAccounts = [[KeyTableM alloc] init];
        
        _keysForGroups = [[KeyTableM alloc] init];
        _tablesFromGroups = [[KeyTableTableM alloc] init];
        
        _dirty = NO;
    }
    return self;
}

- (void)setCurrentUser:(DIMUser *)currentUser {
    if (![_currentUser isEqual:currentUser]) {
        // 1. save key store files for current user
        [self flush];
        
        // 2. clear
        [self clearMemory];
        
        // 3. replace current user
        _currentUser = currentUser;
        
        // 4. load key store files for new user
        [self reload];
    }
}

- (void)clearMemory {
    [_keysForAccounts removeAllObjects];
    [_keysFromAccounts removeAllObjects];
    
    [_keysForGroups removeAllObjects];
    [_tablesFromGroups removeAllObjects];
}

#pragma mark - Cipher key to encpryt message for account(contact)

- (DIMSymmetricKey *)cipherKeyForAccount:(const DIMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    return [_keysForAccounts objectForKey:ID.address];
}

- (void)setCipherKey:(DIMSymmetricKey *)key
          forAccount:(const DIMID *)ID {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    if (key) {
        [_keysForAccounts setObject:key forKey:ID.address];
    }
}

#pragma mark - Cipher key from account(contact) to decrypt message

- (DIMSymmetricKey *)cipherKeyFromAccount:(const DIMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    return [_keysFromAccounts objectForKey:ID.address];
}

- (void)setCipherKey:(DIMSymmetricKey *)key
         fromAccount:(const DIMID *)ID {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"account ID error: %@", ID);
    if (key) {
        [_keysFromAccounts setObject:key forKey:ID.address];
        _dirty = YES;
    }
}

#pragma mark - Cipher key to encrypt message for all group members

- (DIMSymmetricKey *)cipherKeyForGroup:(const DIMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    return [_keysForGroups objectForKey:ID.address];
}

- (void)setCipherKey:(DIMSymmetricKey *)key
            forGroup:(const DIMID *)ID {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsGroup(ID.type), @"group ID error: %@", ID);
    if (key) {
        [_keysForGroups setObject:key forKey:ID.address];
    }
}

#pragma mark - Cipher key from a member in the group to decrypt message

- (DIMSymmetricKey *)cipherKeyFromMember:(const DIMID *)ID
                                 inGroup:(const DIMID *)group {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error: %@", ID);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    KeyTableM *table = [_tablesFromGroups objectForKey:group.address];
    return [table objectForKey:ID.address];
}

- (void)setCipherKey:(DIMSymmetricKey *)key
          fromMember:(const DIMID *)ID
             inGroup:(const DIMID *)group {
    NSAssert(key, @"cipher key cannot be empty");
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error: %@", ID);
    NSAssert(MKMNetwork_IsGroup(group.type), @"group ID error: %@", group);
    KeyTableM *table = [_tablesFromGroups objectForKey:group.address];
    if (!table) {
        table = [[KeyTableM alloc] init];
        [_tablesFromGroups setObject:table forKey:group.address];
    }
    if (key) {
        [table setObject:key forKey:ID.address];
        _dirty = YES;
    }
}

#pragma mark - Private key encrpyted by a password for user

- (NSData *)privateKeyStoredForUser:(const DIMUser *)user
                         passphrase:(const DIMSymmetricKey *)scKey {
    DIMPrivateKey *SK = [user privateKey];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
