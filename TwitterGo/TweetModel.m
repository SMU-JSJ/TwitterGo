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

// Instantiates for the shared instance of the Tweet Model class
+ (TweetModel*) sharedInstance {
    static TweetModel* _sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[TweetModel alloc] init];
    });
    
    return _sharedInstance;
}


// Gets the array of tweets or creates an empty array
- (NSMutableArray*) tweets {
    if(!_tweets)
        _tweets = [[NSMutableArray alloc] init];
    
    return _tweets;
}

// Gets the array of trends or creates an empty array
- (NSMutableArray*) trends {
    if (!_trends) {
        _trends = [[NSMutableArray alloc] init];
    }
    return _trends;
}

// Receives a NSNumber and returns an NSString
// With format 1.1M if the number is greater than or equal to 1,000,000
// With format 1000K if the number is greater than or equal to 100,000
// With format 1.1K if the number is greater than or equal to 1,000
// Or with no format change if the number is less than 1,000
- (NSString*) convertNumber:(NSNumber*) count {
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

// Receives an NSDictionary json retrieved from the Twitter JSON to get tweets
// Iterates through json, creates a new Tweet object for each tweet,
// and adds each Tweet to the shared array of tweets
- (void) addAllTweets:(NSDictionary*) json {
    // Remove any Tweets currently stored in tweets
    [self.tweets removeAllObjects];
    
    // Get statuses from the json to iterate through
    NSArray* statuses = [json objectForKey:@"statuses"];
    
    // Iterates through the statues to get each new Tweet
    for (NSDictionary* status in statuses) {
        // Retrieves the author, message, number of retweets, number of favorites, date, and location
        NSString* author = [NSString stringWithFormat: @"@%@",[status valueForKeyPath:@"user.screen_name"]];
        NSString* message = [status objectForKey:@"text"];
        NSNumber* retweets_count = [status objectForKey:@"retweet_count"];
        NSNumber* favorites_count = [status objectForKey:@"favorite_count"];
        NSString* date = [[status objectForKey:@"created_at"] componentsSeparatedByString:@"+"][0];
        NSString* location = [status valueForKeyPath:@"user.location"];
        
        // Retrieves the image URL for this tweet as an NSString and converts it to an NSURL
        NSString* imageURLString = [[[status valueForKeyPath:@"entities.media"] firstObject] objectForKey:@"media_url"];
        
        NSURL* imageURL = nil;
        if (imageURLString) {
            imageURL = [NSURL URLWithString: imageURLString];
        }
        
        
        // Converts the number of retweets and favorites to shortened version (i.e. 1.1K)
        NSString* retweets = [self convertNumber:retweets_count];
        NSString* favorites = [self convertNumber:favorites_count];
        
        // Creates a new Tweet object with this information
        Tweet* tweet = [[Tweet alloc] initTweet:author
                                        message:message
                                       retweets:retweets
                                      favorites:favorites
                                           date:date
                                       location:location
                                       imageURL:imageURL];
        
        // Adds the new Tweet to the array of tweets
        [self.tweets addObject:tweet];
    }
}

// Receives an NSDictionary retrieved from the Twitter JSON to get trends
// Loops through the json, creates a new Trend object for each trend,
// and adds them to the array of trends
- (void) addAllTrends:(NSDictionary*) json {
    // Remove any Trends currently stored in trends
    [self.trends removeAllObjects];
    
    // Get trends from the json to iterate through
    NSArray* trends = [json objectForKey:@"trends"];
    
    // Iterates through the trends to get each new Trend
    for (NSDictionary* trend in trends) {
        // Retrieves the name (i.e. #hashtag) and query (i.e. %23hashtag) of the trend
        NSString* name = [trend objectForKey:@"name"];
        NSString* query = [trend objectForKey:@"query"];
        
        // Creates a new Trend object with this information
        Trend* newTrend = [[Trend alloc] initTrend:name
                                             query:query];
        
        // Adds the new Trend to the array of trends
        [self.trends addObject:newTrend];
    }
}

@end
