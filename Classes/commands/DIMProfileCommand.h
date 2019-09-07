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
- (instancetype)initWithID:(DIMID *)ID
                      meta:(nullable DIMMeta *)meta
                   profile:(nullable DIMProfile *)profile;

- (instancetype)initWithID:(DIMID *)ID
                   profile:(DIMProfile *)profile;

// query command
- (instancetype)initWithID:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
