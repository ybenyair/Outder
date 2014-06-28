//
//  TemplateCell.m
//  Outder
//
//  Created by Yossi on 6/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TemplateCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TemplateCell
@synthesize template;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
   
}


- (void)configureCell:(Template *)data
{
    template = data;
    
    NSURL *url = [NSURL URLWithString:template.imageURL];
    
    [self.imageView setImageWithURL:url
               placeholderImage:nil
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                          if (image)
                          {
                              self.imageView.alpha = 0.0;
                              [UIView animateWithDuration:1.0
                                               animations:^{
                                                   self.imageView.alpha = 1.0;
                                               }];
                          }
                      }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
