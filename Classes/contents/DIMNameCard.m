// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMNameCard.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DKDContentType.h"

#import "DIMNameCard.h"

@interface DIMNameCard () {
    
    id<MKPortableNetworkFile> _image;
}

@end

@implementation DIMNameCard

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        _image = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _image = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)ID
                      name:(NSString *)nickname
                    avatar:(id<MKPortableNetworkFile>)image {
    if (self = [self initWithType:DKDContentType_NameCard]) {
        [self setString:ID forKey:@"did"];
        [self setObject:nickname forKey:@"name"];
        if (image) {
            [self setObject:image.object forKey:@"avatar"];
        }
    }
    return self;
}

- (id<MKMID>)identifier {
    return MKMIDParse([self objectForKey:@"did"]);
}

- (NSString *)name {
    return [self stringForKey:@"name" defaultValue:@""];
}

- (id<MKPortableNetworkFile>)avatar {
    id<MKPortableNetworkFile> pnf = _image;
    if (!pnf) {
        id url = [self objectForKey:@"avatar"];
        if ([url length] == 0) {
            // ignore empty URL
        } else {
            _image = pnf = MKPortableNetworkFileParse(url);
        }
    }
    return pnf;
}

@end

#pragma mark - Conveniences

DIMNameCard *DIMNameCardCreate(id<MKMID> ID, NSString *name,
                               _Nullable id<MKPortableNetworkFile> avatar) {
    return [[DIMNameCard alloc] initWithID:ID name:name avatar:avatar];
}
