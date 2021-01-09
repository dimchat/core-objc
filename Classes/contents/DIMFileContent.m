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

@interface DIMFileContent () {
    
    id _attachment;
}

@end

@implementation DIMFileContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _attachment = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
        _attachment = nil;
    }
    return self;
}

- (instancetype)initWithFileData:(NSData *)data
                        filename:(nullable NSString *)name {
    NSAssert(data.length > 0, @"file data cannot be empty");
    if (self = [self initWithType:DKDContentType_File]) {
        
        // filename
        if (name) {
            [self setObject:name forKey:@"filename"];
        }
        
        // file data
        self.fileData = data;
    }
    return self;
}

- (nullable NSURL *)URL {
    NSString *string = [self objectForKey:@"URL"];
    if (string) {
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (void)setURL:(NSURL *)URL {
    NSString *string = [URL absoluteString];
    if (string) {
        [self setObject:string forKey:@"URL"];
    } else {
        [self removeObjectForKey:@"URL"];
    }
}

- (nullable NSData *)fileData {
    return _attachment;
}

- (void)setFileData:(NSData *)fileData {
    _attachment = fileData;
    
    // update filename with MD5 string
    if (fileData.length > 0) {
        NSString *filename = MKMHexEncode(MKMMD5Digest(fileData));
        NSString *ext = [[self.filename pathExtension] lowercaseString];
        if (ext.length > 0) {
            filename = [NSString stringWithFormat:@"%@.%@", filename, ext];
        }
        //NSAssert([self.filename isEqualToString:filename], @"filename error");
        [self setObject:filename forKey:@"filename"];
        
        // file data
        [self setObject:MKMBase64Encode(fileData) forKey:@"data"];
    } else {
        [self removeObjectForKey:@"data"];
    }
}

- (nullable NSString *)filename {
    return [self objectForKey:@"filename"];
}

- (void)setPassword:(id<MKMSymmetricKey>)password {
    if (password) {
        [self setObject:[password dictionary] forKey:@"password"];
    } else {
        [self removeObjectForKey:@"password"];
    }
}

- (nullable id<MKMSymmetricKey>)password {
    id pwd = [self objectForKey:@"password"];
    return MKMSymmetricKeyFromDictionary(pwd);
}

@end
