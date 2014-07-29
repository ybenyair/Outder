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
@property (weak, nonatomic) IBOutlet UIView *viewRecordTimer;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnRestart;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnRestartClicked:(id)sender;

- (void)setRecordButtonHidden: (BOOL) hidden;
- (void)setRestartButtonHidden: (BOOL) hidden;
- (void)updateInstructionState;

+ (AVCamInstructionsVC *) loadInstance;

@end