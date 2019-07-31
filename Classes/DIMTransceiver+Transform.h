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
 *  @return InstantMessage object
 */
- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg;

@end

@interface DIMTransceiver (Send)

/**
 *  Send message (secured + certified) to target station
 *
 *  @param iMsg - instant message
 *  @param callback - callback function
 *  @param split - if it's a group message, split it before sending out
 *  @return NO on data/delegate error
 */
- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split;

//- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
//                   callback:(nullable DIMTransceiverCallback)callback;

@end

NS_ASSUME_NONNULL_END
