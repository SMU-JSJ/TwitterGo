//
//  TrendVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "TrendVC.h"

@interface TrendVC () 
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation TrendVC

- (IBAction)cancel:(id)sender
{
    [self.delegate trendVCDidCancel:self];
}

- (IBAction)done:(id)sender
{
    [self.delegate trendVCDidSave:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
