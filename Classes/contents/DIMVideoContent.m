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
//  DIMVideoContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DIMVideoContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) DKDContentType type;

@end

@implementation DIMVideoContent

- (instancetype)initWithVideoData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DKDContentType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)videoData {
    return [self fileData];
}

- (void)setVideoData:(NSData *)videoData {
    self.fileData = videoData;
}

- (nullable NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

@end