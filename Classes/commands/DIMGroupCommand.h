//
//  DIMGroupCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupCommand : DIMHistoryCommand

// Group ID for group message already defined in DKDMessageContent
//@property (strong, nonatomic, nullable) MKMID *group;

@property (readonly, strong, nonatomic, nullable) DIMID *member;

/**
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "invite",      // expel, quit
 *      group   : "{GROUP_ID}",
 *      member  : "{MEMBER_ID}",
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                         member:(nullable DIMID *)memberID;

@end

#pragma mark -

@interface DIMInviteCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(nullable DIMID *)memberID;

@end

@interface DIMExpelCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(nullable DIMID *)memberID;

@end

@interface DIMQuitCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

NS_ASSUME_NONNULL_END
