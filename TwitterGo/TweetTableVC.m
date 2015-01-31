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

@property (strong, nonatomic) TweetModel* tweetModel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString* trend;
@property (strong, nonatomic) NSString* type;

@end

@implementation TweetTableVC

@synthesize type = _type;
@synthesize trend = _trend;

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

-(NSString*) trend {
    if(!_trend)
        _trend = @"%23hashtag";
    
    return _trend;
}

-(void) setTrend: (NSString*) trend {
    _trend = trend;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 120.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self getTwitterJSON];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) getTwitterJSON {
    NSNumber* numberOfTweets = @10;
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=%@&count=%@", self.trend, self.type, numberOfTweets];
    
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
                    [self.refreshControl endRefreshing];
                    
                });
                
                
            }] resume];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
