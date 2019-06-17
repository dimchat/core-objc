//
//  DIMGroupCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommand (Group)

// Group ID for group message already defined in DKDMessageContent
//@property (strong, nonatomic, nullable) const MKMID *group;

@property (readonly, strong, nonatomic, nullable) const DIMID *member;
@property (readonly, strong, nonatomic, nullable) const NSArray<const DIMID *> *members;

@end

@interface DIMGroupCommand : DIMHistoryCommand

/**
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "join",      // or quit
 *      group   : "{GROUP_ID}",
 *  }
 */
- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const DIMID *)groupID;

/**
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      member  : "{MEMBER_ID}",
 *  }
 */
- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const DIMID *)groupID
                         member:(const DIMID *)memberID;

/**
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "invite",      // or expel
 *      group   : "{GROUP_ID}",
 *      members : ["{MEMBER_ID}", ],
 *  }
 */
- (instancetype)initWithCommand:(const NSString *)cmd
                          group:(const DIMID *)groupID
                        members:(const NSArray<const DIMID *> *)list;

@end

#pragma mark -

@interface DIMInviteCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(const DIMID *)memberID;

- (instancetype)initWithGroup:(const DIMID *)groupID
                      members:(const NSArray<const DIMID *> *)list;

@end

@interface DIMExpelCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                       member:(const DIMID *)memberID;

- (instancetype)initWithGroup:(const DIMID *)groupID
                      members:(const NSArray<const DIMID *> *)list;

@end

@interface DIMJoinCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID;

@end

@interface DIMQuitCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID;

@end

#pragma mark -

@interface DIMResetGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID
                      members:(const NSArray<const DIMID *> *)list;

@end

@interface DIMQueryGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(const DIMID *)groupID;

@end

NS_ASSUME_NONNULL_END
