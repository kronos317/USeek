//
//  USeekPlayerView.m
//  USeekDemo
//
//  Created by Kronos on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekPlayerView.h"
#import "USeekManager.h"
#import "USeekUtils.h"
#import <WebKit/WebKit.h>

@interface USeekPlayerView () <WKUIDelegate, WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *loadingMaskView;

@property (assign, atomic) USEEKENUM_VIDEO_LOADSTATUS enumStatus;
@property (assign, atomic) BOOL isLoadingMaskHidden;

@property (strong, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSString *userId;

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
    
    [self initializeWebView];
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

- (void)layoutSubviews{
    [super layoutSubviews];
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    USEEKLOG(@"USeekPlayerView didStartLoad");
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
        self.loadingMaskView.hidden = YES;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    USEEKLOG(@"USeekPlayerView didFinishLoad");
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
        self.loadingMaskView.hidden = YES;
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    USEEKLOG(@"USeekPlayerView didFailLoadWithError: %@", error);
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
        self.loadingMaskView.hidden = YES;
    }
}

@end
