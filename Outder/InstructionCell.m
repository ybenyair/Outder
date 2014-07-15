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

@synthesize instruction, index, videoCtrl, state;

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
    
    self.textEditTitle.layer.shadowOpacity = 1.0;
    self.textEditTitle.layer.shadowRadius = 0.0;
    self.textEditTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.textEditTitle.layer.shadowOffset = CGSizeMake(0.0, -1.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) restoreState
{
    if ([instruction.fixed boolValue] == NO)
    {
        if (self.instruction.imageURL) {
            NSLog(@"Restore start to kInstructionRetake");
            self.state = kInstructionRetake;
        }
        
    }
}

#pragma mark -
#pragma mark configure current view

- (void)configureItem: (Instruction *)data inView: (UIView *)view withIndex:(NSUInteger)indx
{
    instruction = data;
    self.labelName.text = instruction.name;
    self.index = indx;
    self.labelNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)index + 1];
    
    if ([instruction.fixed boolValue] == YES) self.state = kInstructionFixed;
    
    [self restoreState];
    
    switch (self.state) {
            
        case kInstructionFixed:
            [self setFixedShotLayer];
            break;
            
        case kInstructionRetake:
            [self setAfterUserShotLayer];
            break;
            
        case kInstructionRecord:
        case kInstructionUnknown:
            [self setBeforeUserShotLayer];
            break;
            
        default:
            break;
    }

}

- (void) setFixedShotLayer
{
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;
    [self setImage:instruction.imageURL];
    self.labelFixedShot.hidden = NO;
    
    self.btnPlayFixedShot.hidden = NO;
    self.btnPlayFixedShot.enabled = YES;
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;
    
    self.btnEditTitle.hidden = YES;
    [self.superCtrl setRecordButtonHidden:YES];
    self.state = kInstructionFixed;
}

- (void) setBeforeUserShotLayer
{
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;
    [self setImage:nil];
    self.labelFixedShot.hidden = YES;
    
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;
    
    self.btnEditTitle.hidden = YES;
    [self.superCtrl setRecordButtonHidden:NO];
    self.state = kInstructionRecord;
}

- (void) setAfterUserShotLayer
{
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;
    [self setImageUserShot:instruction.imageURL];
    self.labelFixedShot.hidden = YES;
    
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
    self.btnPlayPreview.hidden = NO;
    self.btnPlayPreview.enabled = YES;
    
    self.btnEditTitle.hidden = NO;
    self.state = kInstructionRetake;
}

- (void) setEditTextLayer
{
    self.viewInstructions.hidden = YES;
    self.viewEditText.hidden = NO;
}


- (void)setImage:(NSString *)imageURL
{
    NSURL *url = [NSURL URLWithString:imageURL];
    UIImageView *_imageView = self.imageShot;
    
    [self.imageShot setImageWithURL:url
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

- (void)setImageUserShot:(NSString *)filePath
{
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    if (image) {
        
        self.imageShot.hidden = NO;
        [self.imageShot setAlpha:0];
        [self.imageShot setImage:image];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.imageShot setAlpha:1];
                         }];
        
        NSLog(@"Update user shot for instruction '%@'", instruction.name);
        
    } else {
        NSLog(@"Cannot load user shot image from URL");
    }
}

- (void)configureUserShot:(NSString *)imagePath withVideo:(NSString *)videoPath
{
    self.instruction.imageURL = imagePath;
    self.instruction.videoURL = videoPath;
    [self setAfterUserShotLayer];
}

#pragma mark -
#pragma mark play fixed video shot

- (void)playVideo {

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

#pragma mark -
#pragma mark edit title

- (void) resetTextTitle
{
    self.textEditPlaceholder.hidden = NO;
    self.textEditTitle.text = @"";
}

- (IBAction)btnEditTitleClicked:(id)sender {
    
    // add the observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.textEditTitle];
    
    [self setEditTextLayer];
    [self.textEditTitle becomeFirstResponder];
}

// the method to call on a change
- (void)textFieldDidChange:(NSNotification*)aNotification
{
    NSLog(@"textViewDidChange");
    
    if(self.textEditTitle.text.length == 0)
    {
        [self resetTextTitle];
    }
    else
    {
        self.textEditPlaceholder.hidden = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self resetTextTitle];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn: %@", textField.text);
    // add the observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.textEditTitle];
    [textField resignFirstResponder];
    [self setAfterUserShotLayer];
    return YES;
}



#pragma mark -
#pragma mark Play video

- (IBAction)btnPreviewClicked:(id)sender {
    NSLog(@"btnPreviewClicked");
    [self playVideo];
}

- (IBAction)btnFixedShotClicked:(id)sender {
    NSLog(@"btnFixedShotClicked");
    [self playVideo];
}


@end
