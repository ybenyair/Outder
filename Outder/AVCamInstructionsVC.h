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
#import "AVCamInstructionsTextView.h"

@interface AVCamInstructionsVC : AVCamViewController <iCarouselDataSource, iCarouselDelegate>

- (void)setInstructions:(NSSet *)data;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIView *landscapeView;
@property (weak, nonatomic) IBOutlet UIView *viewRecordTimer;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnRestart;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnFlip;
@property (weak, nonatomic) IBOutlet UILabel *labelRecord;
@property (weak, nonatomic) IBOutlet UIButton *labelRestart;
@property (weak, nonatomic) IBOutlet AVCamInstructionsTextView *viewEditText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnRestartClicked:(id)sender;
- (IBAction)toggleMovieRecording:(id)sender;


// Camera
- (void) setCameraFront;
- (void) setCameraBack;
- (void)setRecordButtonHidden: (BOOL) hidden;

// Events from childrens
- (void) editTextEnded;
- (void) videoPlayEnded;
- (void) makeOneClicked;
- (void) btnRetakeClicked;

// Methods for childrens
- (void) setRestartButtonHidden: (BOOL) hidden;
- (void) updateInstructionState;
- (void) startEditText;
- (void) moveToNextInstruction: (CGFloat) delay;

+ (AVCamInstructionsVC *) loadInstance;

@end
