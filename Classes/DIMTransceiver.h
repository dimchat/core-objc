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
- (nullable NSURL *)uploadEncryptedFileData:(NSData *)CT forMessage:(DIMInstantMessage *)iMsg;

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

@protocol DIMSocialNetworkDataSource;
@protocol DIMCipherKeyDataSource;

/**
 *  Callback for sending message
 *  set by application and executed by DIM Core
 */
typedef void (^DIMTransceiverCallback)(DIMReliableMessage *rMsg, NSError * _Nullable error);

@interface DIMTransceiver : NSObject <DIMInstantMessageDelegate,
                                      DIMSecureMessageDelegate,
                                      DIMReliableMessageDelegate> {
    
    __weak id<DIMTransceiverDelegate> _delegate;
    
    __weak id<DIMSocialNetworkDataSource> _barrack;
    __weak id<DIMCipherKeyDataSource> _keyCache;
}

@property (weak, nonatomic) id<DIMTransceiverDelegate> delegate;

@property (weak, nonatomic) id<DIMSocialNetworkDataSource> barrack;
@property (weak, nonatomic) id<DIMCipherKeyDataSource> keyCache;

@end

NS_ASSUME_NONNULL_END
