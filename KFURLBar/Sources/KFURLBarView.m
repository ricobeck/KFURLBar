//
//  KFURLBarView.m
//  KFJSON
//
//  Created by Rico Becker on 2/15/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
//

#import "KFURLBarView.h"
#import "KFURLFormatter.h"

#define kKFURLBarGradientColorTop [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0f]
#define kKFURLBarGradientColorBottom [NSColor colorWithCalibratedRed:0.700f green:0.700f blue:0.700f alpha:1.0f]

#define kKFURLBarBorderColorTop [NSColor colorWithDeviceWhite:0.6 alpha:1.0f]
#define kKFURLBarBorderColorBottom [NSColor colorWithDeviceWhite:0.2 alpha:1.0f]


@interface KFURLBarView ()

@property (nonatomic, strong) NSColor *currentBarColorTop;
@property (nonatomic, strong) NSColor *currentBarColorBottom;
@property (nonatomic, strong) NSTextField *urlTextField;


@end


@implementation KFURLBarView


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initializeDefaults];
    }
    return self;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeDefaults];
    }
    return self;
}


- (instancetype)initWithDelegate:(id<KFURLBarDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        [self initializeDefaults];
    }
    return self;
}


- (void)awakeFromNib
{
    [self initializeDefaults];
}



- (void)initializeDefaults
{
    _progress = .0f;
    _progressPhase = BarProgressPhasePending;
    self.gradientColorTop = kKFURLBarGradientColorTop;
    self.gradientColorBottom = kKFURLBarGradientColorBottom;

    self.borderColorTop = kKFURLBarBorderColorTop;
    self.borderColorBottom = kKFURLBarBorderColorBottom;
    
    self.urlTextField = [[NSTextField alloc] init];
    self.urlTextField.bezeled = NO;
    self.urlTextField.focusRingType = NSFocusRingTypeNone;
    self.urlTextField.drawsBackground = NO;
    self.urlTextField.textColor = [NSColor blackColor];
    self.urlTextField.editable = YES;
    [self.urlTextField.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.urlTextField.formatter = [[KFURLFormatter alloc] init];
    [self addSubview:self.urlTextField];
    
    NSLayoutConstraint *textFieldCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    NSLayoutConstraint *textFieldLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20];
    NSLayoutConstraint *textFieldTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-95];

    [self addConstraints:@[textFieldCenterYConstraint, textFieldLeadingConstraint, textFieldTrailingConstraint]];
    
    
}


- (void)drawRect:(NSRect)dirtyRect
{
    //// Color Declarations
    NSColor* fillColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.393];
    NSColor* color = [NSColor colorWithCalibratedRed: 0.667 green: 0.667 blue: 0.667 alpha: 1];
    
    NSColor *color4;
    NSColor *color5;
    
    switch (self.progressPhase)
    {
        case BarProgressPhasePending:
            color4 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 0.243 alpha: 0.395];
            color5 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 0.774 alpha: 0];
            break;
        case BarProgressPhaseDownloading:
            
            color4 = [NSColor colorForControlTint:[NSColor currentControlTint]];
            color5 = [[NSColor colorForControlTint:[NSColor currentControlTint]] colorWithAlphaComponent:.1f];
        default:
            break;
    }

    NSColor* color6 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0];
    
    NSGradient* progressGradient = [[NSGradient alloc] initWithStartingColor: color5 endingColor: color4];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: strokeColor];
    [shadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [shadow setShadowBlurRadius: 3];
    
    //// Frames
    NSRect frame = self.bounds;
    
    
    //// Background Drawing
    if (self.gradientColorTop && self.gradientColorBottom)
    {
        [[[NSGradient alloc] initWithStartingColor:self.gradientColorTop endingColor:self.gradientColorBottom] drawInRect:self.bounds angle:-90.0];
    }
    
    [NSBezierPath setDefaultLineWidth:0.0f];
    
    if (self.borderColorTop)
    {
        [self.borderColorTop setStroke];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds)) toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    }
    
    if (self.borderColorBottom)
    {
        [self.borderColorBottom setStroke];
        
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds)) toPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    }
    
    
    //// AddressBar Background Drawing
    NSBezierPath* addressBarBackgroundPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, NSWidth(frame) - 97, NSHeight(frame) - 10) xRadius: 10 yRadius: 10];
    [fillColor setFill];
    [addressBarBackgroundPath fill];
    [color setStroke];
    [addressBarBackgroundPath setLineWidth: 1];
    [addressBarBackgroundPath stroke];
    
    
    //// AddressBar Progress Drawing
    
    if (self.progress > .0f && self.progress < 1.0f)
    {
        CGFloat addressBarProgressCornerRadius = 10;
        CGFloat progressWidth = MAX((NSWidth(frame) - 97) * self.progress, 57);
        NSRect addressBarProgressRect = NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, progressWidth, NSHeight(frame) - 10);
        NSRect addressBarProgressInnerRect = NSInsetRect(addressBarProgressRect, addressBarProgressCornerRadius, addressBarProgressCornerRadius);
        NSBezierPath* addressBarProgressPath = [NSBezierPath bezierPath];
        [addressBarProgressPath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(addressBarProgressInnerRect), NSMinY(addressBarProgressInnerRect)) radius: addressBarProgressCornerRadius startAngle: 180 endAngle: 270];
        [addressBarProgressPath lineToPoint: NSMakePoint(NSMaxX(addressBarProgressRect), NSMinY(addressBarProgressRect))];
        [addressBarProgressPath lineToPoint: NSMakePoint(NSMaxX(addressBarProgressRect), NSMaxY(addressBarProgressRect))];
        [addressBarProgressPath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(addressBarProgressInnerRect), NSMaxY(addressBarProgressInnerRect)) radius: addressBarProgressCornerRadius startAngle: 90 endAngle: 180];
        [addressBarProgressPath closePath];
        [progressGradient drawInBezierPath: addressBarProgressPath angle: -90];
    }
    
    //// AddressBar Drawing
    NSBezierPath* addressBarPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, NSWidth(frame) - 97, NSHeight(frame) - 10) xRadius: 10 yRadius: 10];
    [color6 setFill];
    [addressBarPath fill];
    
    ////// AddressBar Inner Shadow
    NSRect addressBarBorderRect = NSInsetRect([addressBarPath bounds], -shadow.shadowBlurRadius, -shadow.shadowBlurRadius);
    addressBarBorderRect = NSOffsetRect(addressBarBorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
    addressBarBorderRect = NSInsetRect(NSUnionRect(addressBarBorderRect, [addressBarPath bounds]), -1, -1);
    
    NSBezierPath* addressBarNegativePath = [NSBezierPath bezierPathWithRect: addressBarBorderRect];
    [addressBarNegativePath appendBezierPath: addressBarPath];
    [addressBarNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* shadowWithOffset = [shadow copy];
        CGFloat xOffset = shadowWithOffset.shadowOffset.width + round(addressBarBorderRect.size.width);
        CGFloat yOffset = shadowWithOffset.shadowOffset.height;
        shadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [shadowWithOffset set];
        [[NSColor grayColor] setFill];
        [addressBarPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(addressBarBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: addressBarNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [color setStroke];
    [addressBarPath setLineWidth: 1];
    [addressBarPath stroke];
}


- (void)setProgress:(double)progress
{
    if (progress != _progress)
    {
        _progress = progress;
        [self setNeedsDisplay:YES];
    }
    
}


- (void)setProgressPhase:(BarProgressPhase)progressPhase
{
    if (progressPhase != _progressPhase)
    {
        _progressPhase = progressPhase;
        [self setNeedsDisplay:YES];
    }
}


@end
