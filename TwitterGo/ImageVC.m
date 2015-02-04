//
//  ImageVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ImageVC.h"

@interface ImageVC () <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation ImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.imageView];
}

// Set the image URL and download the image in another queue
-(void) setImageURL:(NSURL*) imageURL {
    _imageURL = imageURL;
    
    // Only go download the image if there is an image URL
    if (self.imageURL) {
        // Show the loading spinner
        [self.indicator startAnimating];
        
        // Create queue for downloading image
        dispatch_queue_t queue = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
            
            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                
                // Hide the loading spinner
                [self.indicator stopAnimating];
            });
        });
    } else {
        // Image unavailable
        self.image = [UIImage imageNamed:@"unavailable_text_100px"];
    }
}

// Configure scroll view options
- (void) setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

-(UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

-(UIImageView*)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    
    return _imageView;
}

// Allow the image to be zoomed in the scroll view
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
