//
//  DIMTransceiver+Transform.h
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTransceiver.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMTransceiver (Transform)

/**
 *  Pack instant message to reliable message for delivering
 *
 *  @param iMsg - instant message
 *  @return ReliableMessage Object
 */
- (nullable DIMReliableMessage *)encryptAndSignMessage:(DIMInstantMessage *)iMsg;

/**
 *  Extract instant message from a reliable message received
 *
 *  @param rMsg - reliable message
 *  @param users - my accounts
 *  @return InstantMessage object
 */
- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg
                                                  users:(NSArray<DIMUser *> *)users;

@end

NS_ASSUME_NONNULL_END
