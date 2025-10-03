// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  DIMWebpageContent.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMContent.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Web Page message: {
 *      type : i2s(0x20),
 *      sn   : 123,
 *
 *      title : "...",                // Web title
 *      desc  : "...",
 *      icon  : "data:image/x-icon;base64,...",
 *
 *      URL   : "https://github.com/moky/dimp",
 *
 *      HTML      : "...",            // Web content
 *      mime_type : "text/html",      // Content-Type
 *      encoding  : "utf8",
 *      base      : "about:blank"     // Base URL
 *
 *  }
 */
@protocol DKDPageContent <DKDContent>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, nullable) id<MKPortableNetworkFile> icon;
@property (strong, nonatomic, nullable) NSString *desc;

@property (strong, nonatomic, nullable) NSURL *URL;
@property (strong, nonatomic, nullable) NSString *HTML;

@end

@interface DIMPageContent : DIMContent <DKDPageContent>

- (instancetype)initWithURL:(NSURL *)url
                      title:(NSString *)title
                description:(nullable NSString *)desc
                       icon:(nullable id<MKTransportableData>)icon;

- (instancetype)initWithHTML:(NSString *)html
                       title:(NSString *)title
                 description:(nullable NSString *)desc
                        icon:(nullable id<MKTransportableData>)icon;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

// create from URL
DIMPageContent *DIMPageContentFromURL(NSURL *url,
                                      NSString *title,
                                      NSString * _Nullable desc,
                                      _Nullable id<MKTransportableData> icon);

// create from HTML
DIMPageContent *DIMPageContentFromHTML(NSString *html,
                                       NSString *title,
                                       NSString * _Nullable desc,
                                       _Nullable id<MKTransportableData> icon);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
