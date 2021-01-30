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
//  DIMImageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMImageContent.h"

@interface DKDContent (Hacking)

@property (nonatomic) DKDContentType type;

@end

@interface DIMImageContent () {
    
    NSData *_thumbnail;
}

@end

@implementation DIMImageContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _thumbnail = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _thumbnail = nil;
    }
    return self;
}

- (instancetype)initWithImageData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // change content type
        self.type = DKDContentType_Image;
    }
    return self;
}

- (NSData *)imageData {
    return [self fileData];
}

- (void)setImageData:(NSData *)imageData {
    [self setFileData:imageData];
}

- (nullable NSData *)thumbnail {
    if (!_thumbnail) {
        NSString *small = [self objectForKey:@"thumbnail"];
        if ([small length] > 0) {
            _thumbnail = MKMBase64Decode(small);
        }
    }
    return _thumbnail;
}

- (void)setThumbnail:(NSData *)thumbnail {
    if ([thumbnail length] > 0) {
        [self setObject:MKMBase64Encode(thumbnail) forKey:@"thumbnail"];
    } else {
        [self removeObjectForKey:@"thumbnail"];
    }
    _thumbnail = thumbnail;
}

@end
