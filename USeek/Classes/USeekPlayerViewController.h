//
//  USeekPlayerViewController.h
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USeekPlayerViewController;

@protocol USeekPlayerViewControllerDelegate <NSObject>

@optional

- (void) useekPlayerViewControllerDidStartLoad: (USeekPlayerViewController *) playerViewController;
- (void) useekPlayerViewControllerDidFinishLoad: (USeekPlayerViewController *) playerViewController;
- (void) useekPlayerViewController: (USeekPlayerViewController *) playerViewController didFailWithError: (NSError *) error;
- (void) useekPlayerViewControllerDidClose: (USeekPlayerViewController *) playerViewController;
- (void) useekPlayerViewController: (USeekPlayerViewController *) playerViewController didPlaybackFinish: (BOOL) finished WithPoints: (int) points;

@end

@interface USeekPlayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelLoadingTitle;

- (void) setCloseButtonHidden: (BOOL) hidden;
- (BOOL) validateConfiguration;
- (void) loadVideoWithVideoId: (NSString *) videoId UserId: (NSString *) userId;

@property (weak, nonatomic) id<USeekPlayerViewControllerDelegate> delegate;

@end
