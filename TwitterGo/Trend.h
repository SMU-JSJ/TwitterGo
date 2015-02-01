//
//  Trend.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trend : NSObject

-(id) initTrend:(NSString*) name
          query:(NSString*) query;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* query;

@end
