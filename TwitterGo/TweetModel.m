//
//  TweetModel.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "TweetModel.h"
#import "Tweet.h"

@interface TweetModel()


@end

@implementation TweetModel

+ (TweetModel*) sharedInstance {
    static TweetModel * _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[TweetModel alloc] init];
    });
    
    return _sharedInstance;
}


-(NSMutableArray*) tweets{
    if(!_tweets)
        _tweets = [[NSMutableArray alloc] init];
    
    return _tweets;
}

- (void) addAllTweets:(NSDictionary*)json {
    NSArray* statuses = [json objectForKey:@"statuses"];
    for (NSDictionary* status in statuses) {
        NSString* author = [NSString stringWithFormat: @"@%@",[status valueForKeyPath:@"user.screen_name"]];
        NSString* message = [status objectForKey:@"text"];
        NSNumber* retweets = [status objectForKey:@"retweet_count"];
        NSNumber* favorites = [status objectForKey:@"favorite_count"];
        NSString* date = [[status objectForKey:@"created_at"] componentsSeparatedByString:@"+"][0];
        NSString* location = [status valueForKeyPath:@"user.location"];
        NSURL* pictureUrl = [[[status valueForKeyPath:@"entities.media"] firstObject] objectForKey:@"media_url"];
        
        Tweet* tweet = [[Tweet alloc] initTweet:author
                                        message:message
                                       retweets:retweets
                                      favorites:favorites
                                           date:date
                                       location:location
                                     pictureUrl:pictureUrl];
        
        [self.tweets addObject:tweet];
    }
}

@end
