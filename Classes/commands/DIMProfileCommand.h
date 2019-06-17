//
//  DIMProfileCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMMetaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommand (Profile)

@property (readonly, strong, nonatomic, nullable) DIMProfile *profile;

@end

@interface DIMProfileCommand : DIMMetaCommand

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command   : "profile", // command name
 *      ID        : "{ID}",    // entity ID
 *      meta      : {...},     // only for handshaking with new friend
 *      profile   : {...}      // when profile is empty, means query for ID
 *  }
 */
- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile;

@end

NS_ASSUME_NONNULL_END
