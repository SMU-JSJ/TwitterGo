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


- (NSMutableArray*) tweets {
    if(!_tweets)
        _tweets = [[NSMutableArray alloc] init];
    
    return _tweets;
}

//Gets the array of trends or creates an empty array.
- (NSMutableArray*)trends {
    if (!_trends) {
        _trends = [[NSMutableArray alloc] init];
    }
    return _trends;
}

- (NSString*) convertNumber:(NSNumber*)count {
    if ([count intValue] >= 1000000) {
        return [NSString stringWithFormat:@"%.1fM", [count floatValue]/1000000];
    } else if ([count intValue] >= 100000) {
        return [NSString stringWithFormat:@"%.0fK", [count floatValue]/1000];
    } else if ([count intValue] >= 1000) {
        return [NSString stringWithFormat:@"%.1fK", [count floatValue]/1000];
    } else {
        return [NSString stringWithFormat:@"%@", count];
    }
}

- (void) addAllTweets:(NSDictionary*)json {
    [self.tweets removeAllObjects];
    NSArray* statuses = [json objectForKey:@"statuses"];
    
    for (NSDictionary* status in statuses) {
        NSString* author = [NSString stringWithFormat: @"@%@",[status valueForKeyPath:@"user.screen_name"]];
        NSString* message = [status objectForKey:@"text"];
        NSNumber* retweets_count = [status objectForKey:@"retweet_count"];
        NSNumber* favorites_count = [status objectForKey:@"favorite_count"];
        NSString* date = [[status objectForKey:@"created_at"] componentsSeparatedByString:@"+"][0];
        NSString* location = [status valueForKeyPath:@"user.location"];
        
        NSString* imageURLString = [[[status valueForKeyPath:@"entities.media"] firstObject] objectForKey:@"media_url"];
        
        NSURL* imageURL = nil;
        if (imageURLString) {
            imageURL = [NSURL URLWithString: imageURLString];
        }
        
        NSString* retweets = [self convertNumber:retweets_count];
        NSString* favorites = [self convertNumber:favorites_count];
        
        Tweet* tweet = [[Tweet alloc] initTweet:author
                                        message:message
                                       retweets:retweets
                                      favorites:favorites
                                           date:date
                                       location:location
                                       imageURL:imageURL];
        
        [self.tweets addObject:tweet];
    }
}

//Loops through the json and adds the trends to the array.
- (void) addAllTrends:(NSDictionary*)json {
    [self.trends removeAllObjects];
    NSArray* trends = [json objectForKey:@"trends"];
    
    for (NSDictionary* trend in trends) {
        NSString* name = [trend objectForKey:@"name"];
        NSString* query = [trend objectForKey:@"query"];
        
        Trend* newTrend = [[Trend alloc] initTrend:name
                                             query:query];
        
        [self.trends addObject:newTrend];
    }
}

@end
