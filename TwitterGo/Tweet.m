//
//  Tweet.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

// Constructor
- (id) initTweet:(NSString*) author
        message:(NSString*) message
       retweets:(NSString*) retweets
      favorites:(NSString*) favorites
           date:(NSString*) date
       location:(NSString*) location
       imageURL:(NSURL*) imageURL
{
    self = [super init];
    
    // Set member variables
    if (self) {
        self.author = author;
        self.message = message;
        self.retweets = retweets;
        self.favorites = favorites;
        self.date = date;
        self.location = location;
        self.imageURL = imageURL;
    }
    
    return self;
}

@end
