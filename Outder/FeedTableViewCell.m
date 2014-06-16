//
//  FeedTableViewCell.m
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedTableViewCell.h"

@implementation FeedTableViewCell

- (void) layoutSubviews{
    
    [super layoutSubviews];
    /*
    self.image.bounds = CGRectMake(6,4,102,65);
    self.image.frame = CGRectMake(6,4,102,65);
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    */
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
