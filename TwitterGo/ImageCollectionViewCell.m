//
//  ImageCollectionViewCell.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/30/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;


@end

@implementation ImageCollectionViewCell

-(void) setImageURL:(NSURL*) imageURL {
    _imageURL = imageURL;
    [self startDownloadingImage:_imageURL useThumbnail:YES];
}

- (void) startDownloadingImage:(NSURL*)imageURL useThumbnail:(BOOL)useThumbnail {
    self.imageView.image = nil;
    
    if (imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        [self.indicator startAnimating];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:imageURL]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicator stopAnimating];
                        self.imageView.image = image;
                    });
                }
            } else {
                if (useThumbnail == YES) {
                    NSURL *url = [NSURL URLWithString:[[[imageURL absoluteString] componentsSeparatedByString:@":thumb"] firstObject]];
                    [self startDownloadingImage:url useThumbnail:NO];
                }
            }
        }];
        [task resume];
    } else {
        self.imageView.image = [UIImage imageNamed:@"unavailable_text_100px"];
    }
    
//    if(_imageURL){
//        self.imageView.image = nil;
//        
//        [self.indicator startAnimating];
//        dispatch_queue_t queue = dispatch_queue_create("image fetcher", NULL);
//        dispatch_async(queue, ^{
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.imageView.image = image;
//                [self.indicator stopAnimating];
//            });
//        });
//        
//    } else {
//        self.imageView.image = [UIImage imageNamed:@"unavailable_text_100px"];
//    }

}

@end
