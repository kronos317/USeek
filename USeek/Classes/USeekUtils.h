//
//  USeekUtils.h
//  Pods
//
//  Created by Kronos on 7/20/17.
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

@property (strong, nonatomic) NSString *publisherId;
@property (strong, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *internalUserId;
@property (assign, atomic) BOOL finished;
@property (assign, atomic) int lastPlayPoints;
@property (assign, atomic) int totalPoints;

- (instancetype) initWithDictionary: (NSDictionary *) dictionary;
- (void) setWithDictionary: (NSDictionary *) resultDictionary;

@end

@interface USeekUtils : NSObject

+ (BOOL) validateString: (NSString *) candidate;
+ (NSString *) refineNSString: (NSString *)originalString;
+ (int) refineInt:(id)value DefaultValue: (int) defValue;
+ (BOOL) refineBool:(id)value DefaultValue: (BOOL) defValue;

+ (BOOL) validateUrl: (NSString *) candidate;

+ (void) requestGET: (NSString *) urlString Params: (NSDictionary *) params Success: (void (^) (id responseObject)) success Failure: (void (^) (NSError *error)) failure;
+ (void) requestPOST: (NSString *) urlString Params: (NSDictionary *) params Success: (void (^) (id responseObject)) success Failure: (void (^) (NSError *error)) failure;

@end
