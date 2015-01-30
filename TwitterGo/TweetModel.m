//
//  TweetModel.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "TweetModel.h"

@interface TweetModel()

@property (strong, nonatomic) NSMutableArray* tweets;

@end

@implementation TweetModel

+(TweetModel*) sharedInstance {
    static TweetModel * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[TweetModel alloc] init];
    });
    
    return _sharedInstance;
}

-(void) loadAllTweets {
    NSNumber* numberOfTweets = @10;
    NSString* trend = @"%23firstworldproblems";
    NSString* type = @"popular";
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=%@&count=%@", trend, type, numberOfTweets];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSError* otherError;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                NSLog(@"JSON: %@", json);
                
            }] resume];
}

@end
