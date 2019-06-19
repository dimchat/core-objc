//
//  DIMGroupCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMHistoryCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupCommand : DIMHistoryCommand

// Group ID for group message already defined in DKDContent
//@property (strong, nonatomic, nullable) DIMID *group;

@property (readonly, strong, nonatomic, nullable) DIMID *member;
@property (readonly, strong, nonatomic, nullable) NSArray<DIMID *> *members;

/**
 *  Group history command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "join",      // or quit
 *      group   : "{GROUP_ID}",
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID;

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
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                         member:(DIMID *)memberID;

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
- (instancetype)initWithCommand:(NSString *)cmd
                          group:(DIMID *)groupID
                        members:(NSArray<DIMID *> *)list;

@end

#pragma mark -

@interface DIMInviteCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID;

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMExpelCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                       member:(DIMID *)memberID;

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMJoinCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

@interface DIMQuitCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

#pragma mark -

@interface DIMResetGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID
                      members:(NSArray<DIMID *> *)list;

@end

@interface DIMQueryGroupCommand : DIMGroupCommand

- (instancetype)initWithGroup:(DIMID *)groupID;

@end

NS_ASSUME_NONNULL_END
