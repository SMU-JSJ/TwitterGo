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

-(id) initTweet:(NSString*) author
        message:(NSString*) message
       retweets:(NSNumber*) retweets
      favorites:(NSNumber*) favorites
           date:(NSString*) date
       location:(NSString*) location
     pictureUrl:(NSURL*) pictureUrl;

@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSNumber* retweets;
@property (strong, nonatomic) NSNumber* favorites;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSURL* pictureUrl;
@property (strong, nonatomic) UIImage* picture;

@end
