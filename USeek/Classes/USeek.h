//
//  USeek.h
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USeek : NSObject

@property (strong, nonatomic) NSString *publisherId;

+ (instancetype) sharedInstance;

#pragma mark - Request

- (void) requestPointsWithGameId: (NSString *) gameId UserId: (NSString *) userId Success: (void (^) (int points)) success Failure: (void (^) (NSError *error)) failure;

@end
