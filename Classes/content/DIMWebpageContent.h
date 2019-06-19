//
//  DIMWebpageContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMWebpageContent : DIMContent

@property (readonly, strong, nonatomic) NSURL *URL;
@property (readonly, strong, nonatomic, nullable) NSString *title;
@property (readonly, strong, nonatomic, nullable) NSString *desc;
@property (readonly, strong, nonatomic, nullable) NSData *icon;

/**
 *  Web Page message: {
 *      type : 0x20,
 *      sn   : 123,
 *
 *      URL   : "https://github.com/moky/dimp", // Page URL
 *      icon  : "...",                          // base64_encode(icon)
 *      title : "...",
 *      desc  : "..."
 *  }
 */
- (instancetype)initWithURL:(NSURL *)url
                      title:(nullable NSString *)title
                description:(nullable NSString *)desc
                       icon:(nullable NSData *)icon;

@end

NS_ASSUME_NONNULL_END
