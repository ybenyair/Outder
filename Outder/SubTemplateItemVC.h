//
//  SubTemplateItemVC.h
//  Outder
//
//  Created by Yossi on 7/1/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubTemplate.h"

@interface SubTemplateItemVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UIImageView *videoImage;
@property (nonatomic,strong) UILabel *labelTitle;
@property (nonatomic,strong) UILabel *labelTitleDirection;
@property (nonatomic,strong) UIButton *btnMake;
@property (nonatomic,strong) UIButton *btnDirection;
@property (nonatomic,strong) CAShapeLayer *lineLayer;
@property (nonatomic,strong) UITableView *tableDirections;

@property (nonatomic,strong) SubTemplate *subTemplate;

- (void)configureItem: (SubTemplate *)data inView: (UIView *)view;

@end
