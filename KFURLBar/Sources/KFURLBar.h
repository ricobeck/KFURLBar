//
//  KFURLBarView.h
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


#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSUInteger, BarProgressPhase)
{
    KFProgressPhaseNone = 0,
    KFProgressPhasePending,
    KFProgressPhaseDownloading
};

@class KFURLBar;


@protocol KFURLBarDelegate <NSObject>


- (void)urlBar:(KFURLBar *)urlBar didRequestURL:(NSURL *)url;


@optional

- (void)urlBarColorConfig;

- (BOOL)urlBar:(KFURLBar *)urlBar isValidRequestStringValue:(NSString *)requestString;


@end


@interface KFURLBar : NSView


@property (nonatomic, weak) id<KFURLBarDelegate> delegate;

@property (nonatomic) double progress;
@property (nonatomic) BarProgressPhase progressPhase;
@property (nonatomic, weak) NSString *addressString;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic,strong) NSColor *gradientColorTop;
@property (nonatomic,strong) NSColor *gradientColorBottom;
@property (nonatomic,strong) NSColor *borderColorTop;
@property (nonatomic,strong) NSColor *borderColorBottom;
@property (nonatomic,strong) NSColor *barColorPendingTop;
@property (nonatomic,strong) NSColor *barColorPendingBottom;
@property (nonatomic,strong) NSColor *barColorDownloadingTop;
@property (nonatomic,strong) NSColor *barColorDownloadingBottom;

@property (nonatomic, strong) NSArray *leftItems;
@property (nonatomic, strong) NSArray *rightItems;


- (instancetype)initWithDelegate:(id<KFURLBarDelegate>)delegate;


@end
