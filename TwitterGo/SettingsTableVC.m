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

//If the switch is changed either hide or show the slider.
- (IBAction)updatesSwitchChanged:(UISwitch *)sender {
    self.updatesSpeedCell.hidden = ![sender isOn];
}

//If the stepper is changed update the text next to it with that value.
- (IBAction)stepperChanged:(UIStepper *)sender {
    self.tweetLimit.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

//Closes the view controller if cancel is clicked.
- (IBAction)cancel:(id)sender {
    [self.delegate settingsTableVCDidCancel:self];
}

//Closes the view controller if done is clicked.
//Saves the settings values into the user defaults.
//These values will be saved even after the app is closed.
- (IBAction)done:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.tweetLimit.text forKey:@"tweetLimit"];
    [defaults setInteger:self.updatesSpeed.value forKey:@"updatesSpeed"];
    [defaults setInteger:[self.updatesSwitch isOn] forKey:@"updatesSwitch"];
    
    [self.delegate settingsTableVCDidSave:self];
}

//Called when the view is about to open.
//Sets the default values in the view.
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

//Called when the view loads.
- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
