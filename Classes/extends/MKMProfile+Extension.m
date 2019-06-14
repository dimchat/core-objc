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
    return _valid ? [_properties objectForKey:@"avatar"] : nil;
}

- (void)setAvatar:(NSString *)avatar {
    if ([avatar length] > 0) {
        [_storeDictionary setObject:avatar forKey:@"avatar"];
    } else {
        [_storeDictionary removeObjectForKey:@"avatar"];
    }
    [self reset];
}

@end

@implementation MKMProfile (Group)

- (NSString *)logo {
    return _valid ? [_properties objectForKey:@"logo"] : nil;
}

- (void)setLogo:(NSString *)logo {
    if ([logo length] > 0) {
        [_storeDictionary setObject:logo forKey:@"logo"];
    } else {
        [_storeDictionary removeObjectForKey:@"logo"];
    }
    [self reset];
}

@end
