//
//  TOGlintyGradientLayer.m
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


#import "TOGlintyGradientLayer.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

@interface TOGlintyGradientLayer ()

- (void)setUp;

- (CAKeyframeAnimation *)shimmerAnimation;
- (CAKeyframeAnimation *)reflectionAnimation;

@end

@implementation TOGlintyGradientLayer

- (instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    [self setValue:@(NO) forKey:@"allowsGroupBlending"];
    self.opaque = NO;
    self.masksToBounds = YES;
    self.allowsGroupOpacity = NO;
    
    CGImageRef reflectionImage = nil;
    CGSize reflectionSize = CGSizeZero;
    
    CGImageRef shimmerImage = nil;
    CGSize shimmerSize = CGSizeZero;
    
#if TARGET_OS_IPHONE
    UIImage *_reflectionImage = [UIImage imageNamed:@"TOGlintyStringViewReflectionMask"];
    reflectionSize = _reflectionImage.size;
    reflectionImage = _reflectionImage.CGImage;
    
    UIImage *_shimmerImage    = [UIImage imageNamed:@"TOGlintyStringViewShimmerMask"];
    shimmerSize = _shimmerImage.size;
    shimmerImage = _shimmerImage.CGImage;
#elif TARGET_OS_MAC
    NSImage *_reflectionImage = [NSImage imageNamed:@"TOGlintyStringViewReflectionMask"];
    reflectionImage = [_reflectionImage CGImageForProposedRect:(CGRect){CGPointZero, _reflectionImage.size} context:NULL hints:nil];
    
    NSImage *_shimmerImage    = [NSImage imageNamed:@"TOGlintyStringViewShimmerMask"];
    shimmerImage = [_shimmerImage CGImageForProposedRect:(CGRect){CGPointZero, _shimmerImage.size} context:NULL hints:nil];
#endif

    self.shimmerLayer = [[CALayer alloc] init];
    self.shimmerLayer.opaque = NO;
    self.shimmerLayer.frame = (CGRect){CGPointZero, {646, 46}};
    self.shimmerLayer.opacity = 0.9f;
    self.shimmerLayer.contents = (__bridge id)shimmerImage;
    self.shimmerLayer.compositingFilter = @"linearLightBlendMode";
    [self.shimmerLayer setValue:@(NO) forKey:@"allowsGroupBlending"];
    self.shimmerLayer.allowsGroupOpacity = NO;
    [self addSublayer:self.shimmerLayer];
    
    self.gradientLayer = [[CAGradientLayer alloc] init];
    self.gradientLayer.allowsGroupOpacity = YES;
    self.gradientLayer.opaque = YES;
    self.gradientLayer.opacity = 0.35;
    self.gradientLayer.compositingFilter = @"colorDodgeBlendMode";
    
    CGColorRef lowPointColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){0.05f, 1.0f});
    CGColorRef highPointColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){0.95f, 1.0f});
    self.gradientLayer.colors = @[(__bridge id)lowPointColor, (__bridge id)highPointColor, (__bridge id)lowPointColor];
    self.gradientLayer.frame = (CGRect){CGPointZero, {646, 46}};
    [self addSublayer:self.gradientLayer];
    
    self.reflectionLayer = [[CALayer alloc] init];
    self.reflectionLayer.opaque = NO;
    self.reflectionLayer.frame = (CGRect){CGPointZero, {646, 46}};
    self.reflectionLayer.opacity = 0.75f;
    self.reflectionLayer.contents = (__bridge id)reflectionImage;
    self.reflectionLayer.allowsGroupOpacity = YES;
    self.reflectionLayer.compositingFilter = @"multiplyBlendMode";
    [self addSublayer:self.reflectionLayer];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    frame = self.gradientLayer.frame;
    frame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(frame)) * 0.5f;
    frame.origin.y += 2;
    self.gradientLayer.frame = frame;
}

- (void)startAnimation
{
    [self.reflectionLayer addAnimation:[self reflectionAnimation] forKey:@"reflectionAnimation"];
    [self.shimmerLayer addAnimation:[self shimmerAnimation] forKey:@"shimmerAnimation"];
}

- (void)stopAnimation
{
    [self.reflectionLayer removeAllAnimations];
    [self.shimmerLayer removeAllAnimations];
}

- (CAKeyframeAnimation *)shimmerAnimation
{
    CAKeyframeAnimation *shimmerAnimation = [[CAKeyframeAnimation alloc] init];
    shimmerAnimation.values = @[@(0), @(320)];
    shimmerAnimation.keyTimes = @[@(0), @(1)];
    shimmerAnimation.repeatCount = HUGE_VALF;
    shimmerAnimation.removedOnCompletion = NO;
    shimmerAnimation.duration = 2;
    shimmerAnimation.fillMode = @"both";
    shimmerAnimation.keyPath = @"position.x";
    return shimmerAnimation;
}

- (CAKeyframeAnimation *)reflectionAnimation
{
    CAKeyframeAnimation *reflectionAnimation = [[CAKeyframeAnimation alloc] init];
    reflectionAnimation.values = @[@(0), @(320)];
    reflectionAnimation.keyTimes = @[@(0), @(1)];
    reflectionAnimation.repeatCount = HUGE_VALF;
    reflectionAnimation.removedOnCompletion = NO;
    reflectionAnimation.fillMode = @"both";
    reflectionAnimation.duration = 2;
    reflectionAnimation.keyPath = @"position.x";
    return reflectionAnimation;
}

@end
