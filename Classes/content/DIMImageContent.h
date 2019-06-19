//
//  DIMImageContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMFileContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMImageContent : DIMFileContent

@property (strong, nonatomic) NSData *imageData;
@property (readonly, strong, nonatomic, nullable) NSData *thumbnail;

/**
 *  Image message: {
 *      type : 0x12,
 *      sn   : 123,
 *
 *      URL       : "http://", // upload to CDN
 *      data      : "...",     // if (!URL) base64_encode(image)
 *      thumbnail : "...",     // base64_encode(smallImage)
 *      filename  : "..."
 *  }
 */
- (instancetype)initWithImageData:(NSData *)data
                         filename:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
