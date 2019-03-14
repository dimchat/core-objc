//
//  DIMReliableMessage+Transform.h
//  DIMCore
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMSecureMessage;

@interface DIMReliableMessage (Transform)

/**
 *  Verify the Reliable Message to Secure Message
 *
 *    +----------+      +----------+
 *    | sender   |      | sender   |
 *    | receiver |      | receiver |
 *    | time     |  ->  | time     |
 *    |          |      |          |
 *    | data     |      | data     |  1. verify(data, signature, sender.PK)
 *    | key/keys |      | key/keys |
 *    | signature|      +----------+
 *    +----------+
 *
 *  @return SecureMessage
 */
- (DIMSecureMessage *)verify;

@end

NS_ASSUME_NONNULL_END
