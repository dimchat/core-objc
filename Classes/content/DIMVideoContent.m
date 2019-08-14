//
//  DIMVideoContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DIMVideoContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) UInt8 type;

@end

@implementation DIMVideoContent

- (instancetype)initWithVideoData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DKDContentType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (NSData *)videoData {
    return [self fileData];
}

- (void)setVideoData:(NSData *)videoData {
    self.fileData = videoData;
}

- (nullable NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

@end
