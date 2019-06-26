//
//  DIMStation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMTransceiver.h"

#import "DIMCertificateAuthority.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMServiceProvider;

@protocol DIMStationDelegate;

@interface DIMStation : DIMAccount {
    
    NSString *_host;
    UInt32 _port;
    
    DIMServiceProvider *_SP;
    DIMCertificateAuthority *_CA;
    
    __weak id<DIMStationDelegate> _delegate;
}

@property (readonly, strong, nonatomic) NSString *host; // Domain/IP
@property (readonly, nonatomic)         UInt32    port; // default: 9394

@property (strong, nonatomic) DIMServiceProvider *SP;
@property (strong, nonatomic) DIMCertificateAuthority *CA;

@property (readonly, strong, nonatomic) DIMPublicKey *publicKey; // CA.info.*

@property (readonly, strong, nonatomic) NSURL *home; // SP.home

@property (weak, nonatomic) id<DIMStationDelegate> delegate;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithID:(DIMID *)ID
                      host:(NSString *)IP
                      port:(UInt32)port;

@end

#pragma mark - Delegate

@protocol DIMStationDelegate <NSObject>

/**
 *  Received a new data package from the station
 *
 * @param server - current station
 * @param data - data package to send
 */
- (void)station:(DIMStation *)server didReceivePackage:(NSData *)data;

@optional

/**
 *  Send data package to station success
 *
 * @param server - current station
 * @param data - data package sent
 */
- (void)station:(DIMStation *)server didSendPackage:(NSData *)data;

/**
 *  Failed to send data package to station
 *
 * @param server - current station
 * @param data - data package to send
 * @param error - error information
 */
- (void)station:(DIMStation *)server sendPackage:(NSData *)data didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
