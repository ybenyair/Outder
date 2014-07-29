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
#import "FeedCoreData.h"
#import "Defines.h"
#import "UploadManager.h"
#import "VideoOverlayHelpers.h"
#import "CoreData.h"

@interface InstructionCell ()

@end

@implementation InstructionCell
{
    NSMutableArray *playerList;
    NSUInteger currentPlaying;
}

@synthesize instructions, currentInstruction, index, state;

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

- (void) viewDidDisappear:(BOOL)animated
{
    [self closeVideo:nil];
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


- (void) restoreLayout: (BOOL) updateImages
{
    switch (self.state) {
            
        case kInstructionFixed:
            [self setInstructionFixedLayer: updateImages];
            break;
            
        case kInstructionRetake:
            [self setInstructionRetakeLayer: updateImages];
            break;
            
        case kInstructionRecord:
        case kInstructionUnknown:
            [self setInstructionRecordLayer];
            break;
            
        case kInstructionDone:
            [self setInstructionDoneLayer];
            break;
            
        default:
            break;
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

    [self restoreLayout: YES];
}

#pragma mark -
#pragma mark contorl the visibale views

- (void) hideEditTextView
{
    self.viewEditText.hidden = YES;
    self.viewEditText.userInteractionEnabled = NO;
}

- (void) unhideEditTextView
{
    self.viewEditText.hidden = NO;
    self.viewEditText.userInteractionEnabled = YES;
}

- (void) hideInstructionsView
{
    self.viewInstructions.hidden = YES;
    self.viewInstructions.userInteractionEnabled = NO;
}

- (void) unhideInstructionsView
{
    self.viewInstructions.hidden = NO;
    self.viewInstructions.userInteractionEnabled = YES;
}

- (void) setInstructionsViewActive
{
    [self hideEditTextView];
    [self unhideInstructionsView];
}

- (void) setEditTextViewActive
{
    [self hideInstructionsView];
    [self unhideEditTextView];
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionRecord state

- (void) hideInstructionRecordItems
{

}

- (void) unhideInstructionRecordItems
{
    [self setInstructionsViewActive];
    self.labelNumber.hidden = NO;
}

- (void) setInstructionRecordLayer
{
    // Hide layers
    [self hideInstructionFixedItems];
    [self hideInstructionRetakeItems];
    [self hideInstructionDoneItems];
    
    // Unhide layers
    [self unhideInstructionRecordItems];
    
    // Set parameters
    [self setImage:nil];
    self.labelName.text = self.currentInstruction.name;
    self.state = kInstructionRecord;
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionFixed state

- (void) hideInstructionFixedItems
{
    self.labelFixedShot.hidden = YES;
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
}

- (void) unhideInstructionFixedItems
{
    [self setInstructionsViewActive];
    self.labelFixedShot.hidden = NO;
    self.btnPlayFixedShot.hidden = NO;
    self.btnPlayFixedShot.enabled = YES;
    self.labelNumber.hidden = NO;
}

- (void) setInstructionFixedLayer: (BOOL) updateImages
{
    // Hide layers
    [self hideInstructionRecordItems];
    [self hideInstructionRetakeItems];
    [self hideInstructionDoneItems];
    
    // Unhide layers
    [self unhideInstructionFixedItems];
    
    // Set parameters
    if (updateImages) [self setImage:currentInstruction.imageURL];
    self.labelName.text = self.currentInstruction.name;
    self.state = kInstructionFixed;
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionRetake state

- (void) hideInstructionRetakeItems
{
    self.btnEditTitle.hidden = YES;
    self.btnEditTitle.enabled = NO;
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;
}


- (void) unhideInstructionRetakeItems
{
    [self setInstructionsViewActive];
    self.btnEditTitle.hidden = NO;
    self.btnEditTitle.enabled = YES;
    self.btnPlayPreview.hidden = NO;
    self.btnPlayPreview.enabled = YES;
    self.labelNumber.hidden = NO;
}

- (void) setInstructionRetakeLayer: (BOOL) updateImages
{
    // Hide layers
    [self hideInstructionRecordItems];
    [self hideInstructionFixedItems];
    [self hideInstructionDoneItems];
    
    // Unhide layers
    [self unhideInstructionRetakeItems];
    
    // Set parameters
    if (updateImages) [self setImageUserShot:currentInstruction.imageURL];
    
    self.labelName.text = self.currentInstruction.name;
    self.state = kInstructionRetake;
}


#pragma mark -
#pragma mark contorl the visibale items in kInstructionDone state

- (void) processUploadIndicator
{
    Instruction *inst = [instructions firstObject];
    SubTemplate *subTemplate = inst.subTemplate;
    NSInteger numOfMakeOne = [[UploadManager getInstance] getNumOfMakeOne:subTemplate];
    
    NSLog(@"Numbet of MakeOne = %ld", (long)numOfMakeOne);
    
    if (numOfMakeOne > 0) {
        self.uploadActivity.hidden = NO;
        [self.uploadActivity startAnimating];
        self.labelNumOfMakeOne.text = [NSString stringWithFormat:@"%ld", (long)numOfMakeOne];
        self.labelNumOfMakeOne.hidden = NO;
    } else {
        self.uploadActivity.hidden = YES;
        self.labelNumOfMakeOne.hidden = YES;
    }
}

- (void) hideInstructionDoneItems
{
    self.btnPlayDone.hidden = YES;
    self.btnPlayDone.enabled = NO;
    self.btnMakeVideo.hidden = YES;
    self.btnMakeVideo.enabled = NO;
    self.uploadActivity.hidden = YES;
    self.labelNumOfMakeOne.hidden = YES;
}

- (void) unhideInstructionDoneItems
{
    [self setInstructionsViewActive];
    self.btnPlayDone.hidden = NO;
    self.btnPlayDone.enabled = YES;
    
    self.btnMakeVideo.hidden = NO;
    Instruction *inst = [instructions firstObject];
    self.btnMakeVideo.enabled = (![inst.subTemplate.makeOneDisable boolValue]);

    [self processUploadIndicator];
}

- (void) setInstructionDoneLayer
{
    // Hide layers
    [self hideInstructionRecordItems];
    [self hideInstructionFixedItems];
    [self hideInstructionRetakeItems];
    
    // Unhide layers
    [self unhideInstructionDoneItems];

    // Set parameters
    self.labelNumber.hidden = YES;
    self.labelName.text = NSLocalizedString(@"Great! all shots were recorded", nil);
    [self setImage:nil];
    self.imageShot.backgroundColor = [UIColor clearColor];
    self.imageShot.alpha = 0.5f;
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
    [self setInstructionRetakeLayer: YES];
    [CoreData saveDB];
}

#pragma mark -
#pragma mark play video (helpers)

- (NSUInteger) getPlayerIndex: (id) player {
    NSUInteger indexPlayer = 0;
    for (id dataElement in playerList) {
        if (player == dataElement) {
            return indexPlayer;
        }
        indexPlayer++;
    }
    
    return 0;
}

- (void) disableButtons
{
    self.btnEditTitle.enabled = NO;
    self.btnPlayDone.enabled = NO;
    self.btnPlayPreview.enabled = NO;
    self.btnPlayFixedShot.enabled = NO;
    self.btnMakeVideo.enabled = NO;
    [self.superCtrl setRecordButtonHidden:YES];
    [self.superCtrl setRestartButtonHidden:YES];
}

- (void) enableButtons
{
    [self restoreLayout: NO];
    [self.superCtrl updateInstructionState];
}

#pragma mark -
#pragma mark play video (a single video)

- (void)playVideo {
    
    [self disableButtons];
    
    currentPlaying = 0;
    
    playerList = [[NSMutableArray alloc] init];

    VideoPlayerViewController *videoCtrl = [playerList firstObject];
    
    self.imageViewVideo.backgroundColor = [UIColor clearColor];
    
    if (!videoCtrl) {
        videoCtrl = [[VideoPlayerViewController alloc] initWithView:self.imageViewVideo andURL:currentInstruction.videoURL];
        [videoCtrl setDelegate:self withInfo:videoCtrl];
        [videoCtrl setTapGesture:YES];
        videoCtrl.enableAutoRotation = NO;
        [playerList addObject:videoCtrl];
    }
    
    if (videoCtrl.videoState == kVideoClosed) {
        VideoOverlay *overlay = [VideoOverlayHelpers getVideoOverlay:currentInstruction];
        [videoCtrl setVideoOverlay:overlay];
        self.imageViewVideo.hidden = NO;
        [videoCtrl playVideo];
    } else {
        NSLog(@"Video is already playing...	");
    }

}

#pragma mark -
#pragma mark play video (a list of videos)

- (void) playVideoList {
    
    [self disableButtons];
    
    self.imageViewVideo.backgroundColor = [UIColor blackColor];
    
    currentPlaying = 0;
    
    playerList = [[NSMutableArray alloc] init];
    
    self.imageViewVideo.hidden = NO;
    
    Instruction *inst = nil;
    
    for (id dataElement in instructions) {
        inst = (Instruction *)dataElement;
        VideoPlayerViewController *player = [[VideoPlayerViewController alloc] initWithView:self.imageViewVideo andURL:inst.videoURL];
        player.enableAutoRotation = NO;
        [player setDelegate:self withInfo:player];
        [player setFadingDuration:0.0f];
        [playerList addObject:player];
        NSLog(@"Insert to the play list: %@", inst.videoURL);
    }
    
    VideoPlayerViewController *firstPlayer = [playerList objectAtIndex:0];
    inst = [instructions objectAtIndex:0];
    VideoOverlay *overlay = [VideoOverlayHelpers getVideoOverlay:inst];
    [firstPlayer setTapGesture:YES];
    [firstPlayer setVideoOverlay:overlay];
    [firstPlayer playVideo];
    
    if ([playerList count] > 1) {
        VideoPlayerViewController *secondPlayer = [playerList objectAtIndex:1];
        inst = [instructions objectAtIndex:1];
        VideoOverlay *overlay = [VideoOverlayHelpers getVideoOverlay:inst];
        [secondPlayer setVideoOverlay:overlay];
        [secondPlayer prepareVideo];
    }
}

#pragma mark -
#pragma mark play video (close video)

- (void) closeVideo: (VideoPlayerViewController *)videoCtrl {
    
    while ([playerList lastObject] != videoCtrl) {
        VideoPlayerViewController *obj = [playerList lastObject];
        [obj setDelegate:nil withInfo:nil];
        [obj stopVideo:NO];
        [playerList removeObject:obj];
        obj = nil;
    }
    
    [videoCtrl stopVideo:YES];
}

#pragma mark -
#pragma mark play video (delegate VideoPlayerViewController)

- (BOOL) keepActivePlayers {
    if ([playerList count] > 1) {
        // Playing a list of files
        return YES;
    } else {
        // Playing a single file
        return NO;
    }
    
}

- (void) videoDidClose:(id)userInfo
{
    NSUInteger indexClosed = [self getPlayerIndex:userInfo];
    [userInfo setTapGesture:NO];
    if (indexClosed == [playerList count] - 1) {
        NSLog(@"PLAY LIST: last video was closed");
        [playerList removeAllObjects];
        self.imageViewVideo.hidden = YES;
        playerList = nil;
        [self enableButtons];
        
    } else {
        
        NSUInteger nextToPlay = indexClosed + 1;
        VideoPlayerViewController *player = [playerList objectAtIndex:nextToPlay];
        [player setTapGesture:YES];
        [player playWhenPrepared];
        
        currentPlaying = nextToPlay;

        NSLog(@"PLAY LIST: more to play - %lu", (unsigned long)nextToPlay);
        
        NSUInteger nextToPrepare = indexClosed + 2;
        if (nextToPrepare < [playerList count]) {
            VideoPlayerViewController *player = [playerList objectAtIndex:nextToPrepare];
            Instruction *inst = [instructions objectAtIndex:nextToPrepare];
            VideoOverlay *overlay = [VideoOverlayHelpers getVideoOverlay:inst];
            [player setVideoOverlay:overlay];
            [player prepareVideo];
            NSLog(@"PLAY LIST: more to prepare - %lu", (unsigned long)nextToPrepare);
            
            if (player == [playerList lastObject]) {
                [player setFadingDuration:1.0f];
            }
        }

    }
}

- (BOOL) videoShouldClose:(id)userInfo
{
    self.imageViewVideo.backgroundColor = [UIColor clearColor];
    VideoPlayerViewController *videoCtrl = userInfo;
    [videoCtrl setFadingDuration:1.0f];
    
    [self closeVideo:userInfo];
    
    return NO;
}

#pragma mark -
#pragma mark play video (call back from iCarousel)

- (void)itemClicked
{
    NSLog(@"itemClicked");
}

#pragma mark -
#pragma mark edit title

- (void) resetTextTitle
{
    self.textEditPlaceholder.hidden = NO;
    self.textEditTitle.text = @"";
}


- (IBAction)btnPlayListClicked:(id)sender {
    [self playVideoList];
}

- (IBAction)btnEditTitleClicked:(id)sender {
    
    // add the observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.textEditTitle];
    
    [self setEditTextViewActive];
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
    [self setInstructionsViewActive];
    return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)btnPreviewClicked:(id)sender {
    NSLog(@"btnPreviewClicked");
    [self playVideo];
}

- (IBAction)btnFixedShotClicked:(id)sender {
    NSLog(@"btnFixedShotClicked");
    [self playVideo];
}

- (IBAction)btnMakeOneClicked:(id)sender {
    NSLog(@"btnMakeOneClicked");
    Feed *feed = [FeedCoreData createFeed:kMyVideoType];
    Instruction *inst = [instructions firstObject];
    SubTemplate *subTemplate = inst.subTemplate;
    // A new feed
    feed.title = subTemplate.title;
    feed.videoURL = nil;
    feed.imageURL = inst.imageURL;
    feed.pageURL = nil;
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    feed.time = [formatter stringFromDate:[NSDate date]];
    feed.subTemplate = subTemplate;
    self.btnMakeVideo.enabled = NO;
    //[subTemplate addFeedsObject:feed];
    NSLog(@"Post MakeOne notification %p", feed);

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"MakeOne"
                                      object:feed
                                    userInfo:nil];
    
}

- (void)updateMakeOneCount
{
    [self processUploadIndicator];
}

@end
