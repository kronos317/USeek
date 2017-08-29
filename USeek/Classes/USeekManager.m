//
//  USeek.m
//  USeekDemo
//
//  Created by Chris Lin on 7/19/17.
//  Copyright © 2017 USeek. All rights reserved.
//

#import "USeekManager.h"
#import "USeekUtils.h"

@interface USeekManager ()

@end

@implementation USeekManager

+ (instancetype) sharedInstance{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init{
    if (self = [super init]){
        [self initializeManager];
    }
    return self;
}

- (void) initializeManager{
    self.publisherId = @"";
}

#pragma mark - Request

- (void) requestPointsWithGameId: (NSString *) gameId UserId: (NSString *) userId Success: (void (^) (int points)) success Failure: (void (^) (NSError *error)) failure{
    if ([USeekUtils validateString:self.publisherId] == NO){
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was cancelled due to invalid publisher id.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Operation was cancelled due to invalid publisher id.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried sending valid publisher id?", nil)
                                   };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorBadServerResponse userInfo:userInfo];
        if (failure){
            failure(error);
        }
        return;
    }
    if ([USeekUtils validateString:gameId] == NO){
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was cancelled due to invalid game id.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Operation was cancelled due to invalid game id.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried sending valid game id?", nil)
                                   };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorBadServerResponse userInfo:userInfo];
        if (failure){
            failure(error);
        }
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[USeekUtils refineNSString:self.publisherId] forKey:@"publisherId"];
    [params setObject:[USeekUtils refineNSString:gameId] forKey:@"gameId"];
    if ([USeekUtils validateString:userId] == YES){
        [params setObject:[USeekUtils refineNSString:userId] forKey:@"user_id"];
    }
    else {
        [params setObject:@"" forKey:@"user_id"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.useek.com/sdk/1.0/%@/%@/get_points", self.publisherId, gameId];
    [USeekUtils requestGET:urlString Params:params Success:^(NSDictionary *dict) {
        USeekPlaybackResultDataModel *result = [[USeekPlaybackResultDataModel alloc] initWithDictionary:dict];
        if (success) {
            success(result.points);
        }
    } Failure:^(NSError *error) {
        if (failure){
            failure(error);
        }
    }];
}

@end
