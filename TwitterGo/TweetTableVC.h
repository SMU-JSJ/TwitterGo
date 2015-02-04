//  Story
//  TweetTableVC.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendVC.h"
#import "SettingsTableVC.h"

@interface TweetTableVC : UITableViewController <TrendVCDelegate, SettingsTableVCDelegate>

-(void) getTwitterJSON;

@end
