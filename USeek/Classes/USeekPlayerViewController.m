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

@property (weak, nonatomic) IBOutlet UIView *viewLoadingMask;
@property (weak, nonatomic) IBOutlet USeekWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

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
        USEEKLOG(@"USeek is not properly initiated. Aborting...");
        return;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.buttonClose.hidden = self.isCloseButtonHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utils

- (void) loadVideoWithVideoId: (NSString *) videoId UserId: (NSString *) userId{
    UIView *view = self.view;
    if (view == nil || self.webView == nil){
        USEEKLOG(@"USeek is not properly initiated. Aborting...");
        return;
    }
    
    self.webView.videoId = videoId;
    self.webView.userId = userId;
    if ([self validateConfiguration] == NO) return;
    
    self.webView.delegate = self;
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_NONE;
    self.viewLoadingMask.hidden = YES;
    
    [self.webView loadVideo];
}

- (BOOL) validateConfiguration{
    return [self.webView validateConfiguration];
}

- (void) setCloseButtonHidden: (BOOL) hidden{
    self.isCloseButtonHidden = hidden;
    if (self.buttonClose != nil){
        [self.buttonClose setHidden:hidden];
    }
}

- (void) setLoadingMaskHidden: (BOOL) hidden{
    self.isLoadingMaskHidden = hidden;
    if (self.viewLoadingMask != nil){
        self.viewLoadingMask.hidden = hidden;
    }
}

#pragma mark - UI

- (void) animateLoadingMaskToShow{
    if (self.viewLoadingMask.hidden == NO) return;
    self.viewLoadingMask.hidden = NO;
    self.viewLoadingMask.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.viewLoadingMask.alpha = 1;
        } completion:^(BOOL finished) {
            self.viewLoadingMask.alpha = 1;
        }];
    });
}

- (void) animateLoadingMaskToHide{
    if (self.viewLoadingMask.hidden == YES) return;
    self.viewLoadingMask.hidden = NO;
    self.viewLoadingMask.alpha = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25f animations:^{
            self.viewLoadingMask.alpha = 0;
        } completion:^(BOOL finished) {
            self.viewLoadingMask.alpha = 1;
            self.viewLoadingMask.hidden = YES;
        }];
    });
}

#pragma mark - UIButton Close

- (IBAction)onButtonClose:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewControllerDidClose:)] == YES){
        [self.delegate useekPlayerViewControllerDidClose:self];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    USeekPlaybackResultDataModel *result = [USeekUtils parsePlaybackResultWithURLRequest:request];
    if (result != nil){
        if ([self.webView.videoId isEqualToString:result.videoId] == YES &&
            ([self.webView.userId isEqualToString:result.userId] == YES)){
            USEEKLOG(@"USeekWebView didPlaybackFinish");
            if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewController:didPlaybackFinish:WithPoints:)] == YES){
                [self.delegate useekPlayerViewController:self didPlaybackFinish:result.finished WithPoints:result.points];
            }
        }
    }
    return YES;
}

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
        self.viewLoadingMask.hidden = YES;
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
        self.viewLoadingMask.hidden = YES;
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
        self.viewLoadingMask.hidden = YES;
    }
}

@end
