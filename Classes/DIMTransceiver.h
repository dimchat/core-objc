//
//  DIMTransceiver.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DIMTransceiverCallback)(const DIMReliableMessage *rMsg, const NSError * _Nullable error);
typedef void (^DIMTransceiverCompletionHandler)(const NSError * _Nullable error);

@protocol DIMTransceiverDelegate <NSObject>

/**
 Send out a data package onto network

 @param data - package`
 @param handler - completion handler
 @return NO on data/delegate error
 */
- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(nullable DIMTransceiverCompletionHandler)handler;

@end

@interface DIMTransceiver : NSObject

@property (weak, nonatomic) id<DIMTransceiverDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 Pack and send message (secured + certified) to target station

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @param callback - callback function
 @return NO on data/delegate error
 */
- (BOOL)sendMessageContent:(const DIMMessageContent *)content
                      from:(const DIMID *)sender
                        to:(const DIMID *)receiver
                      time:(nullable const NSDate *)time
                  callback:(nullable DIMTransceiverCallback)callback;

/**
 Send message (secured + certified) to target station

 @param iMsg - instant message
 @param callback - callback function
 @param split - if it's a group message, split it before sending out
 @return NO on data/delegate error
 */
- (BOOL)sendInstantMessage:(const DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split;

- (BOOL)sendReliableMessage:(const DIMReliableMessage *)rMsg
                   callback:(nullable DIMTransceiverCallback)callback;

#pragma mark -

/**
 Pack message content with sender and receiver to deliver it

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @return ReliableMessage Object
 */
- (DIMReliableMessage *)encryptAndSignContent:(const DIMMessageContent *)content
                                       sender:(const DIMID *)sender
                                     receiver:(const DIMID *)receiver
                                         time:(nullable const NSDate *)time;

/**
 Pack instant message to deliver it

 @param iMsg - instant message
 @return ReliableMessage Object
 */
- (DIMReliableMessage *)encryptAndSignMessage:(const DIMInstantMessage *)iMsg;

/**
 Extract instant message from a reliable message

 @param rMsg - reliable message
 @param user - current user
 @return InstantMessage object
 */
- (DIMInstantMessage *)verifyAndDecryptMessage:(const DIMReliableMessage *)rMsg
                                       forUser:(const DIMUser *)user;

@end

NS_ASSUME_NONNULL_END
