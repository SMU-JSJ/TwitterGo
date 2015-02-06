//
//  Tweet.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/29/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

- (id) initTweet:(NSString*) author
        message:(NSString*) message
       retweets:(NSString*) retweets
      favorites:(NSString*) favorites
           date:(NSString*) date
       location:(NSString*) location
       imageURL:(NSURL*) imageURL;

@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSString* retweets;
@property (strong, nonatomic) NSString* favorites;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSURL* imageURL;

@end
