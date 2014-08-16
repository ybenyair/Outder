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
#import "UILabelAligned.h"

typedef enum {
    kFeedUnknown,
    kFeedLoading,
    kFeedProcessing,
    kFeedReady
} eFeedState;

@interface FeedTableViewCell : UITableViewCell
{
    eFeedState state;
}

@property eFeedState state;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabelAligned *title;
@property (weak, nonatomic) IBOutlet UIButton *sharedButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *feedContentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;


- (IBAction)sharedButtonClicked:(id)sender;
- (IBAction)cameraButtonClicked:(id)sender;

- (void) imageClicked;
- (void)configureCell:(Feed *)feedInfo;

@property (nonatomic,strong) Feed* feed;
@property (nonatomic,weak) UIViewController* superCtrl;

@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;


@end
