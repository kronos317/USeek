//
//  USeekUtils.m
//  USeekDemo
//
//  Created by Chris Lin on 7/20/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekUtils.h"

@implementation USeekPlaybackResultDataModel

- (instancetype) init{
    self = [super init];
    if (self){
        [self initialize];
    }
    return self;
}

- (void) initialize{
    self.userId = @"";
    self.videoId = @"";
    self.finished = NO;
    self.points = 0;
}

@end

@implementation USeekUtils

+ (BOOL) validateString: (NSString *) candidate {
    if (candidate == nil || [candidate isKindOfClass:[NSString class]] == NO || candidate.length == 0) return NO;
    return YES;
}

+ (BOOL) validateUrl: (NSString *) candidate {
    NSURL *candidateURL = [NSURL URLWithString:candidate];
    return candidateURL && candidateURL.scheme && candidateURL.host;
}

+ (USeekPlaybackResultDataModel *) parsePlaybackResultWithURLRequest: (NSURLRequest *) request{
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString rangeOfString:@"#callback"].location != NSNotFound){
        // #callback?video_id={_video_id}&user_id={_user_id}&finished={YES/NO}&points={_points}
        USeekPlaybackResultDataModel *result = [[USeekPlaybackResultDataModel alloc] init];
        return result;
    }
    return nil;
}

@end
