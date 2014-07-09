//
//  SubTemplateViewController.h
//  Outder
//
//  Created by Yossi on 6/30/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "CustomUIViewController.h"
#import "SubTemplateCell.h"

@interface SubTemplatesVC : CustomUIViewController <iCarouselDataSource, iCarouselDelegate, SubTemplateCellDelegate>

- (id)initWithSubTemplates:(NSSet *)data;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
