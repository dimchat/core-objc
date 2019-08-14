//
//  DIMImageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"

#import "DIMImageContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) UInt8 type;

@end

@implementation DIMImageContent

- (instancetype)initWithImageData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DKDContentType_Image;
        
        // TODO: thumbnail
    }
    return self;
}

- (NSData *)imageData {
    return [self fileData];
}

- (void)setImageData:(NSData *)imageData {
    self.fileData = imageData;
}

- (nullable NSData *)thumbnail {
    NSString *small = [_storeDictionary objectForKey:@"thumbnail"];
    return [small base64Decode];
}

@end
