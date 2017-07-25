//
//  USeekPlayerView.h
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USeekPlayerView;

@protocol USeekPlayerViewDelegate <NSObject>

@optional

- (void) useekPlayerViewDidStartLoad: (USeekPlayerView *) playerView;
- (void) useekPlayerViewDidFinishLoad: (USeekPlayerView *) playerView;
- (void) useekPlayerView: (USeekPlayerView *) playerView didFailWithError: (NSError *) error;
- (void) useekPlayerView: (USeekPlayerView *) playerView didPlaybackFinish: (BOOL) finished WithPoints: (int) points;

@end

@interface USeekPlayerView : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelLoadingTitle;

- (BOOL) validateConfiguration;
- (void) loadVideoWithVideoId: (NSString *) videoId UserId: (NSString *) userId;

@property (weak, nonatomic) id<USeekPlayerViewDelegate> delegate;

@end
