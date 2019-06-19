//
//  DIMHistoryCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMHistoryCommand : DIMCommand

@property (readonly, strong, nonatomic) NSDate *time;

/**
 *  History command: {
 *      type : 0x89,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      time    : 0,     // timestamp
 *      extra   : info   // command parameters
 *  }
 */
- (instancetype)initWithHistoryCommand:(NSString *)cmd;

@end

#pragma mark Account history command

// account
#define DIMHistoryCommand_Register  @"register"
#define DIMHistoryCommand_Suicide   @"suicide"

#pragma mark Group history command

// group: founder/owner
#define DIMGroupCommand_Found      @"found"
#define DIMGroupCommand_Abdicate   @"abdicate"
// group: member
#define DIMGroupCommand_Invite     @"invite"
#define DIMGroupCommand_Expel      @"expel"
#define DIMGroupCommand_Join       @"join"
#define DIMGroupCommand_Quit       @"quit"
// group: administrator/assistant
#define DIMGroupCommand_Hire       @"hire"
#define DIMGroupCommand_Fire       @"fire"
#define DIMGroupCommand_Resign     @"resign"

NS_ASSUME_NONNULL_END
