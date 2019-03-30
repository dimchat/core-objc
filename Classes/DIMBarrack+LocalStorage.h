//
//  DIMBarrack+LocalStorage.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMBarrack (LocalStorage)

// default: "Documents/.mkm"
@property (strong, nonatomic) NSString *directory;

// default "Documents/.mkm/{address}/meta.plist"
- (nullable const DIMMeta *)loadMetaForID:(const DIMID *)ID;

// default "Documents/.mkm/{address}/meta.plist"
- (BOOL)saveMeta:(const DIMMeta *)meta forEntityID:(const DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
