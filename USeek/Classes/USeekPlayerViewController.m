//
//  USeekPlayerViewController.m
//  USeekDemo
//
//  Created by Kronos on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekPlayerViewController.h"
#import "USeekManager.h"
#import "USeekUtils.h"
#import <WebKit/WebKit.h>

@interface USeekPlayerViewController () <WKUIDelegate, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) WKWebView *webView;

@property (weak, nonatomic) IBOutlet UIView *loadingMaskView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (assign, atomic) USEEKENUM_VIDEO_LOADSTATUS enumStatus;
@property (assign, atomic) BOOL isCloseButtonHidden;
@property (assign, atomic) BOOL isLoadingMaskHidden;

@property (strong, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSString *userId;

@end

@implementation USeekPlayerViewController

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Initialization

- (id) init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.isCloseButtonHidden = NO;
    self.isLoadingMaskHidden = NO;
    
    UIView *view = self.view;
    if (view == nil){
        USEEKLOG(@"USeekPlayerViewController is not properly initiated. Aborting...");
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.closeButton.hidden = self.isCloseButtonHidden;
    
    [self initializeWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.viewContainer.frame.size.width, self.viewContainer.frame.size.height) configuration:config];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    [self.viewContainer addSubview:self.webView];
}

#pragma mark - Utils

- (void) loadVideoWithGameId: (NSString *) gameId UserId: (NSString *) userId{
    UIView *view = self.view;
    if (view == nil || self.webView == nil){
        USEEKLOG(@"USeekPlayerViewController is not properly initiated. Aborting...");
        return;
    }
    
    self.gameId = gameId;
    self.userId = userId;
    if ([self validateConfiguration] == NO) return;
    
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_NONE;
    self.loadingMaskView.hidden = YES;
    
    NSURL *url = [self generateVideoUrl];
    if (url == nil){
        USEEKLOG(@"Useek Configuration Invalid:\n %@", self);
        return;
    }
    
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadRequest:urlReq];
}

- (BOOL) validateConfiguration{
    NSString *publisherId = [[USeekManager sharedManager] publisherId];
    
    if ([USeekUtils validateString:publisherId] == NO) return NO;
    if ([USeekUtils validateString:self.gameId] == NO) return NO;
    return YES;
}

- (NSURL *) generateVideoUrl{
    if ([self validateConfiguration] == NO) return nil;
    
    NSString *szUrl = [NSString stringWithFormat:@"https://www.useek.com/sdk/1.0/%@/%@/play", [[USeekManager sharedManager] publisherId], self.gameId];
    if ([USeekUtils validateString:self.userId] == YES){
        szUrl = [NSString stringWithFormat:@"%@?external_user_id=%@", szUrl, self.userId];
    }
    
    if ([USeekUtils validateUrl:szUrl] == NO) return nil;
    NSURL *url = [NSURL URLWithString:szUrl];
    return url;
}


- (void) setCloseButtonHidden: (BOOL) hidden{
    self.isCloseButtonHidden = hidden;
    if (self.closeButton != nil){
        [self.closeButton setHidden:hidden];
    }
}

- (void) setLoadingMaskHidden: (BOOL) hidden{
    self.isLoadingMaskHidden = hidden;
    if (self.loadingMaskView != nil){
        self.loadingMaskView.hidden = hidden;
    }
}

#pragma mark - UI

- (void) animateLoadingMaskToShow{
    if (self.loadingMaskView.hidden == NO) return;
    self.loadingMaskView.hidden = NO;
    self.loadingMaskView.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.loadingMaskView.alpha = 1;
        } completion:^(BOOL finished) {
            self.loadingMaskView.alpha = 1;
        }];
    });
}

- (void) animateLoadingMaskToHide{
    if (self.loadingMaskView.hidden == YES) return;
    self.loadingMaskView.hidden = NO;
    self.loadingMaskView.alpha = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.loadingMaskView.alpha = 0;
        } completion:^(BOOL finished) {
            self.loadingMaskView.alpha = 1;
            self.loadingMaskView.hidden = YES;
        }];
    });
}

#pragma mark - UIButton Close

- (IBAction)onCloseButtonClick:(id)sender {
    USEEKLOG(@"USeekPlayerViewController didClose");
    if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewControllerDidClose:)] == YES){
        [self.delegate useekPlayerViewControllerDidClose:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    USEEKLOG(@"USeekPlayerViewController didStartLoad");
    if (self.enumStatus == USEEKENUM_VIDEO_LOADSTATUS_NONE){
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewControllerDidStartLoad:)] == YES){
            [self.delegate useekPlayerViewControllerDidStartLoad:self];
        }
    }
    
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_LOADSTARTED;
    if (self.isLoadingMaskHidden == NO){
        [self animateLoadingMaskToShow];
    }
    else {
        self.loadingMaskView.hidden = YES;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    USEEKLOG(@"USeekPlayerViewController didFinishLoad");
    if (self.enumStatus != USEEKENUM_VIDEO_LOADSTATUS_LOADFAILED && self.enumStatus != USEEKENUM_VIDEO_LOADSTATUS_LOADED){
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewControllerDidFinishLoad:)] == YES){
            [self.delegate useekPlayerViewControllerDidFinishLoad:self];
        }
    }
    
    if (self.enumStatus != USEEKENUM_VIDEO_LOADSTATUS_LOADFAILED){
        self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_LOADED;
    }
    if (self.isLoadingMaskHidden == NO){
        [self animateLoadingMaskToHide];
    }
    else {
        self.loadingMaskView.hidden = YES;
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    USEEKLOG(@"USeekPlayerViewController didFailLoadWithError: %@", error);
    if (self.enumStatus != USEEKENUM_VIDEO_LOADSTATUS_LOADFAILED){
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewController:didFailWithError:)] == YES){
            [self.delegate useekPlayerViewController:self didFailWithError:error];
        }
    }
    
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_LOADFAILED;
    if (self.isLoadingMaskHidden == NO){
        [self animateLoadingMaskToHide];
    }
    else {
        self.loadingMaskView.hidden = YES;
    }
}

@end
