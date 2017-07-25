//
//  USeekWebView.h
//  USeekDemo
//
//  Created by Chris Lin on 7/20/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USeekWebView : UIWebView

@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSString *userId;

- (BOOL) validateConfiguration;
- (void) loadVideo;

@end
