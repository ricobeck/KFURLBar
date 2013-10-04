//
//  KFWebKitProgressController.m
//  KFURLBar
//
//  Created by rick on 04/10/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
//

#import "KFWebKitProgressController.h"

#import <WebKit/WebKit.h>


@interface KFWebKitProgressController ()


@property (nonatomic) NSInteger resourceCount;

@property (nonatomic) NSInteger resourceFailedCount;

@property (nonatomic) NSInteger resourceCompletedCount;


@end


@implementation KFWebKitProgressController


- (id)init
{
    self = [super init];
    if (self)
    {
        _resourceCount = 0;
        _resourceCompletedCount = 0;
        _resourceFailedCount = 0;
    }
    return self;
}


- (void)updateResourceStatus
{
    if ([self.delegate respondsToSelector:@selector(webKitProgressDidChangeFinishedCount:ofTotalCount:)])
    {
        [self.delegate webKitProgressDidChangeFinishedCount:(self.resourceCompletedCount + self.resourceFailedCount) ofTotalCount:self.resourceCount];
    }
    else
    {
        NSLog(@"progress: %lu of %lu", (self.resourceCompletedCount + self.resourceFailedCount), self.resourceCount);
    }
}


- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        [[sender window] setTitle:title];
    }
}


- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
    return @(self.resourceCount++);
}


-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    [self updateResourceStatus];
    return request;
}


-(void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
    self.resourceFailedCount++;
    [self updateResourceStatus];
}


-(void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    self.resourceCompletedCount++;
    [self updateResourceStatus];
}

@end
