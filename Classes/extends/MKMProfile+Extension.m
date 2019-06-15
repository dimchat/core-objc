//
//  MKMProfile+Extension.m
//  DIMCore
//
//  Created by Albert Moky on 2019/6/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMProfile+Extension.h"

@implementation MKMProfile (Account)

- (NSString *)avatar {
    return (NSString *)[self dataForKey:@"avatar"];
}

- (void)setAvatar:(NSString *)avatar {
    [self setData:avatar forKey:@"avatar"];
}

@end

@implementation MKMProfile (Group)

- (NSString *)logo {
    return (NSString *)[self dataForKey:@"logo"];
}

- (void)setLogo:(NSString *)logo {
    [self setData:logo forKey:@"logo"];
}

@end
