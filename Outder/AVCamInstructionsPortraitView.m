//
//  AVCamInstructionsPortraitView.m
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "AVCamInstructionsPortraitView.h"

@implementation AVCamInstructionsPortraitView

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
    
    self.labelRotate.text = NSLocalizedString(@"Record in landscape mode", nil);
    
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

@end
