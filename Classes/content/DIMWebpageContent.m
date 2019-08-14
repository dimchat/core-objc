//
//  DIMWebpageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMWebpageContent.h"

@implementation DIMWebpageContent

- (instancetype)initWithURL:(NSURL *)url
                      title:(nullable NSString *)title
                description:(nullable NSString *)desc
                       icon:(nullable NSData *)icon {
    NSAssert(url, @"URL cannot be empty");
    if (self = [self initWithType:DKDContentType_Page]) {
        // url
        if (url) {
            [_storeDictionary setObject:[url absoluteString] forKey:@"URL"];
        }
        
        // title
        if (title) {
            [_storeDictionary setObject:title forKey:@"title"];
        }
        
        // desc
        if (desc) {
            [_storeDictionary setObject:desc forKey:@"desc"];
        }
        
        // icon
        if (icon) {
            NSString *str = [icon base64Encode];
            [_storeDictionary setObject:str forKey:@"icon"];
        }
    }
    return self;
}

- (NSURL *)URL {
    NSString *string = [_storeDictionary objectForKey:@"URL"];
    return [NSURL URLWithString:string];
}

- (NSString *)title {
    return [_storeDictionary objectForKey:@"title"];
}

- (NSString *)desc {
    return [_storeDictionary objectForKey:@"desc"];
}

- (NSData *)icon {
    NSString *str = [_storeDictionary objectForKey:@"icon"];
    return [str base64Decode];
}

@end
