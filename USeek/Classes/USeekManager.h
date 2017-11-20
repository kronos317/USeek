//
//  USeek.h
//  Pods
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *
 * This singleton class provides the following features
 *
 *  - Set / Retrieve publisher ID
 *  - Request server for the points of certain user based on game id
 *
 */
@interface USeekManager : NSObject

/**
 *
 * Mutable property to set / get publisher id.
 *
 * - Warning: You should set publisher id before loading video.
 *
 * - - -
 *
 * You can set publisher id in AppDelegate like this.
 *
 *      ```objective-c
 *      [[USeekManager sharedManager] setPublisherId: @"publisher id"];
 *      ```
 *
 */
@property (strong, nonatomic) NSString *publisherId;

/**
 * Returns USeekManager singleton object.
 */
+ (instancetype) sharedManager;

#pragma mark - Request

/**
 *
 * Queries the points user has gained while playing the game.
 * The centralized server will return user's points based on gameId and userId.
 *
 * - Precondition: Publisher ID should be set.
 *
 * @param userId      user's unique id registered in USeek
 * @param gameId      unique game id provided by USeek
 * @param success     block which will be triggered after response is successfully retrieved
 * @param failure     block which will be triggered when there is an error detected
 *
 */
- (void) requestPointsWithGameId: (NSString *) gameId UserId: (NSString *) userId Success: (void (^) (int lastPlayPoints, int totalPoints)) success Failure: (void (^) (NSError *error)) failure;

@end
