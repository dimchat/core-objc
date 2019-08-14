//
//  DIMAudioContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMAudioContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) UInt8 type;

@end

@implementation DIMAudioContent

- (instancetype)initWithAudioData:(NSData *)data
                         filename:(nullable NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DKDContentType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (NSData *)audioData {
    return [self fileData];
}

- (void)setAudioData:(NSData *)audioData {
    self.fileData = audioData;
}

@end
