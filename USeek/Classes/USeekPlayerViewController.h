//
//  USeekPlayerViewController.h
//  Pods
//
//  Created by Kronos on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class USeekPlayerViewController;

/**
 *
 * The USeekPlayerViewControllerDelegate protocol provides a mechanism for your application
 * to take action on events that occur in the WKWebView. You can make use of these calls
 * by assigning an object to the USeekPlayerViewController's delegate property directly.
 *
 * The ViewController will auto-rotate to landscap mode when it is open. But this won't work well if "Requires Full Scree" is not checked in plist file in case of iPad.
 *
 */
@protocol USeekPlayerViewControllerDelegate <NSObject>

@optional

/**
 *
 * Called when USeekPlayerViewController starts loading the video.
 *
 * @param playerViewController          The USeekPlayerViewController object which initiated this event.
 *
 */
- (void) useekPlayerViewControllerDidStartLoad: (USeekPlayerViewController *) playerViewController;

/**
 *
 * Called when USeekPlayerViewController finished loading the video.
 *
 * @param playerViewController          The USeekPlayerViewController object which initiated this event.
 *
 */
- (void) useekPlayerViewControllerDidFinishLoad: (USeekPlayerViewController *) playerViewController;

/**
 *
 * Called when USeekPlayerViewController detected an error while loading the video.
 *
 * @param playerViewController          The USeekPlayerViewController object which initiated this event.
 * @param error                         The NSError object with error information.
 *
 */
- (void) useekPlayerViewController: (USeekPlayerViewController *) playerViewController didFailWithError: (NSError *) error;

/**
 *
 * Called when user clicked close button to dismiss the USeekPlayerViewController
 *
 * @param playerViewController          The USeekPlayerView object which initiated this event.
 *
 */
- (void) useekPlayerViewControllerDidClose: (USeekPlayerViewController *) playerViewController;

@end


/**
 *
 * This class inherits UIView, which you can easily drop in storyboard or create anywhere in your code.
 *
 * There are 2 ways to use USeekPlayerView.
 *
 * - Add as a subview programmatically
 *
 *      ```objective-c
 *      USeekPlayerView *playerView = [[USeekPlayerView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
 *      [self.view addSubview:playerView];
 *      ```
 *
 * - Add in storyboard
 *
 * Just change the class name of the view to USeekPlayerView in storyboard.
 * Now you can add the view as IBOutlet and use.
 *
 */
@interface USeekPlayerViewController : UIViewController

/**
 *
 * IBOutlet for the loading label.
 * By using this label, you can customize the loading text, color and fonts.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *loadingTitleLabel;

/**
 *
 * Show / hide close button in USeekPlayerViewController
 *
 * @param hidden        YES to hide the close button, NO to show
 *
 */
- (void) setCloseButtonHidden: (BOOL) hidden;

/**
 *
 * Validates the configuration.
 * If any of publisher id or game id is not set, validation fails.
 *
 */
- (BOOL) validateConfiguration;

/**
 *
 * Starts loading the video in UIWebView instance.
 *
 * - Precondition: Publisher ID should be set.
 *
 * @param gameId      unique game id provided by USeek, not nullable.
 * @param userId      user's unque id registered in USeek, nullable.
 *
 */
- (void) loadVideoWithGameId: (NSString *) gameId UserId: (NSString *) userId;

/**
 *
 * The delegate can be used to handle the events occured while playing video.
 * 
 */
@property (weak, nonatomic) id<USeekPlayerViewControllerDelegate> delegate;

@end
