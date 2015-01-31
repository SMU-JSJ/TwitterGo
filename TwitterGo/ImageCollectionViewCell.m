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
    [self.indicator startAnimating];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
    self.imageView.image = image;
    [self.indicator stopAnimating];
}



@end
