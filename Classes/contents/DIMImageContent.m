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

#import "DKDContentType.h"

#import "DIMImageContent.h"

@interface DIMImageContent () {
    
    id<MKPortableNetworkFile> _thumbnail;
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
- (instancetype)initWithType:(NSString *)type
                        data:(nullable id<MKTransportableData>)image
                    filename:(nullable NSString *)name
                         url:(nullable NSURL *)remote
                    password:(nullable id<MKDecryptKey>)key {
    if (self = [super initWithType:type
                              data:image
                          filename:name
                               url:remote
                          password:key]) {
        _thumbnail = nil;
    }
    return self;
}

- (instancetype)initWithData:(id<MKTransportableData>)image
                    filename:(NSString *)name {
    return [self initWithType:DKDContentType_Image
                         data:image
                     filename:name
                          url:nil
                     password:nil];
}

- (instancetype)initWithURL:(NSURL *)url
                   password:(nullable id<MKDecryptKey>)key {
    return [self initWithType:DKDContentType_Image
                         data:nil
                     filename:nil
                          url:url
                     password:key];
}

// Override
- (nullable id<MKPortableNetworkFile>)thumbnail {
    id<MKPortableNetworkFile> img = _thumbnail;
    if (!img) {
        id uri = [self objectForKey:@"thumbnail"];
        img = MKPortableNetworkFileParse(uri);
        _thumbnail = img;
    }
    return img;
}

// Override
- (void)setThumbnail:(id<MKPortableNetworkFile>)img {
    if ([img count] == 0) {
        [self removeObjectForKey:@"thumbnail"];
    } else {
        [self setObject:img.object forKey:@"thumbnail"];
    }
    _thumbnail = img;
}

@end

#pragma mark - Conveniences

DIMImageContent *DIMImageContentFromData(id<MKTransportableData> image,
                                         NSString *filename) {
    return [[DIMImageContent alloc] initWithData:image filename:filename];
}

DIMImageContent *DIMImageContentFromURL(NSURL *url, id<MKDecryptKey> password) {
    return [[DIMImageContent alloc] initWithURL:url password:password];
}
