//
//  USeekWebView.m
//  USeekDemo
//
//  Created by Chris Lin on 7/20/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekWebView.h"
#import "USeekManager.h"
#import "USeekUtils.h"

@interface USeekWebView ()

@end

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
    return [NSString stringWithFormat:@"USeek Instance (publisherId = %@, gameId = %@, userId = %@", [[USeekManager sharedManager] publisherId], self.gameId, self.userId];
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

- (BOOL) validateConfiguration{
    NSString *publisherId = [[USeekManager sharedManager] publisherId];
    
    if ([USeekUtils validateString:publisherId] == NO) return NO;
    if ([USeekUtils validateString:self.gameId] == NO) return NO;
    
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
