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
//  DIMBaseDataWrapper.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBaseDataWrapper.h"

NSString * const MKEncodeAlgorithm_Default = @"base64";
NSString * const MKEncodeAlgorithm_BASE64  = @"base64";
NSString * const MKEncodeAlgorithm_BASE58  = @"base58";
NSString * const MKEncodeAlgorithm_HEX     = @"hex";

@interface DIMBaseDataWrapper () {
    
    // binary data
    NSData *_data;
}

@end

@implementation DIMBaseDataWrapper

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _data = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _data = nil;
    }
    return self;
}

//- (BOOL)isEmpty {
//    if ([self count] == 0) {
//        return YES;
//    }
//    NSData *binary = [self data];
//    return [binary length] == 0;
//}

- (NSString *)encode {
    NSString *text = [self stringForKey:@"data" defaultValue:nil];
    if ([text length] == 0) {
        return @"";
    }
    NSString *algo = [self stringForKey:@"algorithm" defaultValue:nil];
    if (algo == nil || [algo isEqualToString:MKEncodeAlgorithm_Default]) {
        // 0. "{BASE64_ENCODE}"
        return text;
    } else {
        // 1. "base64,{BASE64_ENCODE}"
        return [[NSString alloc] initWithFormat:@"%@,%@", algo, text];
    }
}

- (NSString *)encode:(NSString *)mimeType {
    NSAssert(![mimeType containsString:@" "], @"content-type error: %@", mimeType);
    // get encoded data
    NSString *text = [self stringForKey:@"data" defaultValue:nil];
    if ([text length] == 0) {
        return @"";
    }
    NSString *algo = [self algorithm];
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return [[NSString alloc] initWithFormat:@"data:%@;%@,%@", mimeType, algo, text];
}

- (NSString *)algorithm {
    NSString *algo = [self stringForKey:@"algorithm" defaultValue:nil];
    if ([algo length] == 0) {
        algo = MKEncodeAlgorithm_Default;
    }
    return algo;
}

- (void)setAlgorithm:(NSString *)algorithm {
    if ([algorithm length] == 0/* ||
        [algorithm isEqualToString:MKEncodeAlgorithm_Default]*/) {
        [self removeObjectForKey:@"algorithm"];
    } else {
        [self setObject:algorithm forKey:@"algorithm"];
    }
}

- (NSData *)data {
    NSData *binary = _data;
    if (binary == nil) {
        NSString *text = [self stringForKey:@"data" defaultValue:nil];
        if ([text length] == 0) {
            NSAssert(false, @"TED data empty: %@", [self dictionary]);
        } else {
            NSString *algo = [self algorithm];
            if ([algo isEqualToString:MKEncodeAlgorithm_BASE64]) {
                binary = MKBase64Decode(text);
            } else if ([algo isEqualToString:MKEncodeAlgorithm_BASE58]) {
                binary = MKBase58Decode(text);
            } else if ([algo isEqualToString:MKEncodeAlgorithm_HEX]) {
                binary = MKHexDecode(text);
            } else {
                NSAssert(false, @"data algorithm not support: %@", algo);
            }
        }
        _data = binary;
    }
    return binary;
}

- (void)setData:(NSData *)binary {
    if ([binary length] == 0) {
        [self removeObjectForKey:@"data"];
    } else {
        NSString *text = @"";
        NSString *algo = [self algorithm];
        if ([algo isEqualToString:MKEncodeAlgorithm_BASE64]) {
            text = MKBase64Encode(binary);
        } else if ([algo isEqualToString:MKEncodeAlgorithm_BASE58]) {
            text = MKBase58Encode(binary);
        } else if ([algo isEqualToString:MKEncodeAlgorithm_HEX]) {
            text = MKHexEncode(binary);
        } else {
            NSAssert(false, @"data algorithm not support: %@", algo);
        }
        [self setObject:text forKey:@"data"];
    }
    _data = binary;
}

@end
