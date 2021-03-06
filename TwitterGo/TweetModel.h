//  
//  TweetModel.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trend.h"

@interface TweetModel : NSObject

@property (strong, nonatomic) NSMutableArray* tweets;
@property (strong, nonatomic) NSMutableArray* trends;
@property (strong, nonatomic) Trend* currentTrend;

+ (TweetModel*) sharedInstance;

- (void) addAllTweets:(NSDictionary*) json;
- (void) addAllTrends:(NSDictionary*) json;

@end
