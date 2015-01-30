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

@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSNumber* retweets;
@property (strong, nonatomic) NSNumber* favorites;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) UIImage* picture;

@end
