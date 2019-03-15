//
//  DIMTransceiver.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Handler to call after sending package complete
 *  executed by application
 */
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

#pragma mark -

/**
 *  Callback for sending message
 *  set by application and executed by DIM Core
 */
typedef void (^DIMTransceiverCallback)(const DIMReliableMessage *rMsg, const NSError * _Nullable error);

@interface DIMTransceiver : NSObject <DKDInstantMessageDelegate,
                                      DKDSecureMessageDelegate,
                                      DKDReliableMessageDelegate> {
    
    __weak id<DIMTransceiverDelegate> _delegate;
}

@property (weak, nonatomic) id<DIMTransceiverDelegate> delegate;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
