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
    if(_imageURL){
        [self.indicator startAnimating];
        dispatch_queue_t queue = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                [self.indicator stopAnimating];
            });
        });
        
    } else {
        self.imageView.image = [UIImage imageNamed:@"unavailable_text_100px"];
    }
}



@end
