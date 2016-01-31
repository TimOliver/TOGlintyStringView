//
//  TOGlintyShapeLayer.m
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

#import "TOGlintyShapeLayer.h"

@interface CAFilter : NSObject

@property (copy) NSString *name;

+ (instancetype)filterWithName:(id)name;
- (instancetype)initWithName:(id)name;

@end

@implementation TOGlintyShapeLayer

- (instancetype)init
{
    if (self = [super init]) {
        self.opaque = NO;
        self.shouldRasterize = YES;
        [self setValue:@(NO) forKey:@"allowsGroupBlending"];
        self.lineDashPattern = @[@(10), @(10)];
        self.lineJoin = @"round";
        self.lineCap = @"round";
        self.miterLimit = 5;
        self.lineWidth = 1.5f;
        self.allowsGroupOpacity = NO;
        self.strokeColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){1.0f, 1.0f});
        self.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){0.0f, 1.0f});
        self.transform = CATransform3DScale(CATransform3DIdentity, 1.0f, -1.0f, 1.0f);
        
        // WARNING: This is exposing a private API and will absolutely
        // not be accepted on the App Store. Use at your own risk!
        CAFilter *blurFilter = [CAFilter filterWithName:@"gaussianBlur"];
        [blurFilter setValue:@(1) forKey:@"inputRadius"];
        self.filters = @[blurFilter];
    }
    
    return self;
}

@end
