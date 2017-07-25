//
//  USeekPlayerView.m
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekPlayerView.h"
#import "USeekWebView.h"
#import "USeekUtils.h"

@interface USeekPlayerView () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *viewLoadingMask;
@property (weak, nonatomic) IBOutlet USeekWebView *webView;

@property (assign, atomic) USEEKENUM_VIDEO_LOADSTATUS enumStatus;
@property (assign, atomic) BOOL isLoadingMaskHidden;

@end

@implementation USeekPlayerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void) initialize{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:self.view];
    
    self.enumStatus = USEEKENUM_VIDEO_LOADSTATUS_NONE;
    self.isLoadingMaskHidden = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    USeekPlaybackResultDataModel *result = [USeekUtils parsePlaybackResultWithURLRequest:request];
    if (result != nil){
        if ([self.webView.videoId isEqualToString:result.videoId] == YES &&
            ([self.webView.userId isEqualToString:result.userId] == YES)){
            USEEKLOG(@"USeekWebView didPlaybackFinish");
            if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerView:didPlaybackFinish:WithPoints:)] == YES){
                [self.delegate useekPlayerView:self didPlaybackFinish:result.finished WithPoints:result.points];
            }
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    USEEKLOG(@"USeekWebView didStartLoad");
    if (self.enumStatus == USEEKENUM_VIDEO_LOADSTATUS_NONE){
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewDidStartLoad:)] == YES){
            [self.delegate useekPlayerViewDidStartLoad:self];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerViewDidFinishLoad:)] == YES){
            [self.delegate useekPlayerViewDidFinishLoad:self];
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(useekPlayerView:didFailWithError:)] == YES){
            [self.delegate useekPlayerView:self didFailWithError:error];
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
