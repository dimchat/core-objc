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
//  DIMWebpageContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDContentType.h"

#import "DIMWebpageContent.h"

@interface DIMPageContent () {
    
    id<MKTransportableData> _image;
    NSURL *_url;
}

@end

@implementation DIMPageContent

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        _image = nil;
        _url = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy load
        _image = nil;
        _url = nil;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
                      title:(NSString *)title
                description:(nullable NSString *)desc
                       icon:(nullable id<MKTransportableData>)icon {
    if (self = [self initWithType:DKDContentType_Page]) {
        self.URL = url;
        self.title = title;
        if (desc) {
            self.desc = desc;
        }
        if (icon) {
            [self _setImage:icon];
        }
    }
    return self;
}

- (instancetype)initWithHTML:(NSString *)html
                       title:(NSString *)title
                 description:(nullable NSString *)desc
                        icon:(nullable id<MKTransportableData>)icon {
    if (self = [self initWithType:DKDContentType_Page]) {
        self.HTML = html;
        self.title = title;
        if (desc) {
            self.desc = desc;
        }
        if (icon) {
            [self _setImage:icon];
        }
    }
    return self;
}

#pragma mark title

// Override
- (NSString *)title {
    return [self stringForKey:@"title" defaultValue:@""];
}

// Override
- (void)setTitle:(NSString *)title {
    [self setObject:title forKey:@"title"];
}

#pragma mark favicon.ico

// Override
- (NSData *)icon {
    id<MKTransportableData> ted = _image;
    if (!ted) {
        id base64 = [self objectForKey:@"icon"];
        _image = ted = MKTransportableDataParse(base64);
    }
    return [ted data];
}

// Override
- (void)setIcon:(NSData *)icon {
    id<MKTransportableData> ted;
    if ([icon length] == 0) {
        ted = nil;
    } else {
        ted = MKTransportableDataCreate(icon, nil);
    }
    [self _setImage:ted];
}

- (void)_setImage:(id<MKTransportableData>)ted {
    if (!ted) {
        [self removeObjectForKey:@"icon"];
    } else {
        [self setObject:ted.object forKey:@"icon"];
    }
    _image = ted;
}

#pragma mark keyword /description

// Override
- (NSString *)desc {
    return [self stringForKey:@"desc" defaultValue:nil];
}

// Override
- (void)setDesc:(NSString *)desc {
    [self setObject:desc forKey:@"desc"];
}

#pragma mark URL

// Override
- (NSURL *)URL {
    if (!_url) {
        NSString *string = [self stringForKey:@"URL" defaultValue:nil];
        if ([string length] > 0) {
            _url = [NSURL URLWithString:string];
        }
    }
    return _url;
}

// Override
- (void)setURL:(NSURL *)remote {
    [self setObject:remote.absoluteString forKey:@"URL"];
    _url = remote;
}

#pragma mark HTML

// Override
- (NSString *)HTML {
    return [self stringForKey:@"HTML" defaultValue:nil];
}

// Override
- (void)setHTML:(NSString *)html {
    [self setObject:html forKey:@"HTML"];
}

@end

#pragma mark - Conveniences

DIMPageContent *DIMPageContentFromURL(NSURL *url,
                                      NSString *title,
                                      NSString *desc,
                                      id<MKTransportableData> icon) {
    return [[DIMPageContent alloc] initWithURL:url
                                         title:title
                                   description:desc
                                          icon:icon];
}

DIMPageContent *DIMPageContentFromHTML(NSString *html,
                                       NSString *title,
                                       NSString * _Nullable desc,
                                       _Nullable id<MKTransportableData> icon) {
    return [[DIMPageContent alloc] initWithHTML:html
                                          title:title
                                    description:desc
                                           icon:icon];
}
