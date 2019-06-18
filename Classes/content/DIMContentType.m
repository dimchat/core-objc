//
//  DIMContentType.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMTextContent.h"
#import "DIMFileContent.h"
#import "DIMImageContent.h"
#import "DIMAudioContent.h"
#import "DIMVideoContent.h"
#import "DIMWebpageContent.h"
#import "DIMForwardContent.h"

#import "DIMCommand.h"
#import "DIMHistoryCommand.h"

#import "DIMContentType.h"

@implementation DIMContent (RegisterClasses)

+ (void)loadContentClasses {
    
    // Text
    [self registerClass:[DIMTextContent class] forType:DIMContentType_Text];
    
    // File
    [self registerClass:[DIMFileContent class] forType:DIMContentType_File];
    // Image
    [self registerClass:[DIMImageContent class] forType:DIMContentType_Image];
    // Audio
    [self registerClass:[DIMAudioContent class] forType:DIMContentType_Audio];
    // Video
    [self registerClass:[DIMVideoContent class] forType:DIMContentType_Video];
    
    // Web Page
    [self registerClass:[DIMWebpageContent class] forType:DIMContentType_Page];
    
    // Top-Secret
    [self registerClass:[DIMForwardContent class] forType:DIMContentType_Forward];
    
    // Command
    [self registerClass:[DIMCommand class] forType:DIMContentType_Command];
    // (Group) History Command
    [self registerClass:[DIMHistoryCommand class] forType:DIMContentType_History];
}

@end
