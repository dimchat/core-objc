// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2021 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2021 Albert Moky
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
//  DIMTransferContent.m
//  DIMCore
//
//  Created by Albert Moky on 2021/4/15.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import "DIMTransferContent.h"

@implementation DIMTransferContent

- (instancetype)initWithCurrency:(NSString *)currency amount:(float)value {
    return [self initWithType:DKDContentType_Transfer currency:currency amount:value];
}

- (nullable id<MKMID>)remitter {
    return MKMIDFromString([self objectForKey:@"remitter"]);
}

- (void)setRemitter:(id<MKMID>)sender {
    if (sender) {
        [self setObject:[sender string] forKey:@"remitter"];
    } else {
        [self removeObjectForKey:@"remitter"];
    }
}

- (nullable id<MKMID>)remittee {
    return MKMIDFromString([self objectForKey:@"remittee"]);
}

- (void)setRemittee:(id<MKMID>)receiver {
    if (receiver) {
        [self setObject:[receiver string] forKey:@"remittee"];
    } else {
        [self removeObjectForKey:@"remittee"];
    }
}

@end
