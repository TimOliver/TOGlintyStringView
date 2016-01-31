//
//  TOGlintyStringView.m
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

#import <QuartzCore/QuartzCore.h>

#import "TOGlintyStringView.h"
#import "TOGlintyShapeLayer.h"
#import "TOGlintyGradientLayer.h"
#import "ARCGPathFromString.h"

@interface TOGlintyStringView ()

@property (nonatomic, strong) TOGlintyGradientLayer *gradientLayer;
@property (nonatomic, strong) TOGlintyShapeLayer *shapeLayer;
@property (nonatomic, strong) CALayer *fillLayer;
@property (nonatomic, strong) CALayer *textLayer;

@property (nonatomic, assign) CGPathRef textPath;

#if TARGET_OS_IPHONE
@property (nonatomic, strong, readwrite) UIView *effectView;
#elif TARGET_OS_MAC
@property (nonatomic, strong, readwrite) NSView *effectView;
#endif

- (CGPathRef)pathForCurrentTextAndFont;
- (CGPathRef)offsetForChevronWithTextPath:(CGPathRef)path offset:(CGPoint *)offset;

- (void)setUp;
- (void)resetContent;
- (void)sizeLayersForContent;
- (void)renderContent;

@end

@implementation TOGlintyStringView

#pragma mark - View Creation -
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }

    return self;
}

#pragma mark - Set-up -
- (void)setUp
{
    self.text = @"slide to unlock";
    self.chevronSpacing = 10.0f;
    
#if TARGET_OS_IPHONE
    self.font = [UIFont systemFontOfSize:24.0f];
#elif TARGET_OS_MAC
    self.font = [NSFont systemFontOfSize:24.0f];
#endif

    //Configure this view
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
    self.wantsLayer = YES;
#endif
    
    self.layer.allowsGroupOpacity = YES;
    self.layer.opaque = NO;
    self.opaque = NO;
    
    // TECHNICALLY a private API, but necessary to allow discrete blend modes on layers
    [self.layer setValue:@(NO) forKey:@"allowsGroupBlending"];
    
    //Create the effect view
    if (self.effectView == nil) {
#if TARGET_OS_IPHONE
        self.effectView = [[UIView alloc] initWithFrame:CGRectZero];
        self.effectView.opaque = NO;;
#elif TARGET_OS_MAC
        self.effectView = [[NSView alloc] initWithFrame:CGRectZero];
        self.effectView.wantsLayer = YES;
#endif
        [self.effectView.layer setValue:@(NO) forKey:@"allowsGroupBlending"];
        self.effectView.layer.compositingFilter = @"linearLightBlendMode";
        self.effectView.layer.opaque = NO;
        [self addSubview:self.effectView];
    }
    
    if (self.shapeLayer == nil) {
        self.shapeLayer = [[TOGlintyShapeLayer alloc] init];
        [self.effectView.layer addSublayer:self.shapeLayer];
    }
    
    if (self.gradientLayer == nil) {
        self.gradientLayer = [[TOGlintyGradientLayer alloc] init];
        [self.effectView.layer addSublayer:self.gradientLayer];
    }
    
    if (self.fillLayer == nil) {
        self.fillLayer = [[CALayer alloc] init];
        self.fillLayer.compositingFilter = @"screenBlendMode";
        self.fillLayer.allowsGroupOpacity = NO;
        [self.fillLayer setValue:@(NO) forKey:@"allowsGroupBlending"];
        self.fillLayer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){0.39f, 1.0f});
        [self.effectView.layer addSublayer:self.fillLayer];
    }
    
    if (self.textLayer == nil) {
        self.textLayer = [[CALayer alloc] init];
        self.textLayer.compositingFilter = @"destIn";
        self.textLayer.rasterizationScale = 2.0f;
        self.textLayer.contentsScale = 2.0f;
        self.textLayer.allowsGroupOpacity = YES;
        [self.effectView.layer addSublayer:self.textLayer];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self resetContent];
    [self.gradientLayer startAnimation];
}

- (void)layoutSubviews
{
    CGRect frame = self.effectView.frame;
    frame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(frame)) * 0.5f;    
    frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) * 0.5f;
    self.effectView.frame = frame;
}

- (void)resetContent
{
    [self sizeLayersForContent];
    [self renderContent];
    [self setNeedsLayout];
}

- (void)sizeLayersForContent
{
    //Release our reference to the previous path for now
    if (self.textPath) {
        CGPathRelease(self.textPath);
        self.textPath = nil;
    }
    
    CGPoint offset = CGPointZero;
    self.textPath = [self pathForCurrentTextAndFont];
    
    CGRect bounds = CGPathGetPathBoundingBox(self.textPath);
    bounds.size.height = ceilf(bounds.size.height);
    bounds.size.width = ceilf(bounds.size.width);
    
    if (self.chevronImage) {
        self.textPath = [self offsetForChevronWithTextPath:self.textPath offset:&offset];
    
        CGSize chevronSize = [self.chevronImage size];
        bounds.size.height = MAX(offset.y + bounds.size.height, chevronSize.height);
        bounds.size.width += offset.x;
    }
    
    self.shapeLayer.path = self.textPath;
    
    bounds.origin = CGPointZero;
    self.shapeLayer.frame = bounds;
    self.textLayer.frame = bounds;
    self.fillLayer.frame = bounds;
    self.gradientLayer.frame = bounds;

    self.effectView.frame = bounds;
}

- (void)renderContent
{
    CGImageRef image = nil;
    CGSize size = self.textLayer.frame.size;
    
#if TARGET_OS_IPHONE
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    [self.chevronImage drawAtPoint:CGPointZero];
    CGContextAddPath(context, self.textPath);
    CGContextFillPath(context);
    image = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
#elif TARGET_OS_MAC
    
    NSImage *im = [[NSImage alloc] initWithSize:size];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:size.width
                             pixelsHigh:size.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    
    [im addRepresentation:rep];
    [im lockFocus];
    
    CGColorRef fillColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), (CGFloat []){1.0f, 1.0f});
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextAddPath(context, self.textPath);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
    
    [im unlock]
    
    image = [im CGImageForProposedRect:(CGRect){CGPointZero, size} context:NULL hints:nil];
    
#endif
    
    self.textLayer.contents = (__bridge id)image;
}

- (CGPathRef)pathForCurrentTextAndFont
{
    NSDictionary *attributes = @{NSFontAttributeName : self.font};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    CGPathRef path = CGPathCreateSingleLineStringWithAttributedString(string);
    
    //Normalize the path to make sure its bounds are properly at 0,0
    CGRect frame = CGPathGetPathBoundingBox(path);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-frame.origin.x, -frame.origin.y);
    CGPathRef newPath = CGPathCreateCopyByTransformingPath(path, &transform);
    CGPathRelease(path);
    
    return newPath;
}

- (CGPathRef)offsetForChevronWithTextPath:(CGPathRef)path offset:(CGPoint *)offset
{
    if (self.chevronImage == nil) {
        return NULL;
    }
    
    CGSize chevronSize = [self.chevronImage size];
    CGPoint _offset = CGPointZero;
    CGRect bounds = CGPathGetPathBoundingBox(path);
    
    // offset the text path horizontally by the chevron
    _offset.x = fabs(bounds.origin.x) + chevronSize.width + self.chevronSpacing;
    
    //if the chevron is bigger than the text, offset the text vertically
    if (bounds.size.height < chevronSize.height) {
        _offset.y = (chevronSize.height - CGRectGetHeight(bounds)) * 0.5f;
    }
    
    *offset = _offset;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(_offset.x, _offset.y);
    CGPathRef translatedPath = CGPathCreateCopyByTransformingPath(path, &transform);
    CGPathRelease(path);
    
    return translatedPath;
}

#pragma mark - Property Methods -
- (void)setChevronImage:(id)chevronImage
{
    if (_chevronImage == chevronImage) {
        return;
    }
    
    _chevronImage = chevronImage;

    [self resetContent];
}

#pragma mark - Class Methods -
+ (id)defaultChevronImage
{
    return (id)[TO_IMAGE_FOR_PLATFORM imageNamed:@"TOGlintyStringViewChevron"];
}

@end
