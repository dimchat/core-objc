//
//  DIMVideoContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DIMContentType.h"

#import "DIMVideoContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) UInt8 type;

@end

@implementation DIMContent (Video)

- (instancetype)initWithVideoData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:nil]) {
        // type
        self.type = DIMContentType_Video;
        
        // TODO: snapshot
    }
    return self;
}

- (const NSData *)videoData {
    return [self fileData];
}

- (void)setVideoData:(const NSData *)videoData {
    self.fileData = videoData;
}

- (nullable const NSData *)snapshot {
    NSString *ss = [_storeDictionary objectForKey:@"snapshot"];
    return [ss base64Decode];
}

@end
