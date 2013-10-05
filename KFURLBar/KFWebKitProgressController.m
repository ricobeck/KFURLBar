//
//  KFWebKitProgressController.m
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
