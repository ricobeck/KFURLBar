//
//  KFURLBarView.m
//  KFURLBar
//
//  Copyright (c) 2013 Rico Becker, KF Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "KFURLBar.h"
#import "KFURLFormatter.h"

#define kKFURLBarGradientColorTop [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0f]
#define kKFURLBarGradientColorBottom [NSColor colorWithCalibratedRed:0.700f green:0.700f blue:0.700f alpha:1.0f]

#define kKFURLBarBorderColorTop [NSColor colorWithDeviceWhite:0.6 alpha:1.0f]
#define kKFURLBarBorderColorBottom [NSColor colorWithDeviceWhite:0.2 alpha:1.0f]


@interface KFURLBar ()

@property (nonatomic) BOOL drawBackground;
@property (nonatomic, strong) NSColor *currentBarColorTop;
@property (nonatomic, strong) NSColor *currentBarColorBottom;
@property (nonatomic, strong) NSTextField *urlTextField;
@property (nonatomic, strong) NSButton *loadButton;
@property (nonatomic, strong) NSArray *fieldConstraints;


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


- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
    self.drawBackground = ![newSuperview.className isEqualToString:@"NSToolbarFullScreenContentView"];
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
    _cornerRadius = 2.5f;
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
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.urlTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]]];
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.loadButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]]];
    
    [self updateFieldConstraints];
}


- (void)updateFieldConstraints
{
    NSView *urlTextField = self.urlTextField;
    NSView *loadButton = self.loadButton;
    NSDictionary *views = NSDictionaryOfVariableBindings(urlTextField, loadButton);
    
    NSMutableDictionary *allViews = [views mutableCopy];
    
    NSUInteger leftItemsCount = self.leftItems == nil ? 0 : [self.leftItems count];
    if (leftItemsCount > 0)
    {
        [allViews addEntriesFromDictionary:[self viewsFromArray:self.leftItems withBaseName:@"leftItem"]];
    }
    NSUInteger rightItemsCount = self.rightItems == nil ? 0 : [self.rightItems count];
    if (rightItemsCount > 0)
    {
        [allViews addEntriesFromDictionary:[self viewsFromArray:self.rightItems withBaseName:@"rightItem"]];
    }
    views = [allViews copy];
    
    NSString *leftItemsVisualFormat = [self visualFormatFromArray:self.leftItems withBaseName:@"leftItem"];
    NSString *rightItemsVisualFormat = [self visualFormatFromArray:self.rightItems withBaseName:@"rightItem"];
    
    
    if (self.fieldConstraints != nil)
    {
        [self removeConstraints:self.fieldConstraints];
    }

    NSString *visualFormat = [NSString stringWithFormat:@"|-(12)%@[urlTextField]%@(20)-[loadButton]-(8)-|", leftItemsVisualFormat, rightItemsVisualFormat];
    
    self.fieldConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:nil views:views];
    [self addConstraints:self.fieldConstraints];
    
    [self setNeedsDisplay:YES];
}


- (NSDictionary *)viewsFromArray:(NSArray *)views withBaseName:(NSString *)baseName
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSUInteger count = 0;
    for (NSView *view in views)
    {
        NSString *key = [NSString stringWithFormat:@"%@%lu", baseName, count];
        result[key] = view;
        count++;
    }
    return [result copy];
}


- (NSString *)visualFormatFromArray:(NSArray *)views withBaseName:(NSString *)baseName
{
    NSMutableArray *items = [NSMutableArray new];
    NSUInteger count = 0;
    for (NSView *view in views)
    {
        NSString *name = [NSString stringWithFormat:@"[%@%lu]", baseName, count];
        [items addObject:name];
        count++;
    }
    
    NSString *result = [items componentsJoinedByString:@"-"];
    if ([result length] > 0)
    {
        result = [NSString stringWithFormat:@"-%@-", result];
    }
    else
    {
        result = @"-";
    }
    return result;
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
    return YES;
}


- (CGFloat)barWidthForProtocol
{
    NSInteger protocolIndex = [self.urlTextField.stringValue rangeOfString:@"://"].location;
    if (protocolIndex == NSNotFound)
    {
        return 0;
    }
    
    NSString *measureString = [self.urlTextField.stringValue substringToIndex:protocolIndex + 3];
    CGFloat measuredSize = [measureString sizeWithAttributes:@{NSFontAttributeName:self.urlTextField.font}].width;
    
    return NSMinX([self.urlTextField frame]) + measuredSize;
}


- (void)drawRect:(NSRect)dirtyRect
{
    //// Color Declarations
    NSColor* fillColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.2];
    NSColor* color = [NSColor colorWithCalibratedRed: 0.57 green: 0.57 blue: 0.57 alpha: 1];
    
    NSColor *color4;
    NSColor *color5;
    
    switch (self.progressPhase)
    {
        case KFProgressPhasePending:
            color4 = [NSColor colorWithCalibratedWhite:.8f alpha:.8f];
            color5 = [NSColor colorWithCalibratedWhite:.8f alpha:.4f];
            break;
        case KFProgressPhaseDownloading:
            color4 = [NSColor colorForControlTint:[NSColor currentControlTint]];
            color5 = [[NSColor colorForControlTint:[NSColor currentControlTint]] colorWithAlphaComponent:.6f];
            color = [NSColor colorWithCalibratedRed: 0.45 green: 0.45 blue: 0.45 alpha: 1];
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
    
    if ([self.rightItems count] > 0)
    {
        barEnd = NSMaxX([[self.rightItems lastObject] frame]) - 4;
    }
    
    
    if (self.drawBackground)
    {
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
    }
    
    if (self.borderColorBottom)
    {
        [self.borderColorBottom setStroke];
        
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds)) toPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    }
    
    
    //// AddressBar Background Drawing
    NSBezierPath* addressBarBackgroundPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10) xRadius: self.cornerRadius yRadius: self.cornerRadius];
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
            barWidth = MAX(barEnd * self.progress, [self barWidthForProtocol]);
            break;
    }
    
    if (barWidth > 0)
    {
        CGFloat addressBarProgressCornerRadius = self.cornerRadius;
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
    
    
    NSBezierPath* addressBarPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10) xRadius: self.cornerRadius yRadius: self.cornerRadius];
    [color6 setFill];
    [addressBarPath fill];
    
    if (!addressBarPath.isEmpty)
    {
        ////// AddressBar Inner Shadow
        NSRect addressBarBorderRect = NSInsetRect([addressBarPath bounds], -shadow.shadowBlurRadius, -shadow.shadowBlurRadius);
        addressBarBorderRect = NSOffsetRect(addressBarBorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
        addressBarBorderRect = NSInsetRect(NSUnionRect(addressBarBorderRect, [addressBarPath bounds]), -1, -3);
        
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
            [[NSColor lightGrayColor] setFill];
            [addressBarPath addClip];
            NSAffineTransform* transform = [NSAffineTransform transform];
            [transform translateXBy: -round(addressBarBorderRect.size.width) yBy: 0];
            [[transform transformBezierPath: addressBarNegativePath] fill];
        }
        [NSGraphicsContext restoreGraphicsState];
    }
    
    [color setStroke];
    [addressBarPath setLineWidth: .5f];
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
    if (addressString) self.urlTextField.stringValue = addressString;
}


- (void)setLeftItems:(NSArray *)leftItems
{
    if (_leftItems != nil)
    {
        for (NSView *view in _leftItems)
        {
            if ([[view superview] isEqualTo:self])
            {
                [view removeFromSuperview];
            }
        }
    }
    _leftItems = leftItems;
    
    for (NSView *view in _leftItems)
    {
        [self addSubview:view];
         [self addConstraints:@[[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]]];
    }
    
    [self updateFieldConstraints];
}


- (void)setRightItems:(NSArray *)rightItems
{
    if (_rightItems != nil)
    {
        for (NSView *view in _rightItems)
        {
            if ([[view superview] isEqualTo:self])
            {
                [view removeFromSuperview];
            }
        }
    }
    _rightItems = rightItems;
    
    for (NSView *view in _rightItems)
    {
        [self addSubview:view];
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]]];
    }
    
    [self updateFieldConstraints];
}


@end
