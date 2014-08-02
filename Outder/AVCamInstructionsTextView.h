//
//  InstructionCellTextView.h
//  Outder
//
//  Created by Yossi on 8/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCamInstructionsTextView : UIView <UITextFieldDelegate>

- (void) setSuperCtrl: (id)ctrl;
- (void) setUserTextHints: (NSSet *)hints;
- (void) startEditText;
- (void) endEditText;

@property (weak, nonatomic) IBOutlet UILabel *labelPlaceholderFirst;
@property (weak, nonatomic) IBOutlet UITextField *editTextFirst;
@property (weak, nonatomic) IBOutlet UILabel *labelPlaceholderSecond;
@property (weak, nonatomic) IBOutlet UITextField *editTextSecond;
@property (weak, nonatomic) IBOutlet UILabel *labelPlaceholderThird;
@property (weak, nonatomic) IBOutlet UITextField *editTextThird;

- (IBAction)btnCloseClicked:(id)sender;

@property BOOL isCompleted;

@end
