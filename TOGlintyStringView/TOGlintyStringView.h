//
//  TOGlintyStringView.h
//
//  Copyright 2016 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE
#define TO_VIEW_FOR_PLATFORM UIView
#elif TARGET_OS_MAC
#define TOGLINTY_CROSSPLATFORM_VIEW NSView
#endif

#if TARGET_OS_IPHONE
#define TO_FONT_FOR_PLATFORM UIFont
#elif TARGET_OS_MAC
#define TO_FONT_FOR_PLATFORM NSFont
#endif

#if TARGET_OS_IPHONE
#define TO_IMAGE_FOR_PLATFORM UIImage
#elif TARGET_OS_MAC
#define TO_IMAGE_FOR_PLATFORM NSImage
#endif

@interface TOGlintyStringView : TO_VIEW_FOR_PLATFORM

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGFloat chevronSpacing;

@property (nonatomic, strong) TO_FONT_FOR_PLATFORM *font;
@property (nonatomic, strong) TO_IMAGE_FOR_PLATFORM *chevronImage;
@property (nonatomic, readonly) TO_VIEW_FOR_PLATFORM *effectView;

+ (id)defaultChevronImage;

@end
