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

- (instancetype) initWithDictionary: (NSDictionary *) dictionary{
    self = [super init];
    if (self){
        [self setWithDictionary:dictionary];
    }
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"{\rPublisher ID = %@\rVideo ID = %@\rUser ID = %@\rFinished = %@\rPoints = %d\r}",
            self.publisherId,
            self.videoId,
            self.userId,
            ((self.finished) ? @"Yes" : @"No"),
            self.points
            ];
}

- (void) initialize{
    self.publisherId = @"";
    self.userId = @"";
    self.videoId = @"";
    self.finished = NO;
    self.points = 0;
}

- (void) setWithDictionary: (NSDictionary *) resultDictionary{
    [self initialize];
    self.publisherId = [USeekUtils refineNSString:[resultDictionary objectForKey:@"publisherId"]];
    self.videoId = [USeekUtils refineNSString:[resultDictionary objectForKey:@"videoId"]];
    self.userId = [USeekUtils refineNSString:[resultDictionary objectForKey:@"userId"]];
    self.points = [USeekUtils refineInt:[resultDictionary objectForKey:@"lastPlayPoints"] DefaultValue:0];
    self.finished = [USeekUtils refineBool:[resultDictionary objectForKey:@"finished"] DefaultValue:YES];
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

+ (NSString *) refineNSString: (NSString *)originalString{
    NSString *resultString = @"";
    if ((originalString == nil) || ([originalString isKindOfClass:[NSNull class]] == YES)) resultString = @"";
    else resultString = [NSString stringWithFormat:@"%@", originalString];
    return resultString;
}

+ (NSString *) urlEncode: (NSString *) originalString{
    return [originalString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (int) refineInt:(id)value DefaultValue: (int) defValue{
    if (value == nil || [value isKindOfClass:[NSNull class]] == YES) return defValue;
    int v = defValue;
    @try {
        v = [value intValue];
    }
    @catch (NSException *exception) {
    }
    return v;
}

+ (BOOL) refineBool:(id)value DefaultValue: (BOOL) defValue{
    if (value == nil || [value isKindOfClass:[NSNull class]] == YES) return defValue;
    BOOL v = defValue;
    @try {
        v = [value boolValue];
    }
    @catch (NSException *exception) {
    }
    return v;
}

+ (NSString *) getJSONStringRepresentation: (id) object{
    if (object == nil) return @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    NSString *szResult = @"";
    if (!jsonData){
        NSLog(@"Error while serializing customer details into JSON\r\n%@", error.localizedDescription);
    }
    else{
        szResult = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return szResult;
}

+ (NSString *) getURLEncodedQueryStringFromDictionary: (NSDictionary *) params{
    NSMutableArray *queryItems = [[NSMutableArray alloc] init];
    for (NSString *key in params){
        NSString *value = [USeekUtils refineNSString:[params objectForKey:key]];
        NSString *queryPart = [NSString stringWithFormat:@"%@=%@", [USeekUtils urlEncode:key], [USeekUtils urlEncode:value]];
        [queryItems addObject:queryPart];
    }
    return [queryItems componentsJoinedByString:@"&"];
}

+ (id) getObjectFromJSONStringRepresentation: (NSString *) sz{
    NSError *jsonError;
    NSData *objectData = [sz dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (jsonError != nil) return nil;
    return dict;
}

+ (void) requestGET: (NSString *) urlString Params: (NSDictionary *) params Success: (void (^) (NSDictionary * dict)) success Failure: (void (^) (NSError *error)) failure{
    NSString *urlStringWithQueryParams = [NSString stringWithFormat:@"%@?%@", urlString, [USeekUtils getURLEncodedQueryStringFromDictionary:params]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStringWithQueryParams]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            if (success) {
                success([USeekUtils getObjectFromJSONStringRepresentation:requestReply]);
            }
        }
        else {
            if (failure){
                failure(error);
            }
        }
    }] resume];
}

+ (void) requestPOST: (NSString *) urlString Params: (NSDictionary *) params Success: (void (^) (NSDictionary * dict)) success Failure: (void (^) (NSError *error)) failure{
    NSString *postString = [USeekUtils getJSONStringRepresentation:params];
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int) [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error){
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            if (success) {
                success([USeekUtils getObjectFromJSONStringRepresentation:requestReply]);
            }
        }
        else {
            if (failure){
                failure(error);
            }
        }
    }] resume];
}

@end
