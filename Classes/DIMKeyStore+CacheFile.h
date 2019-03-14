//
//  DIMKeyStore+CacheFile.h
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMKeyStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMKeyStore (CacheFile)

// "Library/Caches/.ks"
@property (strong, nonatomic) NSString *directory;

/**
 Save cipher keys (from accounts/group.members) if changed.
 
 DON'T call it manually!
 it will be called automatically when changing current user or dealloc.
 
 @return YES when changed, or NO for nothing changed
 */
- (BOOL)flush;

/**
 Load cipher keys (from accounts/group.members) to current user.
 
 DON'T call it manually!
 it will be called automatically when changing current user
 
 @return YES when changed, or NO for nothing found
 */
- (BOOL)reload;

@end

NS_ASSUME_NONNULL_END
