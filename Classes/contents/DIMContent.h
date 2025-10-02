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
//  DIMContent.h
//  DIMCore
//
//  Created by Albert Moky on 2020/12/8.
//  Copyright © 2020 DIM Group. All rights reserved.
//

#import <DaoKeDao/DaoKeDao.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum DKDContentType
 *
 *  @abstract A flag to indicate what kind of message content this is.
 *
 *  @discussion A message is something send from one place to another one,
 *      it can be an instant message, a system command, or something else.
 *
 *      DKDContentType_Text indicates this is a normal message with plaintext.
 *
 *      DKDContentType_File indicates this is a file, it may include filename
 *      and file data, but usually the file data will encrypted and upload to
 *      somewhere and here is just a URL to retrieve it.
 *
 *      DKDContentType_Image indicates this is an image, it may send the image
 *      data directly(encrypt the image data with Base64), but we suggest to
 *      include a URL for this image just like the 'File' message, of course
 *      you can get a thumbnail of this image here.
 *
 *      DKDContentType_Audio indicates this is a voice message, you can get
 *      a URL to retrieve the voice data just like the 'File' message.
 *
 *      DKDContentType_Video indicates this is a video file.
 *
 *      DKDContentType_Page indicates this is a web page.
 *
 *      DKDContentType_Quote indicates this message has quoted another message
 *      and the message content should be a plaintext.
 *
 *      DKDContentType_Command indicates this is a command message.
 *
 *      DKDContentType_Forward indicates here contains a TOP-SECRET message
 *      which needs your help to redirect it to the true receiver.
 *
 *  Bits:
 *      0000 0001 - this message contains plaintext you can read.
 *      0000 0010 - this is a message you can see.
 *      0000 0100 - this is a message you can hear.
 *      0000 1000 - this is a message for the bot, not for human.
 *
 *      0001 0000 - this message's main part is in somewhere else.
 *      0010 0000 - this message contains the 3rd party content.
 *      0100 0000 - this message contains digital assets
 *      1000 0000 - this is a message send by the system, not human.
 *
 *      (All above are just some advices to help choosing numbers :P)
 */

FOUNDATION_EXPORT NSString * DKDContentType_Any;      // 0x00: 0000 0000 (Undefined)

FOUNDATION_EXPORT NSString * DKDContentType_Text;     // 0x01: 0000 0001

FOUNDATION_EXPORT NSString * DKDContentType_File;     // 0x10: 0001 0000
FOUNDATION_EXPORT NSString * DKDContentType_Image;    // 0x12: 0001 0010
FOUNDATION_EXPORT NSString * DKDContentType_Audio;    // 0x14: 0001 0100
FOUNDATION_EXPORT NSString * DKDContentType_Video;    // 0x16: 0001 0110

// Web Page
FOUNDATION_EXPORT NSString * DKDContentType_Page;     // 0x20: 0010 0000

// Name Card
FOUNDATION_EXPORT NSString * DKDContentType_NameCard; // 0x33: 0011 0011

// Quote a message before and reply it with text
FOUNDATION_EXPORT NSString * DKDContentType_Quote;    // 0x37: 0011 0111

FOUNDATION_EXPORT NSString * DKDContentType_Money;        // 0x40: 0100 0000
FOUNDATION_EXPORT NSString * DKDContentType_Transfer;     // 0x41: 0100 0001
FOUNDATION_EXPORT NSString * DKDContentType_LuckyMoney;   // 0x42: 0100 0010
FOUNDATION_EXPORT NSString * DKDContentType_ClaimPayment; // 0x48: 0100 1000 (Claim for Payment)
FOUNDATION_EXPORT NSString * DKDContentType_SplitBill;    // 0x49: 0100 1001 (Split the Bill)

FOUNDATION_EXPORT NSString * DKDContentType_Command;      // 0x88: 1000 1000
FOUNDATION_EXPORT NSString * DKDContentType_History;      // 0x89: 1000 1001 (Entity History Command)

// Application Customized
FOUNDATION_EXPORT NSString * DKDContentType_Application;      // 0xA0: 1010 0000 (Aoplication 0nly, Reserved)
//FOUNDATION_EXPORT NSString * DKDContentType_Application_1;  // 0xA1: 1010 0001 (Reserved)
//                             ...                            //       1010 ???? (Reserved)
//FOUNDATION_EXPORT NSString * DKDContentType_Application_15; // 0xAF: 1010 1111 (Reserved)

//FOUNDATION_EXPORT NSString * DKDContentType_Customized_0;   // 0xC0: 1100 0000 (Reserved)
//FOUNDATION_EXPORT NSString * DKDContentType_Customized_1;   // 0xC1: 1100 0001 (Reserved)
//                           .....                            //       1100 ???? (Reserved)
FOUNDATION_EXPORT NSString * DKDContentType_Array;            // 0xCA: 1100 1010 (Content Array)
//                           ...                              //       1100 ???? (Reserved)
FOUNDATION_EXPORT NSString * DKDContentType_Customized;       // 0xCC: 1100 1100 (Customized Content)
//                           ...                              //       1100 ???? (Reserved)
FOUNDATION_EXPORT NSString * DKDContentType_CombineForward;   // 0xCF: 1100 1111 (Combine and Forward)

// Top-Secret message forward by proxy (MTA)
FOUNDATION_EXPORT NSString * DKDContentType_Forward;          // 0xFF: 1111 1111

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initializes all content type constants.
 *
 * This function is designed to be automatically called before main()
 * using the GCC/Clang `__attribute__((constructor))` extension.
 *
 * Internally, it employs `dispatch_once` to ensure that the actual
 * initialization logic (creating NSString objects) is executed
 * exactly once across the application's lifecycle, and in a thread-safe manner.
 *
 * Manual invocation of this function is generally NOT required,
 * as it's automatically handled at program startup. It is primarily
 * exposed for extreme edge cases where the automatic invocation might
 * be circumvented (e.g., in highly specialized non-standard environments),
 * or for specific debugging/testing scenarios if necessary.
 * Multiple manual calls will still only result in a single initialization.
 */
void DKDInitializeContentTypes(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark - Base Content

@interface DIMContent : MKDictionary <DKDContent>

- (instancetype)initWithDictionary:(NSDictionary *)dict NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(NSString *)type NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
