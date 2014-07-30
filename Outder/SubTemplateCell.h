//
//  SubTemplateItemVC.h
//  Outder
//
//  Created by Yossi on 7/1/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubTemplate.h"
#import "VideoPlayerViewController.h"

@protocol SubTemplateCellDelegate
- (void)makeOneClicked:(SubTemplate *)subTemplate;
@end

@interface SubTemplateCell : UIViewController <UITableViewDelegate, UITableViewDataSource>

+ (SubTemplateCell *) loadInstance;

@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMake;
@property (weak, nonatomic) IBOutlet UITableView *tableDirections;
@property (weak, nonatomic) IBOutlet UIButton *btnHideDirections;
@property (weak, nonatomic) IBOutlet UIButton *btnShowDirections;
@property (weak, nonatomic) IBOutlet UILabel *labelMakePlace;
@property (weak, nonatomic) IBOutlet UILabel *lableInstructionNum;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;

- (IBAction)btnHideDirectionsClicked:(id)sender;
- (IBAction)btnShowDirectionsClicked:(id)sender;
- (IBAction)btnMakeOneClicked:(id)sender;
- (IBAction)btnMuteClicked:(id)sender;

@property (nonatomic,strong) SubTemplate *subTemplate;
@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;

@property (nonatomic, weak) id <SubTemplateCellDelegate> delegate;

- (void)configureItem: (SubTemplate *)data inView: (UIView *)view;
- (void)currentlyPresented;

@end
