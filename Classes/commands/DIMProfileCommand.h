//
//  DIMProfileCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMProfileCommand : DIMCommand

@property (readonly, strong, nonatomic) DIMID *ID;
@property (readonly, strong, nonatomic, nullable) DIMProfile *profile;
@property (readonly, strong, nonatomic, nullable) NSData *signature;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "profile",   // command name
 *      ID : "{ID}",           // entity ID
 *      profile : "{...}",     // When profile is empty, means query for ID
 *      signature: "{BASE64}", // sign(profile)
 *  }
 */
- (instancetype)initWithID:(DIMID *)ID
                   profile:(nullable NSString *)profileString
                 signature:(nullable NSString *)signatureString;

- (instancetype)initWithID:(DIMID *)ID
                privateKey:(DIMPrivateKey *)SK
                   profile:(DIMProfile *)profile;

@end

NS_ASSUME_NONNULL_END
