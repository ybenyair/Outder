//
//  SubTemplateViewController.h
//  Outder
//
//  Created by Yossi on 6/30/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "TitleNavBarVC.h"
#import "SubTemplateCell.h"

@interface SubTemplatesVC : TitleNavBarVC <iCarouselDataSource, iCarouselDelegate, SubTemplateCellDelegate>

- (id)initWithSubTemplates:(NSSet *)data;
- (void)clearPresentedViewControllers;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
