//
//  DIMReceiptCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMReceiptCommand : DIMCommand

@property (readonly, strong, nonatomic) NSString *message;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "receipt",
 *      message : "...",
 *      extra   : info
 *  }
 */
- (instancetype)initWithMessage:(const NSString *)message;

@end

NS_ASSUME_NONNULL_END
