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
//  DIMCombineContent.m
//  DIMCore
//
//  Created by Albert Moky on 2022/8/8.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "DKDContentType.h"

#import "DIMCombineContent.h"

@interface DIMCombineContent () {
    
    NSArray<id<DKDInstantMessage>> *_history;
}

@end

@implementation DIMCombineContent

- (instancetype)initWithTitle:(NSString *)title
                     messages:(NSArray<id<DKDInstantMessage>> *)history {
    NSAssert(title.length > 0, @"chat title empty");
    NSAssert(history.count > 0, @"chat history empty");
    if (self = [self initWithType:DKDContentType_CombineForward]) {
        _history = history;
        [self setObject:DKDInstantMessageRevert(history) forKey:@"messages"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _history = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        // lazy
        _history = nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMCombineContent *content = [super copyWithZone:zone];
    if (content) {
        content.messages = _history;
    }
    return content;
}

// Override
- (NSString *)title {
    return [self stringForKey:@"title" defaultValue:@""];
}

// Override
- (NSArray<id<DKDInstantMessage>> *)messages {
    if (!_history) {
        id array = [self objectForKey:@"messages"];
        if ([array isKindOfClass:[NSArray class]]) {
            _history = DKDInstantMessageConvert(array);
        } else {
            NSAssert(array == nil, @"messages error: %@", array);
            _history = @[];
        }
    }
    return _history;
}

- (void)setMessages:(NSArray<id<DKDInstantMessage>> *)messages {
    if ([messages count] > 0) {
        [self setObject:DKDInstantMessageRevert(messages) forKey:@"messages"];
    } else {
        [self removeObjectForKey:@"messages"];
    }
    _history = messages;
}

@end

#pragma mark - Conveniences

DIMCombineContent *DIMCombineContentCreate(NSString *title,
                                           NSArray<id<DKDInstantMessage>> *messages) {
    return [[DIMCombineContent alloc] initWithTitle:title messages:messages];
}
