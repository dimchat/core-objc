//
//  DIMChatroom.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMChatroom : DIMGroup

@property (readonly, copy, nonatomic) NSArray<DIMID *> *admins;

- (BOOL)existsAdmin:(DIMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

#pragma mark - Chatroom Delegate

@protocol DIMChatroomDataSource <DIMGroupDataSource>

/**
 *  Get chatroom admin list
 *
 * @param chatroom - group ID
 * @return admins list (ID)
 */
- (NSArray<DIMID *> *)adminsOfChatroom:(DIMID *)chatroom;

@end

NS_ASSUME_NONNULL_END
