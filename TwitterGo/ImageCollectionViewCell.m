//
//  ImageCollectionViewCell.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* indicator;


@end

@implementation ImageCollectionViewCell

//Sets the imageURL and starts getting the UIImage from it.
- (void) setImageURL:(NSURL*) imageURL {
    _imageURL = imageURL;
    [self startDownloadingImage:_imageURL useThumbnail:YES];
}

//Sends a request to get the image and sets it.
- (void) startDownloadingImage:(NSURL*) imageURL
                  useThumbnail:(BOOL) useThumbnail {
    self.imageView.image = nil;
    
    if (imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        [self.indicator startAnimating];
        
        //Sends an HTTP request.
        NSURLSessionDownloadTask* task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL* location, NSURLResponse* response, NSError* error) {
            if (!error) {
                //Sets the image view if nothing went wrong.
                if ([request.URL isEqual:imageURL]) {
                    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicator stopAnimating];
                        self.imageView.image = image;
                    });
                }
            } else {
                //If the thumbnail didn't work try getting the image without it.
                if (useThumbnail == YES) {
                    NSURL* url = [NSURL URLWithString:[[[imageURL absoluteString] componentsSeparatedByString:@":thumb"] firstObject]];
                    [self startDownloadingImage:url useThumbnail:NO];
                }
            }
        }];
        [task resume];
    } else {
        //If the URL doesn't exist use default image.
        self.imageView.image = [UIImage imageNamed:@"unavailable_text_100px"];
    }
}

@end
