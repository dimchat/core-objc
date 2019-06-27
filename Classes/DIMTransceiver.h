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
typedef void (^DIMTransceiverCompletionHandler)(NSError * _Nullable error);

@protocol DIMTransceiverDelegate <NSObject>

/**
 *  Send out a data package onto network
 *
 *  @param data - package`
 *  @param handler - completion handler
 *  @return NO on data/delegate error
 */
- (BOOL)sendPackage:(NSData *)data completionHandler:(nullable DIMTransceiverCompletionHandler)handler;

/**
 *  Upload encrypted data to CDN
 *
 *  @param CT - encrypted file data
 *  @param iMsg - instant message
 *  @return download URL
 */
- (NSURL *)uploadEncryptedFileData:(NSData *)CT forMessage:(DIMInstantMessage *)iMsg;

/**
 *  Download encrypted data from CDN, and decrypt it when finished
 *
 *  @param url - download URL
 *  @param iMsg - instant message
 *  @return encrypted file data
 */
- (nullable NSData *)downloadEncryptedFileData:(NSURL *)url forMessage:(DIMInstantMessage *)iMsg;

@end

#pragma mark -

@protocol DIMBarrackDelegate;
@protocol DIMCipherKeyDataSource;

/**
 *  Callback for sending message
 *  set by application and executed by DIM Core
 */
typedef void (^DIMTransceiverCallback)(DIMReliableMessage *rMsg, NSError * _Nullable error);

@interface DIMTransceiver : NSObject <DKDInstantMessageDelegate,
                                      DKDSecureMessageDelegate,
                                      DKDReliableMessageDelegate> {
    
    __weak id<DIMTransceiverDelegate> _delegate;
    
    __weak id<DIMBarrackDelegate> _barrackDelegate;
    __weak id<DIMEntityDataSource> _entityDataSource;
    __weak id<DIMCipherKeyDataSource> _cipherKeyDataSource;
}

@property (weak, nonatomic) id<DIMTransceiverDelegate> delegate;

@property (weak, nonatomic) id<DIMBarrackDelegate> barrackDelegate;
@property (weak, nonatomic) id<DIMEntityDataSource> entityDataSource;
@property (weak, nonatomic) id<DIMCipherKeyDataSource> cipherKeyDataSource;

@end

NS_ASSUME_NONNULL_END
