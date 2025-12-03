// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
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
//  DIMBulletin.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBulletin.h"

@implementation DIMBulletin

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        //
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)did
                      data:(NSString *)json
                 signature:(id<MKTransportableData>)CT {
    if (self = [super initWithID:did data:json signature:CT]) {
        //
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)did type:(NSString *)type {
    if (self = [super initWithID:did type:type]) {
        //
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)did {
    return [self initWithID:did type:MKMDocumentType_Bulletin];
}

// Override
- (NSString *)name {
    id title = [self propertyForKey:@"name"];
    return MKConvertString(title, nil);
}

// Override
- (void)setName:(NSString *)title {
    [self setProperty:title forKey:@"name"];
}

// Override
- (nullable id<MKMID>)founder {
    return MKMIDParse([self objectForKey:@"founder"]);
}

@end
