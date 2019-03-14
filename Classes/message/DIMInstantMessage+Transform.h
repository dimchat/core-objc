//
//  DIMInstantMessage+Transform.h
//  DIMCore
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMSecureMessage;

@interface DIMInstantMessage (Transform)

/**
 *  Encrypt the Instant Message to Secure Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |
 *    | content  |      | data     |  1. data = encrypt(content, PW)
 *    +----------+      | key/keys |  2. key  = encrypt(PW, receiver.PK)
 *                      +----------+
 *
 *  @return SecureMessage
 */
- (DIMSecureMessage *)encrypt;

@end

NS_ASSUME_NONNULL_END
