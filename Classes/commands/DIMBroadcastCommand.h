//
//  DIMBroadcastCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommand (Broadcast)

@property (readonly, strong, nonatomic) NSString *title;

@end

@interface DIMBroadcastCommand : DIMCommand

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "broadcast",
 *      title   : "...", // broadcast title
 *      extra   : info   // broadcast info
 *  }
 */
- (instancetype)initWithTitle:(const NSString *)title;

@end

NS_ASSUME_NONNULL_END
