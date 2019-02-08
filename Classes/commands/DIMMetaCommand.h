//
//  DIMMetaCommand.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMetaCommand : DIMCommand

@property (readonly, strong, nonatomic) DIMID *ID;
@property (readonly, strong, nonatomic, nullable) DIMMeta *meta;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "meta", // command name
 *      ID : "{ID}",      // contact's ID
 *      meta : {...}      // When meta is empty, means query meta for ID
 *  }
 */
- (instancetype)initWithID:(const DIMID *)ID
                      meta:(nullable const DIMMeta *)meta;

@end

NS_ASSUME_NONNULL_END
