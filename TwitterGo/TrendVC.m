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

@end

@implementation TrendVC

-(TweetModel*) tweetModel {
    if(!_tweetModel)
        _tweetModel = [TweetModel sharedInstance];
    
    return _tweetModel;
}

-(Trend*) temporaryTrend {
    if(!_temporaryTrend)
        _temporaryTrend = self.tweetModel.currentTrend;
    
    return _temporaryTrend;
}

- (IBAction)cancel:(id)sender {
    [self.delegate trendVCDidCancel:self];
}

- (IBAction)done:(id)sender {
    self.tweetModel.currentTrend = self.temporaryTrend;
    
    [self.delegate trendVCDidSave:self];
}

- (NSMutableArray*) trends {
    if (!_trends) {
        _trends = [[NSMutableArray alloc] init];
    }
    return _trends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.picker.dataSource = self;
    self.picker.delegate = self;
    
    // Do any additional setup after loading the view.
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
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    self.temporaryTrend = self.trends[row];
}

- (void) getTwitterJSON {
    NSString* searchURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/trends/place.json?id=23424977"];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfig setHTTPAdditionalHeaders:@{@"Authorization": @"Bearer AAAAAAAAAAAAAAAAAAAAAFnOdwAAAAAA6iJnaL7VNdt9YwJjQYDokvPZcMA%3DquJXwcdOF4CghCMKFaizk3yKeIdOshMXSL7v5DEnPZxMwdoD6J"}];
    
    [self.indicator startAnimating];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:searchURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                NSError* otherError;
                NSArray* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&otherError];
                
                NSDictionary* jsonDict = [json objectAtIndex:0];
                
                [self.trends removeAllObjects];
                [self addAllTrends:jsonDict];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.picker reloadAllComponents];
                    
                    for(int i = 0; i < [self.trends count]; i++) {
                        Trend* trend = self.trends[i];
                        if([trend.name isEqualToString:self.tweetModel.currentTrend.name]) {
                            [self.picker selectRow:i inComponent:0 animated:NO];
                        }
                    }
                    
                    [self.indicator stopAnimating];
                });
                
                
            }] resume];
}

- (void) addAllTrends:(NSDictionary*) json {
    NSArray* trends = [json objectForKey:@"trends"];
    
    for (NSDictionary* trend in trends) {
        NSString* name = [trend objectForKey:@"name"];
        NSString* query = [trend objectForKey:@"query"];
        
        Trend* newTrend = [[Trend alloc] initTrend:name
                                             query:query];
        
        [self.trends addObject:newTrend];
    }
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
