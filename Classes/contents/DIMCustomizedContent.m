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
//  DIMCustomizedContent.m
//  DIMCore
//
//  Created by Albert Moky on 2022/8/8.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "DIMCustomizedContent.h"

@implementation DIMCustomizedContent

- (instancetype)initWithType:(DKDContentType)type
                 application:(NSString *)app module:(NSString *)mod action:(NSString *)act {
    if (self = [self initWithType:type]) {
        // App ID
        if (app) {
            [self setObject:app forKey:@"app"];
        }
        // Module
        if (mod) {
            [self setObject:mod forKey:@"mod"];
        }
        // Action
        if (act) {
            [self setObject:act forKey:@"act"];
        }
    }
    return self;
}

- (instancetype)initWithApplication:(NSString *)app module:(NSString *)mod action:(NSString *)act {
    if (self = [self initWithType:DKDContentType_Customized
                      application:app module:mod action:act]) {
        //
    }
    return self;
}

- (NSString *)application {
    return [self objectForKey:@"app"];
}

- (NSString *)module {
    return [self objectForKey:@"mod"];
}

- (NSString *)action {
    return [self objectForKey:@"act"];
}

@end
