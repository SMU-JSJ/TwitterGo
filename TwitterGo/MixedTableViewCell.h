//
//  MixedTableViewCell.h
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* author;
@property (weak, nonatomic) IBOutlet UILabel* message;
@property (weak, nonatomic) IBOutlet UILabel* location;

@end
