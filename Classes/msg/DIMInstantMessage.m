// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMInstantMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"

@interface DIMInstantMessage () {
    
    id<DKDContent> _content;
}

@end

@implementation DIMInstantMessage

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _content = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env
                         content:(id<DKDContent>)content {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    
    if (self = [super initWithEnvelope:env]) {
        // content
        [self setDictionary:content forKey:@"content"];
        _content = content;
    }
    return self;
}

- (instancetype)initWithEnvelope:(id<DKDEnvelope>)env {
    NSAssert(false, @"DON'T call me");
    id content = nil;
    return [self initWithEnvelope:env content:content];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        [iMsg setInnerContent:_content];
    }
    return iMsg;
}

- (id<DKDContent>)content {
    if (!_content) {
        id dict = [self objectForKey:@"content"];
        _content = DKDContentParse(dict);
    }
    return _content;
}
- (void)setContent:(id<DKDContent>)content {
    [self setDictionary:content forKey:@"content"];
    _content = content;
}
- (void)setInnerContent:(id<DKDContent>)content {
    _content = content;
}

- (NSDate *)time {
    id<DKDContent> content = [self content];
    NSDate *when = [content time];
    if (when) {
        return when;
    }
    return [super time];
}

- (id<MKMID>)group {
    id<DKDContent> content = [self content];
    return [content group];
}

- (DKDContentType)type {
    id<DKDContent> content = [self content];
    return [content type];
}

@end
