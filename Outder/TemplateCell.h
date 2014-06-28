//
//  TemplateCell.h
//  Outder
//
//  Created by Yossi on 6/25/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Template.h"

@interface TemplateCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)configureCell:(Template *)data;

@property (nonatomic,strong) Template* template;

@end
