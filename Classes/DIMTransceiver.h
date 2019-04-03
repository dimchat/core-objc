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
 *  Send out a data package onto network
 *
 *  @param data - package`
 *  @param handler - completion handler
 *  @return NO on data/delegate error
 */
- (BOOL)sendPackage:(const NSData *)data completionHandler:(nullable DIMTransceiverCompletionHandler)handler;

/**
 *  CDN
 */
- (NSURL *)uploadEncryptedFileData:(const NSData *)CT filename:(nullable const NSString *)name sender:(const DIMID *)ID;
- (nullable NSData *)downloadEncryptedFileDataFromURL:(const NSURL *)url filename:(nullable const NSString *)name sender:(const MKMID *)ID;

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

#pragma mark - Convenience

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
