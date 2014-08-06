//
//  AVCamInstructionsPortraitView.m
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "AVCamInstructionsPortraitView.h"
#import "AVCamViewController.h"
#import "AVCamInstructionsVC.h"
#import "Defines.h"

@interface AVCamInstructionsPortraitView ()


@end

@implementation AVCamInstructionsPortraitView
{

}

@synthesize superCtrl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])){
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"AVCamInstructionsPortraitView.iPhone5" owner:self options:nil] objectAtIndex:0]];
        } else {
            // code for 3.5-inch screen
            [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"AVCamInstructionsPortraitView.iPhone4" owner:self options:nil] objectAtIndex:0]];
        }
    }
    
    self.labelRotate.text = NSLocalizedString(@"Shoot in landscape mode", nil);
    self.labelRotate.font = [UIFont fontWithName:kFontBold size:24];
    
    UIImage *imagePress = [UIImage imageNamed:@"back_press"];
    [self.btnBack setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    self.btnBack.showsTouchWhenHighlighted = YES;
    
    imagePress = [UIImage imageNamed:@"icon_rotate_camera_press"];
    [self.btnCamera setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    self.btnCamera.showsTouchWhenHighlighted = YES;

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setSuperCtrl: (id)ctrl
{
    superCtrl = ctrl;
}

- (IBAction)btnBackClicked:(id)sender {
    [superCtrl btnBackClicked:nil];
}

- (IBAction)btnCameraClicked:(id)sender {
    [superCtrl changeCamera:nil];
}

@end
