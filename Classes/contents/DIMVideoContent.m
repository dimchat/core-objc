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
//  DIMVideoContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMVideoContent.h"

@interface DKDContent (Hacking)

@property (nonatomic) DKDContentType type;

@end

@interface DIMVideoContent () {
    
    NSData *_snapshot;
}

@end

@implementation DIMVideoContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _snapshot = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _snapshot = nil;
    }
    return self;
}

- (instancetype)initWithVideoData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // change content type
        self.type = DKDContentType_Video;
    }
    return self;
}

- (NSData *)videoData {
    return [self fileData];
}

- (void)setVideoData:(NSData *)videoData {
    [self setFileData:videoData];
}

- (nullable NSData *)snapshot {
    if (!_snapshot) {
        NSString *ss = [self objectForKey:@"snapshot"];
        if ([ss length] > 0) {
            _snapshot = MKMBase64Decode(ss);
        }
    }
    return _snapshot;
}

- (void)setSnapshot:(NSData *)snapshot {
    if ([snapshot length] > 0) {
        [self setObject:MKMBase64Encode(snapshot) forKey:@"snapshot"];
    } else {
        [self removeObjectForKey:@"snapshot"];
    }
    _snapshot = snapshot;
}

@end
