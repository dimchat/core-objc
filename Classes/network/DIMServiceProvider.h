//
//  DIMServiceProvider.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMStation;

@interface DIMServiceProvider : DIMGroup

@property (strong, nonatomic, nullable) DIMCertificateAuthority *CA;
@property (readonly, strong, nonatomic) DIMPublicKey *publicKey; // CA.info.*

@property (strong, nonatomic, nullable) NSURL *home; // home page URL

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (BOOL)verifyStation:(DIMStation *)server;

@end

#pragma mark Service Provider Data Source

@protocol DIMServiceProviderDataSource <NSObject>

- (NSInteger)numberOfStationsInServiceProvider:(DIMServiceProvider *)SP;

- (DIMStation *)serviceProvider:(DIMServiceProvider *)SP
                 stationAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
