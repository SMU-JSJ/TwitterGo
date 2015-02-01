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

+(TweetModel*) sharedInstance;

@property (strong, nonatomic) Trend* currentTrend;

-(void) addAllTweets:(NSDictionary*)json;

@end
