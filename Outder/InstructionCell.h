//
//  InstructionCell.h
//  Outder
//
//  Created by Yossi on 7/8/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instruction.h"
#import "VideoPlayerViewController.h"
#import "AVCamInstructionsVC.h"
#import "UILabelAligned.h"

typedef enum {
    kInstructionUnknown,
    kInstructionRecord,
    kInstructionFixed,
    kInstructionRetake,
    kInstructionDone
} eInstructionState;

@interface InstructionCell : UIViewController
{
    NSUInteger index;
    eInstructionState state;
}

+ (InstructionCell *) loadInstance;
+ (CGFloat) getSpacingBetweenItems;

@property (nonatomic,strong) NSMutableArray *instructions;
@property (nonatomic,strong) Instruction *currentInstruction;
@property (nonatomic,weak) AVCamInstructionsVC *superCtrl;

@property NSUInteger index;
@property eInstructionState state;

@property (weak, nonatomic) IBOutlet UIImageView *imageBG;
@property (weak, nonatomic) IBOutlet UILabelAligned *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber;
@property (weak, nonatomic) IBOutlet UIImageView *viewNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelFixedShot;
@property (weak, nonatomic) IBOutlet UIImageView *viewFixedShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnRetake;
@property (weak, nonatomic) IBOutlet UIView *viewInstructions;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayFixedShot;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayDone;
@property (weak, nonatomic) IBOutlet UIButton *btnMakeVideo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadActivity;
@property (weak, nonatomic) IBOutlet UILabel *labelDone;
@property (weak, nonatomic) IBOutlet UILabel *labelCenter;
@property (weak, nonatomic) IBOutlet UILabel *labelLeft;
@property (weak, nonatomic) IBOutlet UILabel *labelRight;
@property (weak, nonatomic) IBOutlet UIButton *btnEditText;

- (IBAction)btnRetakeClicked:(id)sender;
- (IBAction)btnPlayListClicked:(id)sender;
- (IBAction)btnPreviewClicked:(id)sender;
- (IBAction)btnFixedShotClicked:(id)sender;
- (IBAction)btnMakeOneClicked:(id)sender;
- (IBAction)btnEditTextClicked:(id)sender;


- (void)configureItem: (UIView *)view;
- (void)playVideo;
- (void)playVideoList;
- (void)itemClicked;
- (void)updateMakeOneCount;
- (void)setImage:(NSString *)imageURL;
- (void)configureUserShot:(NSString *)imagePath withVideo:(NSString *)videoPath;
- (void)currentlyPresented;
- (void)currentlyDragging;

@end
