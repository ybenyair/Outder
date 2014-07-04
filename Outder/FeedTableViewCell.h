//
//  FeedTableViewCell.h
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "VideoPlayerViewController.h"

@interface FeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *sharedButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *feedContentView;


- (IBAction)sharedButtonClicked:(id)sender;
- (IBAction)cameraButtonClicked:(id)sender;

- (void) imageClicked;
- (void)configureCell:(Feed *)feedInfo;

@property (nonatomic,strong) Feed* feed;
@property (nonatomic,strong) UIViewController* superCtrl;

@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;


@end
