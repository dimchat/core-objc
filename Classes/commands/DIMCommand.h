//
//  DIMCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMContent (Command)

@property (readonly, strong, nonatomic) NSString *command;

@end

@interface DIMCommand : DIMContent

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
- (instancetype)initWithCommand:(const NSString *)cmd;

@end

#pragma mark System Command

// network
#define DIMSystemCommand_Handshake @"handshake"
#define DIMSystemCommand_Broadcast @"broadcast"

// message
#define DIMSystemCommand_Receipt   @"receipt"

// facebook
#define DIMSystemCommand_Meta      @"meta"
#define DIMSystemCommand_Profile   @"profile"

#pragma mark -

@interface DIMCommand (History)

@property (readonly, strong, nonatomic) NSDate *time;

@end

@interface DIMHistoryCommand : DIMCommand

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
- (instancetype)initWithHistoryCommand:(const NSString *)cmd;

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
