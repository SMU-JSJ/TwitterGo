//
//  TrendVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "TrendVC.h"
#import "Trend.h"
#import "TweetModel.h"

@interface TrendVC ()

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSMutableArray* trends;
@property (strong, nonatomic) Trend* temporaryTrend;
@property (strong, nonatomic) TweetModel* tweetModel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *done;

@end

@implementation TrendVC

//Gets an instance of the TweetModel class using lazy instantiation.
- (TweetModel*)tweetModel {
    if (!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

//Gets the trend temporarely set in the view controller.
- (Trend*)temporaryTrend {
    if (!_temporaryTrend)
        _temporaryTrend = self.tweetModel.currentTrend;
    
    return _temporaryTrend;
}

//Closes the view controller if cancel is clicked.
- (IBAction)cancel:(id)sender {
    [self.delegate trendVCDidCancel:self];
}

//Closes the view controller if done is clicked.
//Sets the currentTrend using the temporary one.
- (IBAction)done:(id)sender {
    self.tweetModel.currentTrend = self.temporaryTrend;
    
    [self.delegate trendVCDidSave:self];
}

//Gets the array of trends or creates an empty array.
- (NSMutableArray*)trends {
    if (!_trends) {
        _trends = [[NSMutableArray alloc] init];
    }
    return _trends;
}

//When the view has loaded it sets up the delegate.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    // Gets the current list of trends.
    [self getTwitterJSON];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.trends count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Trend* trend = self.trends[row];
    return trend.name;
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // This method is triggered whenever the user makes a change to the picker selection.
    // Sets the temporaryTrend equal to the selected trend.
    self.temporaryTrend = self.trends[row];
}

//Gets the current trends from Twitter API.
- (void) getTwitterJSON {
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=23424977"];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    [self.indicator startAnimating];
    self.done.enabled = NO;
    
    //Send HTTP request.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                //Converts NSData to json.
                NSError* otherError;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                NSDictionary* jsonDict = nil;
                
                if ([json isKindOfClass:[NSArray class]]) {
                    jsonDict = [json firstObject];
                } else {
                    jsonDict = json;
                }
                
                //Removes all the old trends and adds the new ones.
                [self.trends removeAllObjects];
                [self addAllTrends:jsonDict];
                
                //Reloads the picker
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.picker reloadAllComponents];
                    
                    for (int i = 0; i < [self.trends count]; i++) {
                        Trend* trend = self.trends[i];
                        
                        //Sets the picker to the trend that was previously chosen if it exists.
                        if ([trend.name isEqualToString:self.tweetModel.currentTrend.name]) {
                            [self.picker selectRow:i inComponent:0 animated:NO];
                        }
                    }
                    
                    [self.indicator stopAnimating];
                    self.done.enabled = YES;
                });
                
                
            }] resume];
}

//Loops through the json and adds the trends to the array.
- (void) addAllTrends:(NSDictionary*)json {
    NSArray* trends = [json objectForKey:@"trends"];
    
    for (NSDictionary* trend in trends) {
        NSString* name = [trend objectForKey:@"name"];
        NSString* query = [trend objectForKey:@"query"];
        
        Trend* newTrend = [[Trend alloc] initTrend:name
                                             query:query];
        
        [self.trends addObject:newTrend];
    }
}

@end
