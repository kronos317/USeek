//
//  USeekWebView.m
//  USeekDemo
//
//  Created by Chris Lin on 7/20/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekWebView.h"
#import "USeek.h"
#import "USeekUtils.h"

@implementation USeekWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        self.scrollView.scrollEnabled = NO;
        self.scrollView.bounces = NO;
    }
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"USeek Instance (publisherId = %@, videoId = %@, userId = %@", [[USeek sharedInstance] publisherId], self.videoId, self.userId];
}

- (NSURL *) generateVideoUrl{
    if ([self validateConfiguration] == NO) return nil;
    
    NSString *szUrl = [NSString stringWithFormat:@"https://www.useek.com/sdk/1.0/%@/%@", [[USeek sharedInstance] publisherId], self.videoId];
    if ([USeekUtils validateString:self.userId] == YES){
        szUrl = [NSString stringWithFormat:@"%@?external_user_id=%@", szUrl, self.userId];
    }
    
    if ([USeekUtils validateUrl:szUrl] == NO) return nil;
    NSURL *url = [NSURL URLWithString:szUrl];
    return url;
}

- (BOOL) validateConfiguration{
    NSString *publisherId = [[USeek sharedInstance] publisherId];
    
    if (publisherId == nil || [publisherId isKindOfClass:[NSString class]] == NO || publisherId.length == 0) return NO;
    if (self.videoId == nil || [self.videoId isKindOfClass:[NSString class]] == NO || self.videoId.length == 0) return NO;
    
    return YES;
}

- (void) loadVideo{
    if ([self validateConfiguration] == NO){
        USEEKLOG(@"Useek Configuration Invalid:\n %@", self);
        return;
    }
    
    NSURL *url = [self generateVideoUrl];
    if (url == nil){
        USEEKLOG(@"Useek Configuration Invalid:\n %@", self);
        return;
    }
    
    self.allowsInlineMediaPlayback = YES;
    self.mediaPlaybackRequiresUserAction = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
