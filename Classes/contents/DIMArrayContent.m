// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  DIMArrayContent.m
//  DIMCore
//
//  Created by Albert Moky on 2022/8/8.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "DIMArrayContent.h"

/**
 *  Convert content list from dictionary array
 */
NSArray<id<DKDContent>> *DKDContentConvert(NSArray<id> *contents) {
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:contents.count];
    [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<DKDContent> ctx = DKDContentParse(obj);
        if (ctx) {
            [mArray addObject:ctx];
        }
    }];
    return mArray;
}

/**
 *  Revert content list to dictionary array
 */
NSArray<NSDictionary *> *DKDContentRevert(NSArray<id<DKDContent>> *contents) {
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:contents.count];
    [contents enumerateObjectsUsingBlock:^(id<DKDContent> obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:obj.dictionary];
    }];
    return mArray;
}

DIMArrayContent *DIMArrayContentCreate(NSArray<id<DKDContent>> *contents) {
    return [[DIMArrayContent alloc] initWithContents:contents];
}

@interface DIMArrayContent () {
    
    NSArray<id<DKDContent>> *_contents;
}

@end

@implementation DIMArrayContent

- (instancetype)initWithContents:(NSArray<id<DKDContent>> *)array {
    NSAssert(array, @"contents cannot be empty");
    if (self = [self initWithType:DKDContentType_Array]) {
        _contents = array;
        [self setObject:DKDContentRevert(array) forKey:@"contents"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _contents = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMArrayContent *content = [super copyWithZone:zone];
    if (content) {
        content.contents = _contents;
    }
    return content;
}

- (NSArray<id<DKDContent>> *)contents {
    if (!_contents) {
        id info = [self objectForKey:@"contents"];
        _contents = DKDContentConvert(info);
    }
    return _contents;
}

- (void)setContents:(NSArray<id<DKDContent>> *)contents {
    if ([contents count] > 0) {
        [self setObject:DKDContentRevert(contents) forKey:@"contents"];
    } else {
        [self removeObjectForKey:@"contents"];
    }
    _contents = contents;
}

@end
