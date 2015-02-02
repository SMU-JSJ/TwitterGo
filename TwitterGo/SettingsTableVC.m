//
//  SettingsTableVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "SettingsTableVC.h"

@interface SettingsTableVC ()

@property (weak, nonatomic) IBOutlet UILabel *tweetLimit;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UISwitch *updatesSwitch;
@property (weak, nonatomic) IBOutlet UISlider *updatesSpeed;
@property (weak, nonatomic) IBOutlet UITableViewCell *updatesSpeedCell;

@end

@implementation SettingsTableVC

- (IBAction)updatesSwitchChanged:(UISwitch *)sender {
    self.updatesSpeedCell.hidden = ![sender isOn];
}

- (IBAction)stepperChanged:(UIStepper *)sender {
    self.tweetLimit.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate settingsTableVCDidCancel:self];
}

- (IBAction)done:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.tweetLimit.text forKey:@"tweetLimit"];
    [defaults setInteger:self.updatesSpeed.value forKey:@"updatesSpeed"];
    [defaults setInteger:[self.updatesSwitch isOn] forKey:@"updatesSwitch"];
    
    [self.delegate settingsTableVCDidSave:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* numberOfTweets = [defaults stringForKey:@"tweetLimit"];
    NSInteger updatesSpeed = [defaults integerForKey:@"updatesSpeed"];
    NSInteger updatesSwitch = [defaults integerForKey:@"updatesSwitch"];
    
    self.tweetLimit.text = numberOfTweets;
    self.stepper.value = [numberOfTweets integerValue];
    self.updatesSpeed.value = updatesSpeed;
    [self.updatesSwitch setOn:updatesSwitch];
    
    self.updatesSpeedCell.hidden = ![self.updatesSwitch isOn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
