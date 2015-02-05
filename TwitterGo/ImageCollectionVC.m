//
//  ImagesCollectionVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ImageCollectionVC.h"
#import "TweetModel.h"
#import "Tweet.h"
#import "ImageCollectionViewCell.h"
#import "ImageVC.h"

@interface ImageCollectionVC ()

@property (strong, nonatomic) TweetModel* tweetModel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentTrend;
@property (strong, nonatomic) NSTimer* timer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation ImageCollectionVC

-(TweetModel*) tweetModel {
    if(!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load tweets
    [self setTrendName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Reload tweets if the trend was changed
    [self setTrendName];
    [self createTimer];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.timer invalidate];
}

// Set the trend in the navigation bar
- (void)setTrendName {
    NSString *selectedTrend = [self shortenTrend:self.tweetModel.currentTrend.name];
    
    // Only reload the trend name and tweets if the user has changed the trend
    if (![self.currentTrend.title isEqualToString:selectedTrend]) {
        self.currentTrend.title = selectedTrend;
        // Remove old tweets and show a loading spinner
        [self.tweetModel.tweets removeAllObjects];
        [self.collectionView reloadData];
        [self.indicator startAnimating];
        [self getTwitterJSON];
        [self createTimer];
    }
}

- (NSString*)shortenTrend:(NSString*)trendName {
    if ([trendName length] >= 25) {
        return [NSString stringWithFormat:@"%@... ▾", [trendName substringToIndex:22]];
    }
    
    return [NSString stringWithFormat:@"%@ ▾", trendName];
}

// Download JSON of tweets using the Twitter API
-(void) getTwitterJSON {
    // Get the setting for number of tweets to show
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* numberOfTweets = [defaults stringForKey:@"tweetLimit"];
    
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@%%20filter%%3Aimages&result_type=mixed&count=%@&include_entities=true", self.tweetModel.currentTrend.query, numberOfTweets];
    
    // Add authentication header to the HTTP request
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    
    
    // Send HTTP request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // Convert NSData to JSON
                NSError* otherError;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                // Convert JSON to tweets
                [self.tweetModel addAllTweets:json];
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator stopAnimating];
                    [self.collectionView reloadData];
                });
                
            }] resume];
}

// Stop any existing timer and create a new timer for reloading tweets
- (void) createTimer {
    [self.timer invalidate];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Only create the timer if the user wants tweets to reload
    if([defaults integerForKey:@"updatesSwitch"] == 1) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[defaults integerForKey:@"updatesSpeed"]
                                                      target:self
                                                    selector:@selector(getTwitterJSON)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL isVC = [[segue destinationViewController] isKindOfClass:[ImageVC class]];
    
    if(isVC){
        ImageCollectionViewCell* cell = (ImageCollectionViewCell*) sender;
        ImageVC* vc = [segue destinationViewController];
        
        // Pass the selected object to the new view controller.
        Tweet* tweet = (Tweet*)self.tweetModel.tweets[[self.collectionView indexPathForCell: cell].row];
        vc.imageURL = tweet.imageURL;
    } else if ([segue.identifier isEqualToString:@"TrendPicker"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TrendVC *trendVC = [navigationController viewControllers][0];
        trendVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Settings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsTableVC *settingsTableVC = [navigationController viewControllers][0];
        settingsTableVC.delegate = self;
    }
}

#pragma mark - TrendVCDelegate

- (void)trendVCDidCancel:(TrendVC *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)trendVCDidSave:(TrendVC *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Reload tweets
    [self setTrendName];
}

#pragma mark - SettingsTableVCDelegate

- (void)settingsTableVCDidCancel:(SettingsTableVC *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsTableVCDidSave:(SettingsTableVC *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Reload tweets and reset timer
    [self getTwitterJSON];
    [self createTimer];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tweetModel.tweets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TweetImageCell" forIndexPath:indexPath];
    
    Tweet* tweet = nil;
    
    if ([self.tweetModel.tweets count] > indexPath.row) {
        tweet = (Tweet*)self.tweetModel.tweets[indexPath.row];
        
        NSURL* imageURL = nil;
        if (tweet.imageURL) {
            imageURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@:thumb", tweet.imageURL]];
        }
        cell.imageURL = imageURL;
    }
    
    return cell;
}

@end
