//
//  NSData+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Hex)

- (NSString *)hexEncode;

@end

@interface NSData (MD5)

- (NSData *)md5;

@end

NS_ASSUME_NONNULL_END
