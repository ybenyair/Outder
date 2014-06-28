//
//  TemplatePromotedView.m
//  Outder
//
//  Created by Yossi on 6/26/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TemplatePromotedView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TemplatePromotedView ()

@end

@implementation TemplatePromotedView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(NSString *)imageURL
{
    NSURL *url = [NSURL URLWithString:imageURL];
    
    [self.imageView setImageWithURL:url
                           placeholderImage:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      if (image)
                                      {
                                          self.imageView.alpha = 0.0;
                                          [UIView animateWithDuration:0.5
                                                           animations:^{
                                                               self.imageView.alpha = 1.0;
                                                           }];
                                      }
                                  }];
    
}

@end
