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
//  DIMWebpageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMWebpageContent.h"

@implementation DIMPageContent

- (instancetype)initWithURL:(NSURL *)url
                      title:(nullable NSString *)title
                description:(nullable NSString *)desc
                       icon:(nullable NSData *)icon {
    NSAssert(url, @"URL cannot be empty");
    if (self = [self initWithType:DKDContentType_Page]) {
        // url
        if (url) {
            [self setObject:[url absoluteString] forKey:@"URL"];
        }
        
        // title
        if (title) {
            [self setObject:title forKey:@"title"];
        }
        
        // desc
        if (desc) {
            [self setObject:desc forKey:@"desc"];
        }
        
        // icon
        if (icon) {
            NSString *str = MKMBase64Encode(icon);
            [self setObject:str forKey:@"icon"];
        }
    }
    return self;
}

- (NSURL *)URL {
    NSString *string = [self objectForKey:@"URL"];
    return [NSURL URLWithString:string];
}

- (NSString *)title {
    return [self objectForKey:@"title"];
}

- (NSString *)desc {
    return [self objectForKey:@"desc"];
}

- (NSData *)icon {
    NSString *str = [self objectForKey:@"icon"];
    return MKMBase64Decode(str);
}

@end
