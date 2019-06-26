//
//  DIMKeyStore.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSDictionary+Binary.h"

#import "DIMKeyStore.h"

// "Library/Caches"
static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

// receiver -> key
typedef NSMutableDictionary<DIMAddress *, DIMSymmetricKey *> KeyTable;
// sender -> map<receiver, key>
typedef NSMutableDictionary<DIMAddress *, KeyTable *> KeyMap;

@interface DIMKeyStore () {
    
    KeyMap *_keyMap;
    
    BOOL _dirty;
}

@end

@implementation DIMKeyStore

- (void)dealloc {
    [self flush];
    //[super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _keyMap = [[KeyMap alloc] init];
        
        _dirty = NO;
    }
    return self;
}

- (void)flush {
    if (!_dirty) {
        // nothing changed
        return ;
    }
    if ([self saveKeys:_keyMap]) {
        // keys saved
        _dirty = NO;
    }
}

- (BOOL)saveKeys:(NSDictionary *)keyMap {
    // "Library/Caches/keystore.plist"
    NSString *dir = caches_directory();
    NSString *path = [dir stringByAppendingPathComponent:@"keystore.plist"];
    return [_keyMap writeToBinaryFile:path];
}

- (BOOL)loadKeys:(NSDictionary *)keyMap {
    BOOL changed = NO;
    for (NSString *from in keyMap) {
        DIMAddress *fromAddress = MKMAddressFromString(from);
        NSDictionary *keyTable = [keyMap objectForKey:from];
        for (NSString *to in keyTable) {
            DIMAddress *toAddress = MKMAddressFromString(to);
            NSDictionary *keyDict = [keyTable objectForKey:to];
            // check whether exists an old key
            if ([self _cipherKeyFrom:fromAddress to:toAddress]) {
                changed = YES;
            }
            // cache key with direction
            DIMSymmetricKey *key = MKMSymmetricKeyFromDictionary(keyDict);
            NSAssert(key, @"cipher key error(%@ -> %@): %@", from, to, keyDict);
            [self _cacheCipherKey:key from:fromAddress to:toAddress];
        }
    }
    return changed;
}

- (DIMSymmetricKey *)_cipherKeyFrom:(DIMAddress *)fromAddress
                                 to:(DIMAddress *)toAddress {
    NSAssert(MKMNetwork_IsCommunicator(fromAddress.network),
             @"sender error: %@", fromAddress);
    KeyTable *keyTable = [_keyMap objectForKey:fromAddress];
    return [keyTable objectForKey:toAddress];
}

- (void)_cacheCipherKey:(DIMSymmetricKey *)key
                   from:(DIMAddress *)fromAddress
                     to:(DIMAddress *)toAddress {
    NSAssert(MKMNetwork_IsCommunicator(fromAddress.network),
             @"sender error: %@", fromAddress);
    if (!key) {
        NSAssert(false, @"cipher key cannot be empty");
        return ;
    }
    KeyTable *keyTable = [_keyMap objectForKey:fromAddress];
    if (!keyTable) {
        keyTable = [[KeyTable alloc] init];
        [_keyMap setObject:keyTable forKey:fromAddress];
    }
    [keyTable setObject:key forKey:toAddress];
}

#pragma mark - DIMTransceiverDataSource

- (DIMSymmetricKey *)cipherKeyFrom:(DIMID *)sender
                                to:(DIMID *)receiver {
    return [self _cipherKeyFrom:sender.address to:receiver.address];
}

- (void)cacheCipherKey:(DIMSymmetricKey *)key
                  from:(DIMID *)sender
                    to:(DIMID *)receiver {
    [self _cacheCipherKey:key from:sender.address to:receiver.address];
    _dirty = key != nil;
}

- (nonnull DIMSymmetricKey *)reuseCipherKey:(nullable DIMSymmetricKey *)key
                                       from:(DIMID *)sender to:(DIMID *)receiver {
    // TODO: check whether renew the old key
    return key;
}

@end
