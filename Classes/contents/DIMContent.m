// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMContent.m
//  DIMCore
//
//  Created by Albert Moky on 2020/8/11.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMContent.h"

static NSMutableDictionary<NSNumber *, Class> *content_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // ...
    });
    return classes;
}

@implementation DKDContent (Runtime)

+ (void)registerClass:(nullable Class)clazz forType:(UInt8)type {
    NSAssert(![clazz isEqual:self], @"only subclass");
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [content_classes() setObject:clazz forKey:@(type)];
    } else {
        [content_classes() removeObjectForKey:@(type)];
    }
}

+ (nullable instancetype)getInstance:(id)content {
    if (!content) {
        return nil;
    }
    NSAssert([content isKindOfClass:[NSDictionary class]], @"content error: %@", content);
    if ([self isEqual:[DIMContent class]]) {
        if ([content isKindOfClass:[DKDContent class]]) {
            // return Content object directly
            return content;
        }
        // create instance by subclass with content type
        NSNumber *type = [content objectForKey:@"type"];
        Class clazz = [content_classes() objectForKey:type];
        if (clazz) {
            return [clazz getInstance:content];
        }
    }
    // custom message content
    return [[self alloc] initWithDictionary:content];
}

@end
