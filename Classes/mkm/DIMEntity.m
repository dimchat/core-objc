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
//  DIMEntity.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEntity.h"

@interface DIMEntity () {
    
    id<MKMID> _ID;
    __weak id<MKMEntityDataSource> _dataSource;
}

@end

@implementation DIMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    id<MKMID> ID = nil;
    return [self initWithID:ID];
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID {
    if (self = [super init]) {
        _ID = ID;
        _dataSource = nil;
    }
    
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMEntity *entity = [[self class] allocWithZone:zone];
    entity = [entity initWithID:_ID];
    if (entity) {
        entity.dataSource = _dataSource;
    }
    return entity;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        // same object
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMEntity)]) {
        object = [(id<MKMEntity>)object ID];
    }
    // check with ID
    return [_ID isEqual:object];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p | 0x%02X %@>",
            [self class], self, _ID.type, _ID];
}

- (NSString *)debugDescription {
    return [self description];
}

- (id<MKMID>)ID {
    return _ID;
}

- (MKMEntityType)type {
    return _ID.type;
}

- (id<MKMEntityDataSource>)dataSource {
    return _dataSource;
}

- (void)setDataSource:(id<MKMEntityDataSource>)dataSource {
    _dataSource = dataSource;
}

- (id<MKMMeta>)meta {
    NSAssert(_dataSource, @"entity data source not set yet");
    return [_dataSource metaForID:_ID];
}

- (nullable id<MKMDocument>)documentWithType:(nullable NSString *)type {
    NSAssert(_dataSource, @"entity data source not set yet");
    return [_dataSource documentForID:_ID type:type];
}

@end
