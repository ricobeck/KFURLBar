//
//  AppDelegate.m
//  KFURLBar
//
//  Created by Rico Becker on 3/8/13.
//  Copyright (c) 2013 KF Interactive. All rights reserved.
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
