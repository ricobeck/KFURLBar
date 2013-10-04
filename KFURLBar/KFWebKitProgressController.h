//
//  KFWebKitProgressController.h
//  KFURLBar
//
//  Created by rick on 04/10/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol KFWebKitProgressDelegate <NSObject>

- (void)webKitProgressDidChangeFinishedCount:(NSInteger)finishedCount ofTotalCount:(NSInteger)totalCount;

@end

@interface KFWebKitProgressController : NSObject


@property (nonatomic, weak) IBOutlet id<KFWebKitProgressDelegate> delegate;


@end
