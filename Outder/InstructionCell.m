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


@synthesize instructions, currentInstruction, index, videoCtrl, state;

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
    
    self.textEditPlaceholder.text = NSLocalizedString(@"TYPE YOUR MESSAGE", nil);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) restoreState
{
    if (currentInstruction == nil) {
        self.state = kInstructionDone;
        NSLog(@"Restore instruction to state: kInstructionDone");
    }
    
    if (currentInstruction && [currentInstruction.fixed boolValue] == NO)
    {
        if (currentInstruction.imageURL) {
            NSLog(@"Restore instruction to state: kInstructionRetake");
            self.state = kInstructionRetake;
        } else {
            NSLog(@"Restore instruction to state: kInstructionRecord");
            self.state = kInstructionRecord;
        }
    }
}

#pragma mark -
#pragma mark configure current view

- (void)configureItem: (UIView *)view
{
    if (index < [instructions count]) {
        currentInstruction = [instructions objectAtIndex:index];
    } else {
        currentInstruction = nil;
    }
    
    self.labelName.text = currentInstruction.name;
    self.labelNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)index + 1];
    
    if ([currentInstruction.fixed boolValue] == YES) self.state = kInstructionFixed;
    
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
        case kInstructionDone:
            [self setDoneLayer];
            break;
        default:
            break;
    }

}

- (void) hideFixedShotItems
{
    self.labelFixedShot.hidden = YES;
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
}

- (void) setFixedShotLayer	
{
    [self hideBeforeUserShotItems];
    [self hideAfterUserShotItems];
    [self hideEditTextItems];
    [self hideDoneItems];
    
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;
    
    [self setImage:currentInstruction.imageURL];
    self.labelFixedShot.hidden = NO;
    
    self.btnPlayFixedShot.hidden = NO;
    self.btnPlayFixedShot.enabled = YES;
    
    self.labelNumber.hidden = NO;
    self.labelName.text = self.currentInstruction.name;
    
    [self.superCtrl setRecordButtonHidden:YES];
    self.state = kInstructionFixed;
}

- (void) hideBeforeUserShotItems
{
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;
}

- (void) setBeforeUserShotLayer
{
    [self hideEditTextItems];
    [self hideAfterUserShotItems];
    [self hideFixedShotItems];
    [self hideDoneItems];
    
    self.viewEditText.hidden = YES;
    self.viewInstructions.hidden = NO;

    [self setImage:nil];
    
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;

    self.labelNumber.hidden = NO;
    self.labelName.text = self.currentInstruction.name;
    
    [self.superCtrl setRecordButtonHidden:NO];
    self.state = kInstructionRecord;
}

- (void) hideAfterUserShotItems
{
    self.btnEditTitle.hidden = YES;
    self.btnEditTitle.enabled = NO;
}

- (void) setAfterUserShotLayer
{
    [self hideEditTextItems];
    [self hideBeforeUserShotItems];
    [self hideFixedShotItems];
    [self hideDoneItems];
    
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;

    [self setImageUserShot:currentInstruction.imageURL];
    
    self.btnEditTitle.hidden = NO;
    self.btnEditTitle.enabled = YES;
    self.btnPlayPreview.hidden = NO;
    self.btnPlayPreview.enabled = YES;

    self.labelNumber.hidden = NO;
    self.labelName.text = self.currentInstruction.name;
    
    self.state = kInstructionRetake;
}


- (void) hideEditTextItems
{
    
}

- (void) setEditTextLayer
{
    [self hideAfterUserShotItems];
    [self hideBeforeUserShotItems];
    [self hideFixedShotItems];
    [self hideDoneItems];

    self.viewInstructions.hidden = YES;
    self.viewEditText.hidden = NO;
}

- (void) hideDoneItems
{
    self.btnPlayDone.hidden = YES;
    self.btnPlayDone.enabled = NO;
    self.btnMakeVideo.hidden = YES;
    self.btnMakeVideo.enabled = NO;
}

- (void) setDoneLayer
{
    [self hideAfterUserShotItems];
    [self hideBeforeUserShotItems];
    [self hideFixedShotItems];
    [self hideEditTextItems];
    
    self.viewInstructions.hidden = NO;
    self.viewEditText.hidden = YES;
    
    self.btnPlayDone.hidden = NO;
    self.btnPlayDone.enabled = YES;
    self.btnMakeVideo.hidden = NO;
    self.btnMakeVideo.enabled = YES;
    
    self.labelNumber.hidden = YES;
    self.labelName.text = NSLocalizedString(@"Great! all shots were recorded", nil);
    
    [self setImage:nil];
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
        
        NSLog(@"Update user shot for instruction '%@'", currentInstruction.name);
        
    } else {
        NSLog(@"Cannot load user shot image from URL");
    }
}

- (void)configureUserShot:(NSString *)imagePath withVideo:(NSString *)videoPath
{
    currentInstruction.imageURL = imagePath;
    currentInstruction.videoURL = videoPath;
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
        [videoCtrl playVideo:currentInstruction.videoURL inView:self.imageViewVideo];
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
    }
}

#pragma mark -
#pragma mark edit title

- (void) resetTextTitle
{
    self.textEditPlaceholder.hidden = NO;
    self.textEditTitle.text = @"";
}



- (IBAction)btnPlayListClicked:(id)sender {
    
    NSMutableArray *videoURLs = [[NSMutableArray alloc] init];
    Instruction *inst = nil;
    for (id dataElement in instructions) {
        inst = (Instruction *)dataElement;
        [videoURLs addObject:inst.videoURL];
        NSLog(@"Insert to the play list: %@", inst.videoURL);
    }
    
    
    if (!videoCtrl) {
        videoCtrl = [[VideoPlayerViewController alloc] init];
        videoCtrl.delegate = self;
        videoCtrl.enableAutoRotation = NO;
    }
    
    if (videoCtrl.videoState == kVideoClosed) {
        self.imageViewVideo.hidden = NO;
        [videoCtrl playVideoList:videoURLs inView:self.imageViewVideo];
    } else {
        NSLog(@"Video is already playing...	");
    }

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
