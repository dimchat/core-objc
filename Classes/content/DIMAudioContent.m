//
//  DIMAudioContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMContentType.h"

#import "DIMAudioContent.h"

@interface DIMContent (Hacking)

@property (nonatomic) UInt8 type;

@end

@implementation DIMAudioContent

- (instancetype)initWithAudioData:(const NSData *)data
                         filename:(nullable const NSString *)name {
    if (self = [self initWithFileData:data filename:name]) {
        // type
        self.type = DIMContentType_Audio;
        
        // TODO: Automatic Speech Recognition
    }
    return self;
}

- (const NSData *)audioData {
    return [self fileData];
}

- (void)setAudioData:(const NSData *)audioData {
    self.fileData = audioData;
}

@end
