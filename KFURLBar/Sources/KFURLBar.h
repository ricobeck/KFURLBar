//
//  KFURLBarView.h
//  KFJSON
//
//  Created by Rico Becker on 2/15/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
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

@property (nonatomic,strong) NSColor *gradientColorTop;
@property (nonatomic,strong) NSColor *gradientColorBottom;
@property (nonatomic,strong) NSColor *borderColorTop;
@property (nonatomic,strong) NSColor *borderColorBottom;
@property (nonatomic,strong) NSColor *barColorPendingTop;
@property (nonatomic,strong) NSColor *barColorPendingBottom;
@property (nonatomic,strong) NSColor *barColorDownloadingTop;
@property (nonatomic,strong) NSColor *barColorDownloadingBottom;


- (instancetype)initWithDelegate:(id<KFURLBarDelegate>)delegate;


@end
