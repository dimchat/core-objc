//
//  DIMKeyCache.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "DIMKeyCache.h"

#define _Plain @"PLAIN"

/**
 *  Symmetric key for broadcast message,
 *  which will do nothing when en/decoding message data
 *
 *      keyInfo format: {
 *          algorithm: "PLAIN",
 *          data     : ""       // empty data
 *      }
 */
@interface _PlainKey : MKMSymmetricKey

+ (instancetype)sharedInstance;

@end

@implementation _PlainKey

- (NSData *)encrypt:(NSData *)plaintext {
    return plaintext;
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    return ciphertext;
}

SingletonImplementations(_PlainKey, sharedInstance)

@end

#pragma mark -

// receiver -> key
typedef NSMutableDictionary<DIMID *, DIMSymmetricKey *> KeyTable;
// sender -> map<receiver, key>
typedef NSMutableDictionary<DIMID *, KeyTable *> KeyMap;

@interface DIMKeyCache () {
    
    KeyMap *_keyMap;
    
    BOOL _dirty;
}

@end

@implementation DIMKeyCache

- (void)dealloc {
    [self flush];
    //[super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        
        [MKMSymmetricKey registerClass:[_PlainKey class] forAlgorithm:_Plain];
        
        _keyMap = [[KeyMap alloc] init];
        
        // load keys from local storage
        [self updateKeys];
        
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
    NSAssert(false, @"override me!");
    return NO;
}

- (NSDictionary *)loadKeys {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL) updateKeys {
    return [self updateKeys:[self loadKeys]];
}

- (BOOL)updateKeys:(NSDictionary *)keyMap {
    BOOL changed = NO;
    DIMSymmetricKey *oldKey, *newKey;
    for (NSString *from in keyMap) {
        DIMID *sender = MKMIDFromString(from);
        NSDictionary *keyTable = [keyMap objectForKey:from];
        for (NSString *to in keyTable) {
            DIMID *receiver = MKMIDFromString(to);
            NSDictionary *keyDict = [keyTable objectForKey:to];
            newKey = MKMSymmetricKeyFromDictionary(keyDict);
            NSAssert(newKey, @"key error(%@ -> %@): %@", from, to, keyDict);
            // check whether exists an old key
            oldKey = [self _cipherKeyFrom:sender to:receiver];
            if (![oldKey isEqual:newKey]) {
                changed = YES;
            }
            // cache key with direction
            [self _cacheCipherKey:newKey from:sender to:receiver];
        }
    }
    return changed;
}

- (DIMSymmetricKey *)_cipherKeyFrom:(DIMID *)sender
                                 to:(DIMID *)receiver {
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    return [keyTable objectForKey:receiver];
}

- (void)_cacheCipherKey:(DIMSymmetricKey *)key
                   from:(DIMID *)sender
                     to:(DIMID *)receiver {
    NSAssert(MKMNetwork_IsCommunicator(sender.type), @"sender error: %@", sender);
    if (!key) {
        NSAssert(false, @"cipher key cannot be empty");
        return ;
    }
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    if (!keyTable) {
        keyTable = [[KeyTable alloc] init];
        [_keyMap setObject:keyTable forKey:sender];
    }
    [keyTable setObject:key forKey:receiver];
}

#pragma mark - DIMTransceiverDataSource

- (DIMSymmetricKey *)cipherKeyFrom:(DIMID *)sender
                                to:(DIMID *)receiver {
    if (MKMIsBroadcast(receiver)) {
        return [_PlainKey sharedInstance];
    }
    return [self _cipherKeyFrom:sender to:receiver];
}

- (void)cacheCipherKey:(DIMSymmetricKey *)key
                  from:(DIMID *)sender
                    to:(DIMID *)receiver {
    if (MKMIsBroadcast(receiver)) {
        // broadcast message has no key
        return;
    }
    [self _cacheCipherKey:key from:sender to:receiver];
    _dirty = key != nil;
}

- (DIMSymmetricKey *)reuseCipherKey:(nullable DIMSymmetricKey *)key
                               from:(DIMID *)sender to:(DIMID *)receiver {
    // TODO: check whether renew the old key
    return key;
}

@end
