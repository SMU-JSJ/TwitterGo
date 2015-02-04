//  Jordan
//  SettingsTableVC.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsTableVC;

@protocol SettingsTableVCDelegate <NSObject>

- (void)settingsTableVCDidCancel:(SettingsTableVC *) controller;
- (void)settingsTableVCDidSave:(SettingsTableVC *) controller;

@end

@interface SettingsTableVC : UITableViewController

@property (nonatomic, weak) id <SettingsTableVCDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
