//
//  InstructionCell.m
//  Outder
//
//  Created by Yossi on 7/8/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "InstructionCell.h"

@interface InstructionCell ()

@end

@implementation InstructionCell

@synthesize instruction;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureInstructionFrame: (UIView *)inView
{
    /*
    CGRect frame = inView.frame;
    self.instructionFrame.frame = frame;
    */
    self.instructionFrame.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.instructionFrame.layer.borderWidth = 5;
    NSLog(@"instruction Frame = %@", NSStringFromCGRect(self.instructionFrame.frame));
    self.instructionFrame.text = instruction.name;
    self.instructionFrame.textColor = [UIColor whiteColor];
    self.instructionFrame.shadowColor = [UIColor blackColor];
    self.instructionFrame.shadowOffset = CGSizeMake(0, -2.0);
}

- (void)configureItem: (Instruction *)data inView: (UIView *)view
{
    instruction = data;
    [self configureInstructionFrame:view];
}

@end
