//
//  ImageVC.m
//  TwitterGo
//
//  Created by ch484-mac7 on 1/31/15.
//  Copyright (c) 2015 SMU. All rights reserved.
//

#import "ImageVC.h"

@interface ImageVC () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation ImageVC

-(void) setImageURL:(NSURL*) imageURL {
    _imageURL = imageURL;
    if(_imageURL){
        [self.indicator startAnimating];
        dispatch_queue_t queue = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
            });
        });
        
    } else {
        self.image = [UIImage imageNamed:@"unavailable_text_100px"];
    }
}

- (void) setScrollView:(UIScrollView *)scrollView{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

-(UIImage *)image{
    return self.imageView.image;
}

- (void) setImage:(UIImage *)image{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.indicator stopAnimating];
}

-(UIImageView*) imageView {
    if(!_imageView)
        _imageView = [[UIImageView alloc] init];
    
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
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
