// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2026 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2026 Albert Moky
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
//  DIMNetworkFormatAccess.m
//  DIMCore
//
//  Created by Albert Moky on 2026/1/5.
//  Copyright © 2026 DIM Group. All rights reserved.
//

#import <MingKeMing/Type.h>

#import "DIMBaseDataWrapper.h"
#import "DIMBaseFileWrapper.h"

#import "DIMNetworkFormatAccess.h"

@interface DIMBaseNetworkFormatWrapper () {
    
    DIMNetworkFormatDictionary *_storeDictionary;
}

@end

@implementation DIMBaseNetworkFormatWrapper

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    DIMNetworkFormatDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(DIMNetworkFormatDictionary *)dict {
    if (self = [super init]) {
        if ([dict conformsToProtocol:@protocol(MKDictionary)]) {
            dict = [(id<MKDictionary>)dict dictionary];
        }
        _storeDictionary = dict;
    }
    return self;
}

// Override
- (DIMNetworkFormatDictionary *)dictionary {
    return _storeDictionary;
}

// Override
- (id)objectForKey:(NSString *)aKey {
    id object = [_storeDictionary objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

// Override
- (void)removeObjectForKey:(NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

// Override
- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    if (anObject) {
        [_storeDictionary setObject:anObject forKey:aKey];
    } else {
        [_storeDictionary removeObjectForKey:aKey];
    }
}

// Override
- (NSString *)stringForKey:(NSString *)aKey {
    id value = [self objectForKey:aKey];
    return MKConvertString(value, nil);
}

// Override
- (void)setDictionary:(id<MKDictionary>)mapper forKey:(NSString *)aKey {
    if (mapper) {
        [self setObject:mapper.dictionary forKey:aKey];
    } else {
        [self removeObjectForKey:aKey];
    }
}

@end

#pragma mark - Wrapper Factory

@interface DIMNetworkFormatWrapperFactory : NSObject <DIMTEDWrapperFactory,
                                                      DIMPNFWrapperFactory>

@end

@implementation DIMNetworkFormatWrapperFactory

// Override
- (id<DIMTEDWrapper>)createTEDWrapper:(DIMNetworkFormatDictionary *)map {
    return [[DIMBaseDataWrapper alloc] initWithDictionary:map];
}

// Override
- (id<DIMPNFWrapper>)createPNFWrapper:(DIMNetworkFormatDictionary *)content {
    return [[DIMBaseFileWrapper alloc] initWithDictionary:content];
}

@end

@implementation DIMSharedNetworkFormatAccess

static DIMSharedNetworkFormatAccess *s_network_format_access = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // create wrapper factory
        DIMNetworkFormatWrapperFactory *factory;
        factory = [[DIMNetworkFormatWrapperFactory alloc] init];
        // create accessor
        DIMSharedNetworkFormatAccess *access = [[self alloc] init];
        access.tedWrapperFactory = factory;
        access.pnfWrapperFactory = factory;
        // default accessor
        s_network_format_access = access;
    });
    return s_network_format_access;
}

@end
