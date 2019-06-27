//
//  DIMFileContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMFileContent : DIMContent

// URL for download the file data from CDN
@property (strong, nonatomic, nullable) NSURL *URL;

@property (strong, nonatomic, nullable) NSData *fileData;
@property (readonly, strong, nonatomic, nullable) NSString *filename;

// for decrypt file data after download from CDN
@property (strong, nonatomic, nullable) NSDictionary *password;

/**
 *  File message: {
 *      type : 0x10,
 *      sn   : 123,
 *
 *      URL      : "http://", // upload to CDN
 *      data     : "...",     // if (!URL) base64_encode(fileContent)
 *      filename : "..."
 *  }
 */
- (instancetype)initWithFileData:(NSData *)data
                        filename:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
