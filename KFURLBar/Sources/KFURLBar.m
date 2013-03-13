//
//  KFURLBarView.m
//  KFJSON
//
//  Created by Rico Becker on 2/15/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
//

#import "KFURLBar.h"
#import "KFURLFormatter.h"

#define kKFURLBarGradientColorTop [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0f]
#define kKFURLBarGradientColorBottom [NSColor colorWithCalibratedRed:0.700f green:0.700f blue:0.700f alpha:1.0f]

#define kKFURLBarBorderColorTop [NSColor colorWithDeviceWhite:0.6 alpha:1.0f]
#define kKFURLBarBorderColorBottom [NSColor colorWithDeviceWhite:0.2 alpha:1.0f]


@interface KFURLBar ()

@property (nonatomic, strong) NSColor *currentBarColorTop;
@property (nonatomic, strong) NSColor *currentBarColorBottom;
@property (nonatomic, strong) NSTextField *urlTextField;
@property (nonatomic, strong) NSButton *loadButton;


@end


@implementation KFURLBar


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


- (void)initializeDefaults
{
    _progress = .0f;
    _progressPhase = KFProgressPhaseNone;
    self.gradientColorTop = kKFURLBarGradientColorTop;
    self.gradientColorBottom = kKFURLBarGradientColorBottom;

    self.borderColorTop = kKFURLBarBorderColorTop;
    self.borderColorBottom = kKFURLBarBorderColorBottom;
    
    self.urlTextField = [[NSTextField alloc] init];
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.urlTextField.bezeled = NO;
    self.urlTextField.stringValue = @"http://";
    self.urlTextField.focusRingType = NSFocusRingTypeNone;
    self.urlTextField.drawsBackground = NO;
    self.urlTextField.textColor = [NSColor blackColor];
    [self.urlTextField.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    self.urlTextField.formatter = [[KFURLFormatter alloc] init];
    self.urlTextField.action = @selector(didPressEnter:);
    self.urlTextField.target = self;
    [self addSubview:self.urlTextField];
    
    self.loadButton = [[NSButton alloc] init];
    self.loadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loadButton setBezelStyle:NSTexturedRoundedBezelStyle];
    self.loadButton.target = self;
    self.loadButton.action = @selector(didPressEnter:);
    self.loadButton.title = @"Load";
    [self addSubview:self.loadButton];
    
    NSView *urlTextField = self.urlTextField;
    NSView *loadButton = self.loadButton;
    NSDictionary *views = NSDictionaryOfVariableBindings(urlTextField, loadButton);
    
    NSLayoutConstraint *textFieldCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//    NSLayoutConstraint *textFieldLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20];
//    NSLayoutConstraint *textFieldTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-85];
    
    [self addConstraints:@[textFieldCenterYConstraint]];
    
    NSLayoutConstraint *loadButtonCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.loadButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//    NSLayoutConstraint *loadButtonTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.loadButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20];
    [self addConstraints:@[loadButtonCenterYConstraint]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[urlTextField]-(21)-[loadButton]-(8)-|" options:0 metrics:nil views:views]];
}


- (void)didPressEnter:(id)sender
{
    if (self.delegate && [self validateUrl:self.urlTextField.stringValue])
    {
        [self.delegate urlBar:self didRequestURL:[NSURL URLWithString:self.urlTextField.stringValue]];
        
        double delayInSeconds = .0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSText *fieldEditor = [self.urlTextField.window fieldEditor:YES forObject:self.urlTextField];
            fieldEditor.selectedRange = NSMakeRange(0, 0);
            [self.urlTextField.window makeFirstResponder:nil];
        });
    }
}


- (BOOL)validateUrl:(NSString *)candidate
{
    if ([self.delegate respondsToSelector:@selector(urlBar:isValidRequestStringValue:)])
    {
        return [self.delegate urlBar:self isValidRequestStringValue:candidate];
    }
    else
    {
        NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        return [urlTest evaluateWithObject:candidate];
    }
}


- (CGFloat)barWidthForProtocol
{
    NSString *measureString = [self.urlTextField.stringValue substringToIndex:[self.urlTextField.stringValue rangeOfString:@"://"].location + 3];
    return [measureString sizeWithAttributes:@{NSFontAttributeName:self.urlTextField.font}].width + 8.0f;
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
        case KFProgressPhasePending:
            color4 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 0.243 alpha: 0.395];
            color5 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 0.774 alpha: 0];
            break;
        case KFProgressPhaseDownloading:
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
    CGFloat barEnd = NSMaxX(self.urlTextField.frame);
    
    
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
    NSBezierPath* addressBarBackgroundPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10) xRadius: 10 yRadius: 10];
    [fillColor setFill];
    [addressBarBackgroundPath fill];
    [color setStroke];
    [addressBarBackgroundPath setLineWidth: 1];
    [addressBarBackgroundPath stroke];
    
    
    //// AddressBar Progress Drawing
    
    CGFloat barWidth = 0;
    switch (self.progressPhase)
    {
        case KFProgressPhaseNone:
            barWidth = 0;
            break;
        case KFProgressPhasePending:
            barWidth = [self barWidthForProtocol];
            break;
        default:
            barWidth = MAX(barEnd * self.progress, 57);
            break;
    }
    
    if (barWidth > 0)
    {
        CGFloat addressBarProgressCornerRadius = 10;
        NSRect addressBarProgressRect = NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barWidth, NSHeight(frame) - 10);
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
    
    
    NSBezierPath* addressBarPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10) xRadius: 10 yRadius: 10];
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
        if (_progressPhase == KFProgressPhaseDownloading && progressPhase == KFProgressPhaseNone)
        {
            _progress = 1.0f;
            [self setNeedsDisplay:YES];
            double delayInSeconds = .2f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
            {
                _progress = 0;
                _progressPhase = progressPhase;
                [self setNeedsDisplay:YES];
            });
        }
        else
        {
            _progressPhase = progressPhase;
            [self setNeedsDisplay:YES];
        }
    }
}


- (NSString *)addressString
{
    return self.urlTextField.stringValue;
}


- (void)setAddressString:(NSString *)addressString
{
    self.urlTextField.stringValue = addressString;
}


@end
