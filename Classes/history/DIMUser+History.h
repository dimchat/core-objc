//
//  DIMUser+History.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMHistoryBlock;

@interface DIMUser (History)

/**
 Create register record for the account

 @param hello - say hello to the world
 @return HistoryBlock
 */
- (DIMHistoryBlock *)registerWithMessage:(nullable const NSString *)hello;

/**
 Delete the account, FOREVER!
 
 @param lastWords - last message to the world
 @return HistoryBlock
 */
- (DIMHistoryBlock *)suicideWithMessage:(nullable const NSString *)lastWords;

@end

NS_ASSUME_NONNULL_END
