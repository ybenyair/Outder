//
//  AVCamInstructionsVC.h
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "SubTemplate.h"
#import "iCarousel.h"
#import "AVCamViewController.h"

@interface AVCamInstructionsVC : AVCamViewController <iCarouselDataSource, iCarouselDelegate>

- (void)setInstructions:(NSSet *)data;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIView *landscapeView;
@property (weak, nonatomic) IBOutlet UIView *portraitView;
@property (weak, nonatomic) IBOutlet UILabel *labelRotate;

- (IBAction)btnBackClicked:(id)sender;

@end
