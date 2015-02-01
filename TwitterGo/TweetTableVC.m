//
//  TweetTableVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "TweetTableVC.h"
#import "TweetModel.h"
#import "Tweet.h"
#import "PopularTableViewCell.h"
#import "RecentTableViewCell.h"
#import "MixedTableViewCell.h"

@interface TweetTableVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *currentTrend;
@property (strong, nonatomic) TweetModel* tweetModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString* type;

@end

@implementation TweetTableVC

@synthesize type = _type;

-(TweetModel*) tweetModel {
    if(!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

-(NSString*) type {
    if(!_type)
        _type = @"popular";
    
    return _type;
}

-(void) setType: (NSString*) type {
    _type = type;
    [self getTwitterJSON];
}

- (IBAction)changeResultType:(UISegmentedControl*)sender {
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    if (selectedSegment == 0 ) {
        self.type = @"popular";
    } else if (selectedSegment == 1) {
        self.type = @"recent";
    } else {
        self.type = @"mixed";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    [self.tweetModel.tweets removeAllObjects];
    
    if(self.tweetModel.currentTrend) {
        [self getTwitterJSON];
    } else {
        [self setInitialTrend];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 120.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self checkSettings];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) checkSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults stringForKey:@"tweetLimit"]) {
        [defaults setObject:@"10" forKey:@"tweetLimit"];
    }
    
    if(![defaults integerForKey:@"updatesSpeed"]) {
        [defaults setInteger:60 forKey:@"updatesSpeed"];
    }
    
    if(![defaults integerForKey:@"updatesSwitch"]) {
        [defaults setInteger:1 forKey:@"updatesSwitch"];
    }
}

-(void) getTwitterJSON {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* numberOfTweets = [defaults stringForKey:@"tweetLimit"];
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=%@&count=%@", self.tweetModel.currentTrend.query, self.type, numberOfTweets];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    [self.refreshControl beginRefreshing];
    
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
                    [self.tableView reloadData];
                    self.currentTrend.title = [NSString stringWithFormat:@"%@ ▾", self.tweetModel.currentTrend.name];
                    [self.refreshControl endRefreshing];
                    
                });
                
                
            }] resume];
}

-(void) setInitialTrend {
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=23424977"];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                NSError* otherError;
                NSArray* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                NSDictionary* jsonDict = [json objectAtIndex:0];
                
                NSDictionary* trend = [[jsonDict objectForKey:@"trends"] firstObject];
                NSString* name = [trend objectForKey:@"name"];
                NSString* query = [trend objectForKey:@"query"];
                self.tweetModel.currentTrend = [[Trend alloc] initTrend:name
                                                                  query:query];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getTwitterJSON];
                });
                
                
            }] resume];
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tweetModel.tweets count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.type isEqualToString:@"popular"]) {
        
        PopularTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopularCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*)self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        cell.retweets.text = [NSString stringWithFormat:@"%@", tweet.retweets];
        cell.favorites.text = [NSString stringWithFormat:@"%@", tweet.favorites];
        return cell;
        
    } else if([self.type isEqualToString:@"recent"]) {
        
        RecentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*)self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        cell.date.text = tweet.date;
        return cell;
        
    } else {
        
        MixedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MixedCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*)self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        cell.location.text = tweet.location;
        return cell;
        
    }
}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TrendPicker"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        TrendVC *trendVC = [navigationController viewControllers][0];
        trendVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Settings"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsTableVC *settingsTableVC = [navigationController viewControllers][0];
        settingsTableVC.delegate = self;
    }
}

@end
