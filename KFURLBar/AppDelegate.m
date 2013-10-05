//
//  AppDelegate.m
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


#import "AppDelegate.h"
#import "KFURLBar.h"
#import "KFWebKitProgressController.h"

#import <WebKit/WebKit.h>

@interface AppDelegate () <KFURLBarDelegate, NSWindowDelegate, KFWebKitProgressDelegate>


@property (weak) IBOutlet KFURLBar *urlBar;

@property (weak) IBOutlet WebView *webView;


@property (nonatomic) float progress;


@end


@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    
    self.urlBar.delegate = self;
    self.urlBar.addressString = @"https://pods.kf-interactive.com";
    
    NSButton *reloadButton = [[NSButton alloc] init];
    [reloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [reloadButton setBezelStyle:NSInlineBezelStyle];
    [reloadButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
    [reloadButton setTarget:self];
    [reloadButton setAction:@selector(reloadURL:)];
    self.urlBar.leftItems = @[reloadButton];
    
    NSButton *alertButton = [[NSButton alloc] init];
    [alertButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [alertButton setBezelStyle:NSInlineBezelStyle];
    [alertButton setTitle:@"Alert"];
    [alertButton setTarget:self];
    [alertButton setAction:@selector(showAlert:)];
    [[alertButton cell] setBackgroundStyle:NSBackgroundStyleRaised];
    self.urlBar.rightItems = @[alertButton];
}


- (void)reloadURL:(id)sender
{
    [[self.webView mainFrame] reload];
}


- (void)showAlert:(id)sender
{
    NSBeginAlertSheet (@"WebKit Objective-C Programming Guide",
                       @"OK",
                       nil,
                       @"Cancel",
                       [self window],
                       self,
                       nil,
                       nil,
                       nil,
                       @"As the user navigates from page to page in your embedded browser, you may want to display the current URL, load status, and error messages. For example, in a web browser application, you might want to display the current URL in a text field that the user can edit.", nil);
}


- (void)updateProgress
{
    self.urlBar.progressPhase = KFProgressPhaseDownloading;
    self.progress += .005;
    self.urlBar.progress = self.progress;
    if (self.progress < 1.0)
    {
        [self performSelector:@selector(updateProgress) withObject:nil afterDelay:.02f];
    }
    else
    {
        self.urlBar.progressPhase = KFProgressPhaseNone;
    }
}


#pragma mark - KFURLBarDelegate Methods


- (void)urlBar:(KFURLBar *)urlBar didRequestURL:(NSURL *)url
{
    [[self.webView mainFrame] loadRequest:[[NSURLRequest alloc] initWithURL:url]];
    self.urlBar.progressPhase = KFProgressPhasePending;
}


- (BOOL)urlBar:(KFURLBar *)urlBar isValidRequestStringValue:(NSString *)requestString
{
    NSString *urlRegEx = @"(ftp|http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:requestString];
}


#pragma mark - NSWindowDelegate Methods


- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
    rect.origin.y -= NSHeight(self.urlBar.frame);
    return rect;
}


#pragma mark WebKitProgressDelegate Methods


- (void)webKitProgressDidChangeFinishedCount:(NSInteger)finishedCount ofTotalCount:(NSInteger)totalCount
{
    self.urlBar.progressPhase = KFProgressPhaseDownloading;
    self.urlBar.progress = (float)finishedCount / (float)totalCount;
    
    if (totalCount == finishedCount)
    {
        double delayInSeconds = 1.0;
        
         __weak typeof(self) weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
        {
            weakSelf.urlBar.progressPhase = KFProgressPhaseNone;
        });
    }
}





@end
