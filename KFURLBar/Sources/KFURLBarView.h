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
    BarProgressPhasePending,
    BarProgressPhaseDownloading
};


@protocol KFURLBarDelegate <NSObject>



@optional
- (void)urlBarColorConfig;


@end


@interface KFURLBarView : NSView


@property (nonatomic, weak) id<KFURLBarDelegate> delegate;

@property (nonatomic) double progress;
@property (nonatomic) BarProgressPhase progressPhase;

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
