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

@property (nonatomic,strong) UIImageView *videoImage;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,strong) UILabel *labelTitleDirection;
@property (nonatomic,strong) UIButton *btnMake;
@property (nonatomic,strong) UIImageView *imgMake;

@property (nonatomic,strong) UIButton *btnDirection;
@property (nonatomic,strong) CAShapeLayer *lineLayer;
@property (nonatomic,strong) UITableView *tableDirections;

@property (nonatomic,strong) SubTemplate *subTemplate;
@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;

@property (nonatomic, weak) id <SubTemplateCellDelegate> delegate;

- (void)configureItem: (SubTemplate *)data inView: (UIView *)view;

@end
