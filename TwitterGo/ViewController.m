//
//  ViewController.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/27/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ViewController.h"
#import "TweetModel.h"

@interface ViewController ()

@property (strong, nonatomic) TweetModel* tweetModel;

@end

@implementation ViewController

-(TweetModel*) tweetModel{
    if(!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tweetModel loadAllTweets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
