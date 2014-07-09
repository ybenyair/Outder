//
//  InstructionCell.h
//  Outder
//
//  Created by Yossi on 7/8/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instruction.h"

@interface InstructionCell : UIViewController

@property (nonatomic,strong) Instruction *instruction;

- (void)configureItem: (Instruction *)data inView: (UIView *)view;

@property (weak, nonatomic) IBOutlet UILabel *instructionFrame;

@end
