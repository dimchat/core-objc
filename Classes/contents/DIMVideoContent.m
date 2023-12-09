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

DIMVideoContent *DIMVideoContentFromData(NSData *video,
                                         NSString *filename) {
    id<MKMTransportableData> ted = MKMTransportableDataCreate(video, nil);
    return [[DIMVideoContent alloc] initWithData:ted filename:filename];
}

DIMVideoContent *DIMVideoContentFromURL(NSURL *url,
                                        _Nullable id<MKMDecryptKey> password) {
    return [[DIMVideoContent alloc] initWithURL:url password:password];
}

@interface DIMVideoContent () {
    
    id<MKMTransportableData> _snapshot;
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
- (instancetype)initWithType:(DKDContentType)type
                        data:(nullable id<MKMTransportableData>)file
                    filename:(nullable NSString *)name
                         url:(nullable NSURL *)remote
                    password:(nullable id<MKMDecryptKey>)key {
    if (self = [super initWithType:type
                              data:file
                          filename:name
                               url:remote
                          password:key]) {
        _snapshot = nil;
    }
    return self;
}

- (instancetype)initWithData:(id<MKMTransportableData>)video
                    filename:(NSString *)name {
    return [self initWithType:DKDContentType_Video
                         data:video
                     filename:name
                          url:nil
                     password:nil];
}

- (instancetype)initWithURL:(NSURL *)url
                   password:(nullable id<MKMDecryptKey>)key {
    return [self initWithType:DKDContentType_Video
                         data:nil
                     filename:nil
                          url:url
                     password:key];
}

- (nullable NSData *)snapshot {
    id<MKMTransportableData> ted = _snapshot;
    if (!ted) {
        id base64 = [self objectForKey:@"snapshot"];
        _snapshot = ted = MKMTransportableDataParse(base64);
    }
    return [ted data];
}

- (void)setSnapshot:(NSData *)snapshot {
    id<MKMTransportableData> ted;
    if ([snapshot length] == 0) {
        ted = nil;
        [self removeObjectForKey:@"snapshot"];
    } else {
        ted = MKMTransportableDataCreate(snapshot, nil);
        [self setObject:ted.object forKey:@"snapshot"];
    }
    _snapshot = ted;
}

@end
