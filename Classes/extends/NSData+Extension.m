//
//  NSData+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSData+Extension.h"

@implementation NSData (Hex)

- (NSString *)hexEncode {
    NSMutableString *output = nil;
    
    const char *bytes = (const char *)[self bytes];
    NSUInteger len = [self length];
    output = [[NSMutableString alloc] initWithCapacity:(len*2)];
    for (int i = 0; i < len; ++i) {
        [output appendFormat:@"%02x", (unsigned char)bytes[i]];
    }
    
    return output;
}

@end

@implementation NSData (MD5)

- (NSData *)md5 {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (CC_LONG)[self length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

@end
