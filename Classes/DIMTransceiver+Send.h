//
//  DIMTransceiver+Send.h
//  DIMCore
//
//  Created by Albert Moky on 2019/3/15.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTransceiver.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMTransceiver (Send)

/**
 *  Pack and send message (secured + certified) to target station
 *
 *  @param content - message content
 *  @param sender - sender ID
 *  @param receiver - receiver ID
 *  @param callback - callback function
 *  @return NO on data/delegate error
 */
- (BOOL)sendMessageContent:(const DIMMessageContent *)content
                      from:(const DIMID *)sender
                        to:(const DIMID *)receiver
                      time:(nullable const NSDate *)time
                  callback:(nullable DIMTransceiverCallback)callback;

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

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(nullable DIMTransceiverCallback)callback;

@end

NS_ASSUME_NONNULL_END
