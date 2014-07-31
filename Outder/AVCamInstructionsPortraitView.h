//
//  AVCamInstructionsPortraitView.h
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCamInstructionsPortraitView : UIView

- (void) setSuperCtrl: (id)ctrl;

@property (weak, nonatomic) IBOutlet UILabel *labelRotate;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;

- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnCameraClicked:(id)sender;

@end
