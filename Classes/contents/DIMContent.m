// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMContent.m
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import "DIMForwardContent.h"
#import "DIMTextContent.h"
#import "DIMFileContent.h"
#import "DIMImageContent.h"
#import "DIMAudioContent.h"
#import "DIMVideoContent.h"
#import "DIMWebpageContent.h"
#import "DIMCommand.h"
#import "DIMMetaCommand.h"
#import "DIMDocumentCommand.h"
#import "DIMHistoryCommand.h"
#import "DIMGroupCommand.h"

#import "DIMContent.h"

@interface DIMContentParser () {
    
    DIMContentParserBlock _block;
}

@end

@implementation DIMContentParser

- (instancetype)init {
    if (self = [super init]) {
        _block = nil;
    }
    return self;
}

- (instancetype)initWithBlock:(DIMContentParserBlock)block {
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (nullable __kindof id<DKDContent>)parse:(NSDictionary *)content {
    NSAssert(_block != nil, @"block not found");
    return _block(content);
}

@end

#pragma mark - Register Parsers

static inline void load_content_parsers() {
    // Top-Secret
    DIMContentParserRegisterClass(DKDContentType_Forward, DIMForwardContent);
    // Text
    DIMContentParserRegisterClass(DKDContentType_Text, DIMTextContent);
    
    // File
    DIMContentParserRegisterClass(DKDContentType_File, DIMFileContent);
    // Image
    DIMContentParserRegisterClass(DKDContentType_Image, DIMImageContent);
    // Audio
    DIMContentParserRegisterClass(DKDContentType_Audio, DIMAudioContent);
    // Video
    DIMContentParserRegisterClass(DKDContentType_Video, DIMVideoContent);
    
    // Web Page
    DIMContentParserRegisterClass(DKDContentType_Page, DIMWebpageContent);
    
    // Command
    id<DKDContentParser> cmdParser = [[DIMCommandParser alloc] init];
    DIMContentParserRegister(DKDContentType_Command, cmdParser);
    
    // History Command
    id<DKDContentParser> hisParser = [[DIMHistoryCommandParser alloc] init];
    DIMContentParserRegister(DKDContentType_History, hisParser);
}

static inline void load_command_parsers() {
    // Meta Command
    DIMCommandParserRegisterClass(DIMCommand_Meta, DIMMetaCommand);
    
    // Document Command
    id<DKDContentParser> docParser = DIMCommandParserWithClass(DIMDocumentCommand);
    DIMCommandParserRegister(DIMCommand_Profile, docParser);
    DIMCommandParserRegister(DIMCommand_Document, docParser);
    
    // Group Commands
    DIMCommandParserRegisterClass(DIMGroupCommand_Invite, DIMInviteCommand);
    DIMCommandParserRegisterClass(DIMGroupCommand_Expel, DIMExpelCommand);
    DIMCommandParserRegisterClass(DIMGroupCommand_Join, DIMJoinCommand);
    DIMCommandParserRegisterClass(DIMGroupCommand_Quit, DIMQuitCommand);
    DIMCommandParserRegisterClass(DIMGroupCommand_Query, DIMQueryGroupCommand);
    DIMCommandParserRegisterClass(DIMGroupCommand_Reset, DIMResetGroupCommand);
}

@implementation DIMContentParser (Register)

+ (void)registerCoreParsers {
    //
    //  Register core content parsers
    //
    load_content_parsers();
    
    //
    //  Register core command parsers
    //
    load_command_parsers();
}

@end
