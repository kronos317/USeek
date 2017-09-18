//
//  USeekPlayerViewController.m
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekPlayerViewController.h"
#import "USeekWebView.h"
#import "USeekUtils.h"

@interface USeekPlayerViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loadingMaskView;
@property (weak, nonatomic) IBOutlet USeekWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (assign, atomic) USEEKENUM_VIDEO_LOADSTATUS enumStatus;
@property (assign, atomic) BOOL isCloseButtonHidden;
@property (assign, atomic) BOOL isLoadingMaskHidden;

@end

@implementation USeekPlayerViewController

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
    if (view == nil || self.webView == nil){
        USEEKLOG(@"USeekPlayerViewController is not properly initiated. Aborting...");
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.closeButton.hidden = self.isCloseButtonHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utils

- (void) loadVideoWithGameId: (NSString *) gameId UserId: (NSString *) userId{
    UIView *view = self.view;
    if (view == nil || self.webView == nil){
        USEEKLOG(@"USeekPlayerViewController is not properly initiated. Aborting...");
        return;
    }
    
    self.webView.gameId = gameId;
    self.webView.userId = userId;
    if ([self validateConfiguration] == NO) return;
    
    self.webView.delegate = self;
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_NONE;
    self.loadingMaskView.hidden = YES;
    
    [self.webView loadVideo];
}

- (BOOL) validateConfiguration{
    return [self.webView validateConfiguration];
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

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView{
    USEEKLOG(@"USeekWebView didStartLoad");
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

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    USEEKLOG(@"USeekWebView didFinishLoad");
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    USEEKLOG(@"USeekWebView didFailLoadWithError: %@", error);
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
