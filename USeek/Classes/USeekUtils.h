//
//  USeekUtils.h
//  USeekDemo
//
//  Created by Chris Lin on 7/20/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USEEKLOG( s, ... ) NSLog( @"%s: %@ l=>%d", __FUNCTION__, [NSString stringWithFormat:(s), ##__VA_ARGS__], __LINE__ )

typedef enum _ENUM_VIDEOLOADSTATUS{
    USEEKENUM_VIDEO_LOADSTATUS_NONE,
    USEEKENUM_VIDEO_LOADSTATUS_LOADSTARTED,
    USEEKENUM_VIDEO_LOADSTATUS_LOADED,
    USEEKENUM_VIDEO_LOADSTATUS_LOADFAILED,
}USEEKENUM_VIDEO_LOADSTATUS;

@interface USeekPlaybackResultDataModel : NSObject

@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSString *userId;
@property (assign, atomic) BOOL finished;
@property (assign, atomic) int points;

@end

@interface USeekUtils : NSObject

+ (BOOL) validateString: (NSString *) candidate;
+ (BOOL) validateUrl: (NSString *) candidate;
+ (USeekPlaybackResultDataModel *) parsePlaybackResultWithURLRequest: (NSURLRequest *) request;

@end
