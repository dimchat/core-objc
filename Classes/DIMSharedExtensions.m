// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  DIMSharedExtensions.m
//  DIMCore
//
//  Created by Albert Moky on 2025/10/5.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

#import "DIMSharedExtensions.h"

@implementation DKDCommandExtensions

static DKDCommandExtensions *s_cmd_ext = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cmd_ext = [[self alloc] init];
    });
    return s_cmd_ext;
}

@end

@implementation DKDSharedCommandExtensions

static DKDSharedCommandExtensions *s_cmd_extension = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cmd_extension = [[self alloc] init];
    });
    return s_cmd_extension;
}

- (id<DKDCommandHelper>)cmdHelper {
    DKDCommandExtensions *ext = [DKDCommandExtensions sharedInstance];
    return [ext cmdHelper];
}

- (void)setCmdHelper:(id<DKDCommandHelper>)cmdHelper {
    DKDCommandExtensions *ext = [DKDCommandExtensions sharedInstance];
    [ext setCmdHelper:cmdHelper];
}

@end
