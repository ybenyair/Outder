//
//  InstructionCell.m
//  Outder
//
//  Created by Yossi on 7/8/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "InstructionCell.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface InstructionCell ()

@end

@implementation InstructionCell

@synthesize instruction, index, videoCtrl;

+ (CGFloat) getSpacingBetweenItems
{
    CGFloat spacing = 1.0f;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        spacing = 0.78f;
    } else {
        // code for 3.5-inch screen
        spacing = 0.82f;
    }
    
    return spacing;
}

+ (InstructionCell *) loadInstance;
{
    InstructionCell *cell = nil;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        cell = [[InstructionCell alloc] initWithNibName:@"InstructionCell.iPhone5" bundle:nil];
     } else {
        // code for 3.5-inch screen
        cell = [[InstructionCell alloc] initWithNibName:@"InstructionCell.iPhone4" bundle:nil];
     }
    
    return cell;
}

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
    self.imageBG.contentMode = UIViewContentModeScaleAspectFit;
    self.labelFixedShot.contentMode = UIViewContentModeScaleAspectFit;
    self.labelFixedShot.layer.cornerRadius = 10;
    self.imageViewVideo.hidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark configure current view

- (void)configureItem: (Instruction *)data inView: (UIView *)view withIndex:(NSUInteger)indx
{
    instruction = data;
    self.labelName.text = instruction.name;
    self.index = indx;
    self.labelNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)index + 1];
    if ([instruction.fixed boolValue] == YES)
    {
        [self setFixedShotLayer];
    } else {
        [self setUserShotLayer];
    }
}

- (void) setFixedShotLayer
{
    [self setImage:instruction.imageURL];
    self.labelFixedShot.hidden = NO;
    self.btnPlayFixedShot.hidden = NO;
    self.btnPlayFixedShot.enabled = YES;
}

- (void) setUserShotLayer
{
    [self setImage:nil];
    self.labelFixedShot.hidden = YES;
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
}

- (void)setImage:(NSString *)imageURL
{
    NSURL *url = [NSURL URLWithString:imageURL];
    UIImageView *_imageView = self.imageFixedShot;
    
    [self.imageFixedShot setImageWithURL:url
                    placeholderImage:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (image)
                               {
                                   _imageView.alpha = 0.0;
                                   [UIView animateWithDuration:0.5
                                                    animations:^{
                                                        _imageView.alpha = 1.0;
                                                    }];
                               }
                           }];
}


#pragma mark -
#pragma mark play fixed video shot

- (IBAction)btnFixedShotClicked:(id)sender {
    NSLog(@"Video image tapped");

    
    if (!videoCtrl) {
        videoCtrl = [[VideoPlayerViewController alloc] init];
        videoCtrl.delegate = self;
        videoCtrl.enableAutoRotation = NO;
    }
    
    if (videoCtrl.videoState == kVideoClosed) {
        self.imageViewVideo.hidden = NO;
        [videoCtrl playVideo:self.instruction.videoURL inView:self.imageViewVideo];
    } else {
        NSLog(@"Video is already playing...	");
    }

}

- (void) videoClosed
{
    self.imageViewVideo.hidden = YES;
}

- (void)itemClicked
{
    if (videoCtrl && videoCtrl.videoState == kVideoOpened) {
        [self.videoCtrl stopButtonClicked:nil];
    } else {
        NSLog(@"Video is already playing...	");
    }
}

@end
