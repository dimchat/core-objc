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
- (instancetype)initWithDictionary:(DIMNetworkFormatDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _data = nil;
    }
    return self;
}

// Override
- (BOOL)isEmpty {
    NSData *binary = _data;
    if ([binary length] > 0) {
        return NO;
    }
    NSString *text = [self stringForKey:@"data"];
    return [text length] == 0;
}

- (NSString *)description {
    return [self encode];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@>\n\t%@\n</%@>",
            [self class],
            [self encode],
            [self class]
    ];
}

// Override
- (NSString *)encode {
    // get encoded data
    NSString *text = [self encodedData];
    if ([text length] == 0) {
        return @"";
    }
    NSString *algo = [self stringForKey:@"algorithm"];
    if (algo == nil || [algo isEqualToString:MKEncodeAlgorithm_Default]) {
        algo = @"";
    }
    if ([algo length] == 0) {
        // 0. "{BASE64_ENCODE}"
        return text;
    }
    NSString *mimeType = [self stringForKey:@"mime-type"];
    if ([mimeType length] == 0) {
        // 1. "base64,{BASE64_ENCODE}"
        return [[NSString alloc] initWithFormat:@"%@,%@", algo, text];
    }
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return [[NSString alloc] initWithFormat:@"data:%@;%@,%@", mimeType, algo, text];
}

// Override
- (NSString *)encode:(NSString *)mimeType {
    NSAssert(![mimeType containsString:@" "], @"mime-type error: %@", mimeType);
    // get encoded data
    NSString *text = [self encodedData];
    if ([text length] == 0) {
        return @"";
    }
    NSString *algo = [self algorithm];
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return [[NSString alloc] initWithFormat:@"data:%@;%@,%@", mimeType, algo, text];
}

// Override
- (NSString *)algorithm {
    NSString *algo = [self stringForKey:@"algorithm"];
    if ([algo length] == 0) {
        algo = MKEncodeAlgorithm_Default;
    }
    return algo;
}

// Override
- (void)setAlgorithm:(NSString *)algorithm {
    if ([algorithm length] == 0/* ||
        [algorithm isEqualToString:MKEncodeAlgorithm_Default]*/) {
        [self removeObjectForKey:@"algorithm"];
    } else {
        [self setObject:algorithm forKey:@"algorithm"];
    }
}

// Override
- (NSData *)data {
    NSData *binary = _data;
    if (binary == nil) {
        NSString *text = [self stringForKey:@"data"];
        if ([text length] == 0) {
            NSAssert(false, @"TED data empty: %@", [self dictionary]);
            return nil;
        }
        NSString *algo = [self algorithm];
        binary = [self decodeData:text withAlgorithm:algo];
        _data = binary;
    }
    return binary;
}

- (void)setData:(NSData *)binary {
    [self removeObjectForKey:@"data"];
    //if ([binary length] > 0) {
    //    NSString *algo = [self algorithm];
    //    NSString *text = [self encodeData:binary withAlgorithm:algo];
    //    [self setObject:text forKey:@"data"];
    //}
    _data = binary;
}

@end

@implementation DIMBaseDataWrapper (Encoding)

- (nullable NSString *)encodedData {
    NSString *text = [self stringForKey:@"data"];
    if ([text length] == 0) {
        NSData *binary = _data;
        if ([binary length] == 0) {
            return nil;
        }
        NSString *algo = [self algorithm];
        text = [self encodeData:binary withAlgorithm:algo];
        NSAssert(text, @"failed to encode data: %lu", binary.length);
        [self setObject:text forKey:@"data"];
    }
    return text;
}

- (nullable NSString *)encodeData:(NSData *)binary withAlgorithm:(NSString *)algo {
    if ([algo isEqualToString:MKEncodeAlgorithm_BASE64]) {
        return MKBase64Encode(binary);
    } else if ([algo isEqualToString:MKEncodeAlgorithm_BASE58]) {
        return MKBase58Encode(binary);
    } else if ([algo isEqualToString:MKEncodeAlgorithm_HEX]) {
        return MKHexEncode(binary);
    } else {
        NSAssert(false, @"data algorithm not support: %@", algo);
        return nil;
    }
}

- (nullable NSData *)decodeData:(NSString *)text withAlgorithm:(NSString *)algo {
    if ([algo isEqualToString:MKEncodeAlgorithm_BASE64]) {
        return MKBase64Decode(text);
    } else if ([algo isEqualToString:MKEncodeAlgorithm_BASE58]) {
        return MKBase58Decode(text);
    } else if ([algo isEqualToString:MKEncodeAlgorithm_HEX]) {
        return MKHexDecode(text);
    } else {
        NSAssert(false, @"data algorithm not support: %@", algo);
        return nil;
    }
}

@end
