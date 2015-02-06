//  Jordan Kayse, Jessica Yeh, and Story Zanetti
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

@property (weak, nonatomic) IBOutlet UIBarButtonItem* currentTrend;
@property (strong, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSTimer* timer;

@end

@implementation TweetTableVC

@synthesize type = _type;

// Gets an instance of the TweetModel class using lazy instantiation
- (TweetModel*) tweetModel {
    if(!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

// Gets an NSString for type or returns "popular" if type is not set
- (NSString*) type {
    if(!_type)
        _type = @"popular";
    
    return _type;
}

// Receives an NSString and sets type to this parameter
// Calls getTwitterJSON to regenerate the tweet results
- (void) setType:(NSString*) type {
    _type = type;
    [self getTwitterJSON];
}

// When the segmented control is changed, change the type of tweet shown
- (IBAction) changeResultType:(UISegmentedControl*) sender {
    // Get index selected
    NSInteger selectedSegment = sender.selectedSegmentIndex;
    
    // Change type to match
    if (selectedSegment == 0) {
        self.type = @"popular";
    } else if (selectedSegment == 1) {
        self.type = @"recent";
    } else {
        self.type = @"mixed";
    }
}

// When the view did appear
// Get the tweets to appear, set the trend name, and start the timer
- (void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear:YES];
    
    // If there is a current trend in tweetModel, get the tweets for that trend
    // Otherwise, get the initial trend
    if(self.tweetModel.currentTrend) {
        [self getTwitterJSON];
    } else {
        [self setInitialTrend];
    }
    
    // Set the trend name
    [self setTrendName];
    
    // Start the timer to automatically update
    [self createTimer];
}

// When the view will appear
// Invalidate the timer
- (void) viewWillDisappear:(BOOL) animated{
    [self.timer invalidate];
}

// When the view did load
// Sets the table view's row height to automatically resize
- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set the table view's row height to automatic dimensions
    self.tableView.estimatedRowHeight = 120.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Check settings
    [self checkSettings];
}

// Set the trend in the navigation bar
- (void) setTrendName {
    NSString *selectedTrend = [self shortenTrend:self.tweetModel.currentTrend.name];
    
    // Only reload the trend name and tweets if the user has changed the trend,
    // and if it's not null
    // Otherwise, display "Loading..." in the trend selector
    if (![selectedTrend isEqualToString:@"(null) ▾"] &&
        ![self.currentTrend.title isEqualToString:selectedTrend]) {
        self.currentTrend.title = selectedTrend;
        
        // Remove old tweets and show a loading spinner
        [self.tweetModel.tweets removeAllObjects];
        [self.tableView reloadData];
        
        [self getTwitterJSON];
        [self createTimer];
    } else {
        self.currentTrend.title = @"Loading...";
    }
}

// Receives an NSString for a trendName and shortens it to fit on the screens
// Returns shortened version of trendName
- (NSString*) shortenTrend:(NSString*) trendName {
    // If the trend's name is longer than 25 characters, shorten it with a "..."
    // Return shortened result with arrow
    if ([trendName length] >= 25) {
        return [NSString stringWithFormat:@"%@... ▾", [trendName substringToIndex:22]];
    }
    
    // Otherwise, return full name with arrow
    return [NSString stringWithFormat:@"%@ ▾", trendName];
}

// Checks if the defaults for the settings have been sets
// Sets settings to defaults if they have not been set
- (void) checkSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Set default of tweetLimit to 10
    if (![defaults stringForKey:@"tweetLimit"]) {
        [defaults setObject:@"10" forKey:@"tweetLimit"];
    }
    
    // Set default of updatesSpeed to 60 (seconds)
    if (![defaults integerForKey:@"updatesSpeed"]) {
        [defaults setInteger:60 forKey:@"updatesSpeed"];
    }
    
    // Set default of updatesSwitch to 1 (on)
    if (![defaults integerForKey:@"updatesSwitch"]) {
        [defaults setInteger:1 forKey:@"updatesSwitch"];
    }
}

// Download JSON of tweets using the Twitter API
- (void) getTwitterJSON {
    // Get the setting for number of tweets to show
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* numberOfTweets = [defaults stringForKey:@"tweetLimit"];
    
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&result_type=%@&count=%@",
                           self.tweetModel.currentTrend.query, self.type, numberOfTweets];
    
    // Add authentication header to the HTTP request
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    // Send HTTP request
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData* data,
                                NSURLResponse* response,
                                NSError* error) {
                // Convert NSData to JSON
                NSError* otherError;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                // Convert JSON to tweets
                [self.tweetModel addAllTweets:json];
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                    // Set trend title to new current trend
                    self.currentTrend.title = [self shortenTrend:self.tweetModel.currentTrend.name];
                });
                
            }] resume];
}

// Download JSON of trends using the Twitter API and set current trend to first result
- (void) setInitialTrend {
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=23424977"];
    
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
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                NSDictionary* jsonDict = nil;
                
                // If the json received was of class NSArray, set NSDictionary jsonDict to the first object
                // Otherwise, set NSDictionary jsonDict to json (json is already an NSDictionary)
                if ([json isKindOfClass:[NSArray class]]) {
                    jsonDict = [json firstObject];
                } else {
                    jsonDict = json;
                }
                
                // Get the first trend in the list of trends
                NSDictionary* trend = [[jsonDict objectForKey:@"trends"] firstObject];
                
                // Get the name (i.e. #hashtag) and query (i.e. %23hashtag) from the first trend
                NSString* name = [trend objectForKey:@"name"];
                NSString* query = [trend objectForKey:@"query"];
                
                // Set tweetModel's currentTrend to a new Trend object with this information
                self.tweetModel.currentTrend = [[Trend alloc] initTrend:name
                                                                  query:query];
                
                // Update UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Run getTwitterJSON to download tweets for newly set trend
                    [self getTwitterJSON];
                });
                
                
            }] resume];
}


// Stop any existing timer and create a new timer for reloading tweets
- (void) createTimer {
    [self.timer invalidate];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // Only create the timer if the user wants tweets to reload
    if ([defaults integerForKey:@"updatesSwitch"] == 1) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[defaults integerForKey:@"updatesSpeed"]
                                                      target:self
                                                    selector:@selector(getTwitterJSON)
                                                    userInfo:nil
                                                     repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - TrendVCDelegate

- (void) trendVCDidCancel:(TrendVC*) controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) trendVCDidSave:(TrendVC*) controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Reload tweets
    [self setTrendName];
    
}

#pragma mark - SettingsTableVCDelegate

- (void) settingsTableVCDidCancel:(SettingsTableVC*) controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) settingsTableVCDidSave:(SettingsTableVC*) controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView*) tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView:(UITableView*) tableView
  numberOfRowsInSection:(NSInteger) section {
    // Return the number of rows in the section.
    return [self.tweetModel.tweets count];
}

// Set the cells in the table view
- (UITableViewCell*) tableView:(UITableView*) tableView
         cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    // If the type is popular, use the PopularCell layout
    // Otherwise, if the type is recent, use the RecentCell layout
    // Otherwise, use the MixedCell layout
    if ([self.type isEqualToString:@"popular"]) {
        
        PopularTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopularCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*)self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        
        // PopularCell displays number of retweets and number of favorites
        cell.retweets.text = tweet.retweets;
        cell.favorites.text = tweet.favorites;
        
        return cell;
    } else if ([self.type isEqualToString:@"recent"]) {
        RecentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*) self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        
        // RecentCell displays the date of the tweet
        cell.date.text = tweet.date;
        
        return cell;
    } else {
        MixedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MixedCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Tweet* tweet = (Tweet*) self.tweetModel.tweets[indexPath.row];
        cell.author.text = tweet.author;
        cell.message.text = tweet.message;
        [cell.message sizeToFit];
        
        // MixedCell displays the location (if available) of the tweet
        cell.location.text = tweet.location;
        
        return cell;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue *) segue
                 sender:(id) sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TrendPicker"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        TrendVC* trendVC = [navigationController viewControllers][0];
        trendVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Settings"]) {
        UINavigationController* navigationController = segue.destinationViewController;
        SettingsTableVC* settingsTableVC = [navigationController viewControllers][0];
        settingsTableVC.delegate = self;
    }
}

@end
