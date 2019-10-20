//
//  DIMCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommand : DIMContent

@property (readonly, strong, nonatomic) NSString *command;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "...", // command name
 *      extra   : info   // command parameters
 *  }
 */
- (instancetype)initWithCommand:(NSString *)cmd;

@end

#pragma mark System Command

// network
#define DIMSystemCommand_Handshake @"handshake"

// message
#define DIMSystemCommand_Receipt   @"receipt"

// facebook
#define DIMSystemCommand_Meta      @"meta"
#define DIMSystemCommand_Profile   @"profile"

@interface DIMCommand (Runtime)

+ (void)registerClass:(nullable Class)cmdClass forCommand:(NSString *)cmd;

+ (nullable Class)classForCommand:(NSString *)cmd;

@end

NS_ASSUME_NONNULL_END
