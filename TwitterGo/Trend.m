//
//  Trend.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "Trend.h"

@implementation Trend

-(id) initTrend:(NSString*) name
          query:(NSString*) query
{
    self = [super init];
    
    if(self) {
        self.name = name;
        self.query = query;
    }
    
    return self;
}

@end
