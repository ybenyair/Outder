//
//  InstructionCellTextView.m
//  Outder
//
//  Created by Yossi on 8/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "AVCamInstructionsTextView.h"
#import "AVCamInstructionsVC.h"
#import "UserText.h"
#import "Defines.h"
#import "CoreData.h"

@interface AVCamInstructionsTextView ()

@end

@implementation AVCamInstructionsTextView
{
    id superCtrl;
    BOOL isCompleted;
    NSArray *placeholderArray;
    NSArray *textFieldArray;
    NSMutableArray *activeHints;
    id currentTextResponder;
    id currentTextField;
}

@synthesize isCompleted;

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
        
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"AVCamInstructionsTextView" owner:self options:nil] objectAtIndex:0]];
    }
    
    self.labelPlaceholderFirst.font = [UIFont fontWithName:kFontBold size:35];
    self.labelPlaceholderFirst.textColor = [UIColor whiteColor];
    self.labelPlaceholderSecond.font = [UIFont fontWithName:kFontBold size:35];
    self.labelPlaceholderSecond.textColor = [UIColor whiteColor];
    self.labelPlaceholderThird.font = [UIFont fontWithName:kFontBold size:35];
    self.labelPlaceholderThird.textColor = [UIColor whiteColor];

    self.editTextFirst.font = [UIFont fontWithName:kFontBold size:35];
    self.editTextFirst.delegate = self;
    self.editTextFirst.textColor = [UIColor whiteColor];
    self.editTextSecond.font = [UIFont fontWithName:kFontBold size:35];
    self.editTextSecond.delegate = self;
    self.editTextSecond.textColor = [UIColor whiteColor];
    self.editTextThird.font = [UIFont fontWithName:kFontBold size:35];
    self.editTextThird.delegate = self;
    self.editTextThird.textColor = [UIColor whiteColor];

    textFieldArray = [NSArray arrayWithObjects:self.editTextFirst, self.editTextSecond, self.editTextThird, nil];
    placeholderArray = [NSArray arrayWithObjects:self.labelPlaceholderFirst, self.labelPlaceholderSecond, self.labelPlaceholderThird, nil];

    return self;
}


- (void) setSuperCtrl: (id)ctrl
{
    superCtrl = ctrl;
}

- (void) setUserTextHints: (NSSet *)hints
{
    activeHints = [NSMutableArray arrayWithArray:[hints allObjects]];
    isCompleted = YES;
    NSUInteger index = 0;
    for (id dataElement in placeholderArray) {
        UILabel *placeholder = dataElement;
        UITextField *textField = [textFieldArray objectAtIndex:index];
        textField.text = @"";
        
        UserText *hint = nil;
        if (index < [activeHints count]) {
            hint = [activeHints objectAtIndex:index];
            placeholder.text = hint.textHint;
            textField.text = hint.text;
            textField.hidden = NO;
            textField.userInteractionEnabled = YES;
            
            if (textField.text.length > 0) {
                placeholder.hidden = YES;
            } else {
                placeholder.hidden = NO;
            }
            
            if (textField.text == nil || textField.text.length == 0) {
                isCompleted = NO;
            }
            
        } else {
            placeholder.hidden = YES;
            placeholder.text = @"";
            textField.hidden = YES;
            textField.userInteractionEnabled = NO;
        }
        
        index++;
    }
    
    if (isCompleted)  {
        NSLog(@"User text is COMPLETED");
    } else {
        NSLog(@"User text is NOT COMPLETED");
    }
}

- (void) startEditText
{    
    BOOL start = NO;
    
    for (id dataElement in textFieldArray) {
        UITextField *textField = dataElement;
        if (textField.hidden == NO) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textFieldDidChange:)
                                                         name:@"UITextFieldTextDidChangeNotification"
                                                       object:dataElement];
            start = YES;
        }
    }
    
    if (start) {
        [self.editTextFirst becomeFirstResponder];
        currentTextResponder = self.editTextFirst;
    } else {
        [superCtrl editTextEnded];
    }
}

- (void) endEditText
{
    for (id dataElement in textFieldArray) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"UITextFieldTextDidChangeNotification"
                                                      object:dataElement];
    }
    
    [currentTextResponder resignFirstResponder];
}

- (NSUInteger) getTextFieldIndex: (UITextField *)item
{
    NSUInteger index = 0;
    for (id dataElement in textFieldArray) {
        if (dataElement == item) return index;
        index++;
    }
    return 0;
}

- (void) resetTextTitle: (UITextField *)textField
{
    NSUInteger index = [self getTextFieldIndex:textField];
    UILabel *label = [placeholderArray objectAtIndex:index];
    label.hidden = NO;
    textField.text = @"";
}

// the method to call on a change
- (void)textFieldDidChange:(NSNotification*)aNotification
{
    UITextField *textField = aNotification.object;
    NSLog(@"textViewDidChange %p",textField);
    NSUInteger index = [self getTextFieldIndex:textField];
    
    if(textField.text.length == 0)
    {
        [self resetTextTitle:textField];
    }
    else
    {
        UILabel *placeholder = [placeholderArray objectAtIndex:index];
        placeholder.hidden = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing: %p", textField);
    currentTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn: %@", textField.text);
    
    NSUInteger nextIndex = [self getTextFieldIndex:textField] + 1;
    
    if (nextIndex < [activeHints count]) {
        UITextField *obj = [textFieldArray objectAtIndex:nextIndex];
        [currentTextResponder resignFirstResponder];
        [obj becomeFirstResponder];
        currentTextResponder = obj;
    } else {
        [self saveUserText];
        [superCtrl editTextEnded];
    }
    
    return YES;
}

- (void) saveUserText
{
    isCompleted = YES;

    NSUInteger index = 0;
    for (id dataElement in activeHints) {
        if (index < [textFieldArray count]) {
            UserText *userText = dataElement;
            UITextField *textField = [textFieldArray objectAtIndex:index];
            userText.text = textField.text;
            NSLog(@"User text = %@", textField.text);
            
            if (textField.text == nil || textField.text.length == 0) {
                isCompleted = NO;
            }
        }
        index++;
    }
    
    if (isCompleted)  {
        NSLog(@"User text is COMPLETED");
    } else {
        NSLog(@"User text is NOT COMPLETED");
    }
    
    [CoreData saveDB];
}

- (IBAction)btnCloseClicked:(id)sender {
    [ self textFieldShouldReturn:currentTextField];
}

@end
