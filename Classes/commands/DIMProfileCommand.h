//
//  DIMProfileCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMProfileCommand : DIMMetaCommand

@property (readonly, strong, nonatomic, nullable) DIMProfile *profile;
@property (readonly, strong, nonatomic, nullable) NSData *signature;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command   : "profile",  // command name
 *      ID        : "{ID}",     // entity ID
 *      meta      : {...},      // only for handshaking with new friend
 *      profile   : "{...}",    // json(profile); when profile is empty, means query for ID
 *      signature : "{BASE64}", // sign(json(profile))
 *  }
 */
- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta
                   profile:(nullable const NSString *)profileString
                 signature:(nullable const NSString *)signatureString;

- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta
                privateKey:(const DIMPrivateKey *)SK
                   profile:(const DIMProfile *)profile;

@end

NS_ASSUME_NONNULL_END
