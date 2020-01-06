// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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

/*
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

- (instancetype)init {
    NSDictionary *dict = @{@"algorithm": @"PLAIN"};
    if (self = [self initWithDictionary:dict]) {
        //
    }
    return self;
}

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
        [self reload];
        
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

- (nullable NSDictionary *)loadKeys {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)reload {
    NSDictionary *keys = [self loadKeys];
    if (!keys) {
        return NO;
    }
    return [self updateKeys:keys];
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

- (nullable DIMSymmetricKey *)_cipherKeyFrom:(DIMID *)sender
                                          to:(DIMID *)receiver {
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    return [keyTable objectForKey:receiver];
}

- (void)_cacheCipherKey:(DIMSymmetricKey *)key
                   from:(DIMID *)sender
                     to:(DIMID *)receiver {
    NSAssert(key, @"cipher key cannot be empty");
    KeyTable *keyTable = [_keyMap objectForKey:sender];
    if (!keyTable) {
        keyTable = [[KeyTable alloc] init];
        [_keyMap setObject:keyTable forKey:sender];
    }
    [keyTable setObject:key forKey:receiver];
}

#pragma mark - DIMCipherKeyDelegate

- (nullable DIMSymmetricKey *)cipherKeyFrom:(DIMID *)sender
                                         to:(DIMID *)receiver {
    if ([receiver isBroadcast]) {
        return [_PlainKey sharedInstance];
    }
    // get key from cache
    return [self _cipherKeyFrom:sender to:receiver];
}

- (void)cacheCipherKey:(DIMSymmetricKey *)key
                  from:(DIMID *)sender
                    to:(DIMID *)receiver {
    if ([receiver isBroadcast]) {
        // broadcast message has no key
        return;
    }
    [self _cacheCipherKey:key from:sender to:receiver];
    _dirty = YES;
}

- (nullable DIMSymmetricKey *)reuseCipherKey:(nullable DIMSymmetricKey *)key
                                        from:(DIMID *)sender
                                          to:(DIMID *)receiver {
    if (key) {
        // cache the key for reuse
        [self cacheCipherKey:key from:sender to:receiver];
        return key;
    } else {
        // reuse key from cache
        return [self cipherKeyFrom:sender to:receiver];
    }
}

@end
