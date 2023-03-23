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
//  DIMMoneyContent.m
//  DIMCore
//
//  Created by Albert Moky on 2021/4/15.
//  Copyright © 2021 DIM Group. All rights reserved.
//

#import "DIMMoneyContent.h"

DIMMoneyContent *DIMMoneyContentCreate(NSString *currency, float value) {
    return [[DIMMoneyContent alloc] initWithCurrency:currency amount:value];
}

@implementation DIMMoneyContent

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(DKDContentType)type {
    if (self = [super initWithType:type]) {
    }
    return self;
}

- (instancetype)initWithType:(DKDContentType)type
                    currency:(NSString *)currency amount:(float)value {
    if (self = [self initWithType:type]) {
        
        // currency
        if (currency) {
            [self setObject:currency forKey:@"currency"];
        }
        
        // value
        if (value > 0) {
            [self setObject:@(value) forKey:@"value"];
        }
    }
    return self;
}

- (instancetype)initWithCurrency:(NSString *)currency amount:(float)value {
    return [self initWithType:DKDContentType_Money
                     currency:currency amount:value];
}

- (NSString *)currency {
    return [self stringForKey:@"currency"];
}

- (float)amount {
    NSNumber *number = [self objectForKey:@"amount"];
    NSAssert(number, @"amount of money not found: %@", self);
    return [number floatValue];
}

- (void)setAmount:(float)amount {
    [self setObject:@(amount) forKey:@"amount"];
}

@end
