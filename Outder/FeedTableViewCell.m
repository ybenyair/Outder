//
//  FeedTableViewCell.m
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation FeedTableViewCell

@synthesize feed;

- (void) layoutSubviews{
    
    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
    
    [self.image setUserInteractionEnabled:YES];
    [self.image setHighlighted:YES];
    [self.sharedButton setShowsTouchWhenHighlighted:YES];
    [self.cameraButton setShowsTouchWhenHighlighted:YES];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) imageClicked {
    [self.image.layer setOpacity:0.6];
    [self.image.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.image.layer setOpacity:1.0];
                     }];

}


- (IBAction)sharedButtonClicked:(id)sender {
    NSLog(@"shared clicked");
}

- (IBAction)cameraButtonClicked:(id)sender {
    NSLog(@"camera clicked");
}

@end
