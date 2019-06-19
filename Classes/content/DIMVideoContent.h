//
//  DIMVideoContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMFileContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMVideoContent : DIMFileContent

@property (strong, nonatomic) NSData *videoData;
@property (readonly, strong, nonatomic, nullable) NSData *snapshot;

/**
 *  Video message: {
 *      type : 0x16,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64_encode(video)
 *      snapshot : "...",     // base64_encode(smallImage)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithVideoData:(NSData *)data
                         filename:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
