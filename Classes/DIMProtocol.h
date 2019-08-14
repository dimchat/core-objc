//
//  DIMProtocol.h
//  DIMCore
//
//  Created by Albert Moky on 2019/8/14.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DIMSocialNetworkDataSource;
@protocol DIMCipherKeyDataSource;

@interface DIMProtocol : NSObject <DIMInstantMessageDelegate,
                                   DIMSecureMessageDelegate,
                                   DIMReliableMessageDelegate>{
    
    __weak id<DIMSocialNetworkDataSource> _barrack;
    __weak id<DIMCipherKeyDataSource> _keyCache;
}

@property (weak, nonatomic) id<DIMSocialNetworkDataSource> barrack;
@property (weak, nonatomic) id<DIMCipherKeyDataSource> keyCache;

- (DIMSymmetricKey *)passwordFrom:(DIMID *)sender to:(DIMID *)receiver;
- (DIMSymmetricKey *)password:(NSDictionary *)pw from:(DIMID *)sender to:(DIMID *)receiver;

@end

@interface DIMContent (Plugins)

+ (void)loadContentClasses;

@end

NS_ASSUME_NONNULL_END
