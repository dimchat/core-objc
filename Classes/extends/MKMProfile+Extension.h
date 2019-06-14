//
//  MKMProfile+Extension.h
//  DIMCore
//
//  Created by Albert Moky on 2019/6/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMProfile (Account)

@property (strong, nonatomic) NSString *avatar;

@end

@interface MKMProfile (Group)

@property (strong, nonatomic) NSString *logo;

@end

NS_ASSUME_NONNULL_END
