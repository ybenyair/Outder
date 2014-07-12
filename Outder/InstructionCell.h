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

@interface InstructionCell : UIViewController <VideoPlayerViewControllerDelegate>
{
    NSUInteger index;
}

+ (InstructionCell *) loadInstance;
+ (CGFloat) getSpacingBetweenItems;

@property (nonatomic,strong) Instruction *instruction;
@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;
@property (nonatomic,strong) AVCamInstructionsVC *superCtrl;

@property NSUInteger index;

- (void)configureItem: (Instruction *)data inView: (UIView *)view withIndex:(NSUInteger)indx;
- (void)itemClicked;


@property (weak, nonatomic) IBOutlet UIImageView *imageBG;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelFixedShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageFixedShot;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayFixedShot;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewVideo;

- (IBAction)btnFixedShotClicked:(id)sender;

@end
