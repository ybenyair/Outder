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

typedef enum {
    kInstructionUnknown,
    kInstructionRecord,
    kInstructionFixed,
    kInstructionRetake,
    kInstructionDone
} eInstructionState;

@interface InstructionCell : UIViewController <UITextFieldDelegate>
{
    NSUInteger index;
    eInstructionState state;
}

+ (InstructionCell *) loadInstance;
+ (CGFloat) getSpacingBetweenItems;

@property (nonatomic,strong) NSMutableArray *instructions;
@property (nonatomic,strong) Instruction *currentInstruction;
@property (nonatomic,strong) AVCamInstructionsVC *superCtrl;

@property NSUInteger index;
@property eInstructionState state;

- (void)configureItem: (UIView *)view;
- (void)itemClicked;
- (void)updateMakeOneCount;
- (void)setImage:(NSString *)imageURL;
- (void)configureUserShot:(NSString *)imagePath withVideo:(NSString *)videoPath;


@property (weak, nonatomic) IBOutlet UIImageView *imageBG;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelFixedShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnEditTitle;
@property (weak, nonatomic) IBOutlet UIView *viewEditText;
@property (weak, nonatomic) IBOutlet UIView *viewInstructions;
@property (weak, nonatomic) IBOutlet UITextField *textEditTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayFixedShot;
@property (weak, nonatomic) IBOutlet UILabel *textEditPlaceholder;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayDone;
@property (weak, nonatomic) IBOutlet UIButton *btnMakeVideo;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadActivity;
@property (weak, nonatomic) IBOutlet UILabel *labelNumOfMakeOne;

- (IBAction)btnPlayListClicked:(id)sender;
- (IBAction)btnEditTitleClicked:(id)sender;
- (IBAction)btnPreviewClicked:(id)sender;
- (IBAction)btnFixedShotClicked:(id)sender;
- (IBAction)btnMakeOneClicked:(id)sender;

@end
