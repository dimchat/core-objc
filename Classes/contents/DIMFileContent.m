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
//  DIMFileContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMFileContent.h"

DIMFileContent *DIMFileContentCreate(NSString *filename, NSData *file) {
    return [[DIMFileContent alloc] initWithFilename:filename data:file];
}

@interface DIMFileContent () {
    
    id _attachment;
}

@end

@implementation DIMFileContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _attachment = nil;
    }
    return self;
}

- (instancetype)initWithType:(DKDContentType)type {
    NSString *name = nil;
    return [self initWithType:type filename:name data:nil];
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type
                    filename:(NSString *)name
                        data:(nullable NSData *)file {
    if (self = [super initWithType:type]) {
        // filename
        if (name) {
            [self setObject:name forKey:@"filename"];
        }
        // file data
        if (file) {
            self.data = file;
        }
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)name data:(nullable NSData *)file {
    NSAssert([file length] > 0, @"file data cannot be empty");
    return [self initWithType:DKDContentType_File filename:name data:file];
}

//- (id)copyWithZone:(nullable NSZone *)zone {
//    DIMFileContent *content = [super copyWithZone:zone];
//    if (content) {
//        //content.data = _attachment;
//    }
//    return content;
//}

- (nullable NSURL *)URL {
    NSString *string = [self stringForKey:@"URL"];
    if (string) {
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (void)setURL:(nullable NSURL *)URL {
    NSString *string = [URL absoluteString];
    if (string) {
        [self setObject:string forKey:@"URL"];
    } else {
        [self removeObjectForKey:@"URL"];
    }
}

- (nullable NSData *)data {
    if (!_attachment) {
        NSString *base64 = [self stringForKey:@"data"];
        if (base64) {
            _attachment = MKMBase64Decode(base64);
        }
    }
    return _attachment;
}

- (void)setData:(nullable NSData *)fileData {
    if ([fileData length] > 0) {
        [self setObject:MKMBase64Encode(fileData) forKey:@"data"];
    } else {
        [self removeObjectForKey:@"data"];
    }
    _attachment = fileData;
}

- (NSString *)filename {
    return [self stringForKey:@"filename"];
}

- (void)setPassword:(nullable id<MKMSymmetricKey>)password {
    if (password) {
        [self setObject:[password dictionary] forKey:@"password"];
    } else {
        [self removeObjectForKey:@"password"];
    }
}

- (nullable id<MKMSymmetricKey>)password {
    id pwd = [self objectForKey:@"password"];
    return MKMSymmetricKeyParse(pwd);
}

@end
