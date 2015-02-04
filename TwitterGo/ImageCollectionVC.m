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

-(void) getTwitterJSON {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* numberOfTweets = [defaults stringForKey:@"tweetLimit"];
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@%%20filter%%3Aimages&result_type=mixed&count=%@&include_entities=true", self.tweetModel.currentTrend.query, numberOfTweets];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    [self.tweetModel.tweets removeAllObjects];
    [self.collectionView reloadData];
    [self.indicator startAnimating];
    [self.collectionView setUserInteractionEnabled:NO];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSError* otherError;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                [self.tweetModel.tweets removeAllObjects];
                [self.tweetModel addAllTweets:json];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator stopAnimating];
                    [self.collectionView reloadData];
                    [self.collectionView setUserInteractionEnabled:YES];
                    self.currentTrend.title = [NSString stringWithFormat:@"%@ ▾", self.tweetModel.currentTrend.name];
                });
                
                
            }] resume];
}

static NSString * const reuseIdentifier = @"TweetImageCell";

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self getTwitterJSON];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(self.timer) {
        [self.timer invalidate];
    }
    
    if([defaults integerForKey:@"updatesSwitch"] == 1) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[defaults integerForKey:@"updatesSpeed"]
                                                      target:self
                                                    selector:@selector(getTwitterJSON)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)trendVCDidCancel:(TrendVC *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)trendVCDidSave:(TrendVC *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.currentTrend.title = [NSString stringWithFormat:@"%@ ▾", self.tweetModel.currentTrend.name];
    [self getTwitterJSON];
}

#pragma mark - SettingsTableVCDelegate

- (void)settingsTableVCDidCancel:(SettingsTableVC *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsTableVCDidSave:(SettingsTableVC *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self getTwitterJSON];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tweetModel.tweets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
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

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
