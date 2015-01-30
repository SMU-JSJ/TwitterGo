//
//  TweetModel.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetModel : NSObject

+(TweetModel*) sharedInstance;

-(void) loadAllTweets;

@end
