//  Jordan
//  TrendVC.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrendVC;

@protocol TrendVCDelegate <NSObject>

- (void)trendVCDidCancel:(TrendVC *) controller;
- (void)trendVCDidSave:(TrendVC *) controller;

@end

@interface TrendVC : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id <TrendVCDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
