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
#import "Defines.h"

@interface InstructionCell ()

@end

@implementation InstructionCell
{
    NSMutableArray *playerList;
    NSUInteger currentPlaying;
}

#define kPreviewString NSLocalizedString(@"Preview", nil);
#define kRetakeString NSLocalizedString(@"Retake", nil);
#define kMakeString NSLocalizedString(@"Make video", nil);
#define kEditText NSLocalizedString(@"Edit text", nil);

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
        spacing = 0.71f;
    }
    
    return spacing;
}

+ (InstructionCell *) loadInstance;
{
    InstructionCell *cell = nil;
    cell = [[InstructionCell alloc] initWithNibName:@"InstructionCell" bundle:nil];
    return cell;
}

- (void) dealloc
{
    NSLog(@"dealloc InstructionCell");
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
    self.imageShot.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewVideo.hidden = YES;
    
    /*
    self.textEditTitle.layer.shadowOpacity = 1.0;
    self.textEditTitle.layer.shadowRadius = 0.0;
    self.textEditTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.textEditTitle.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    self.textEditPlaceholder.text = NSLocalizedString(@"TYPE YOUR MESSAGE", nil);
    */
    self.labelFixedShot.text = NSLocalizedString(@"Fixed shot - Cannot be edited!", nil);
    self.labelFixedShot.font = [UIFont fontWithName:kFontBold size:12];
    self.labelFixedShot.textColor = [UIColor whiteColor];
    
    self.labelName.font = [UIFont fontWithName:kFontBold size:16];
    self.labelName.textColor = [FontHelpers colorFromHexString:@"#41beb1"];
    
    self.labelDone.font = [UIFont fontWithName:kFontBlack size:20];
    self.labelDone.textColor = [FontHelpers colorFromHexString:@"#41beb1"];
    self.labelDone.text = NSLocalizedString(@"Press 'Make video' to complete", nil);

    self.labelNumber.font = [UIFont fontWithName:kFontBlack size:45];
    self.labelNumber.textColor = [UIColor whiteColor];
    
    self.labelRecorded.font = [UIFont fontWithName:kFontRegular size:13];
    self.labelRecorded.textColor = [FontHelpers colorFromHexString:@"#4db500"];
    self.labelRecorded.text = NSLocalizedString(@"Recorded", nil);
    
    self.labelSeconds.font = [UIFont fontWithName:kFontRegular size:13];
    self.labelSeconds.textColor = [FontHelpers colorFromHexString:@"#4d4d4d"];
    
    self.uploadActivity.color = [FontHelpers colorFromHexString:@"#41beb1"];
    self.labelNumOfMakeOne.textColor = [FontHelpers colorFromHexString:@"#41beb1"];
    self.labelNumOfMakeOne.font = [UIFont fontWithName:kFontBold size:14];
    
    self.labelLeft.font = [UIFont fontWithName:kFontBold size:14];
    self.labelLeft.textColor = [UIColor whiteColor];

    self.labelRight.font = [UIFont fontWithName:kFontBold size:14];
    self.labelRight.textColor = [UIColor whiteColor];
    
    self.labelCenter.font = [UIFont fontWithName:kFontBold size:14];
    self.labelCenter.textColor = [UIColor whiteColor];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) currentlyPresented
{
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self closeVideo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SubTemplate *) getSubTemplate
{
    Instruction *inst = [instructions firstObject];
    SubTemplate *subTemplate = inst.subTemplate;
    return subTemplate;
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
    self.labelName.text = currentInstruction.name;
    self.labelNumber.text = [NSString stringWithFormat:@"%lu", (unsigned long)index + 1];
    NSString *seconds = NSLocalizedString(@"Seconds", nil);
    self.labelSeconds.text = [NSString stringWithFormat:@"%d %@", [currentInstruction.length intValue], seconds];
    
    if ([currentInstruction.fixed boolValue] == YES) self.state = kInstructionFixed;
    
    [self restoreState];

    [self restoreLayout: YES];
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionRecord state

- (void) hideInstructionRecordItems
{

}

- (void) unhideInstructionRecordItems
{
    self.labelNumber.hidden = NO;
    self.viewNumber.hidden = NO;
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
    self.labelName.hidden = NO;
    self.state = kInstructionRecord;
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionFixed state

- (void) hideInstructionFixedItems
{
    self.labelFixedShot.hidden = YES;
    self.viewFixedShot.hidden = YES;
    self.btnPlayFixedShot.hidden = YES;
    self.btnPlayFixedShot.enabled = NO;
    self.labelCenter.hidden = YES;
}

- (void) unhideInstructionFixedItems
{
    self.labelFixedShot.hidden = NO;
    self.viewFixedShot.hidden = NO;
    self.btnPlayFixedShot.hidden = NO;
    self.btnPlayFixedShot.enabled = YES;
    self.labelNumber.hidden = NO;
    self.viewNumber.hidden = NO;
    self.labelCenter.hidden = NO;
}

- (void) setInstructionFixedLayer: (BOOL) updateImages
{
    // Hide layers
    [self hideInstructionRecordItems];
    [self hideInstructionRetakeItems];
    [self hideInstructionDoneItems];
    
    // Unhide layers
    [self unhideInstructionFixedItems];

    self.viewSeconds.hidden = YES;
    self.labelSeconds.hidden = YES;

    // Set parameters
    if (updateImages) [self setImage:currentInstruction.imageURL];
    self.labelName.text = self.currentInstruction.name;
    self.labelName.hidden = NO;
    self.state = kInstructionFixed;
    self.labelCenter.text = kPreviewString;
}

#pragma mark -
#pragma mark contorl the visibale items in kInstructionRetake state

- (void) hideInstructionRetakeItems
{
    self.btnRetake.hidden = YES;
    self.btnRetake.enabled = NO;
    self.btnPlayPreview.hidden = YES;
    self.btnPlayPreview.enabled = NO;
    self.viewRecorded.hidden = YES;
    self.labelRecorded.hidden = YES;
    self.labelLeft.hidden = YES;
    self.labelRight.hidden = YES;
}


- (void) unhideInstructionRetakeItems
{
    self.btnRetake.hidden = NO;
    self.btnRetake.enabled = YES;
    self.btnPlayPreview.hidden = NO;
    self.btnPlayPreview.enabled = YES;
    self.labelNumber.hidden = NO;
    self.viewNumber.hidden = NO;
    self.viewRecorded.hidden = NO;
    self.labelRecorded.hidden = NO;
    self.viewSeconds.hidden = NO;
    self.labelSeconds.hidden = NO;
    self.labelLeft.hidden = NO;
    self.labelRight.hidden = NO;
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
    self.labelName.hidden = NO;
    self.state = kInstructionRetake;
    self.labelRight.text = kRetakeString;
    self.labelLeft.text = kPreviewString;
    
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
    self.labelDone.hidden = YES;
    self.labelLeft.hidden = YES;
    self.labelRight.hidden = YES;
    self.labelCenter.hidden = YES;
    self.btnEditText.hidden = YES;
    self.btnEditText.enabled = NO;
    
    CGPoint center = self.labelLeft.center;
    center.x = self.btnPlayPreview.center.x;
    self.labelLeft.center = center;
    
    center = self.labelRight.center;
    center.x = self.btnRetake.center.x;
    self.labelRight.center = center;
    
    self.imageShot.alpha = 1.0f;
    self.imageShot.backgroundColor = [UIColor clearColor];
}

- (void) unhideInstructionDoneItems
{
    self.btnPlayDone.hidden = NO;
    self.btnPlayDone.enabled = YES;
    
    self.btnMakeVideo.hidden = NO;
    Instruction *inst = [instructions firstObject];
    self.btnMakeVideo.enabled = (![inst.subTemplate.makeOneDisable boolValue]);
    
    CGFloat xLeft = self.btnPlayPreview.center.x;
    CGFloat xRight = self.btnRetake.center.x;
    
    if ([[[self getSubTemplate] userTexts] count] > 0) {
        self.btnEditText.hidden = NO;
        self.btnEditText.enabled = YES;
        self.labelCenter.hidden = NO;
        xLeft = self.btnMakeVideo.center.x;
        xRight = self.btnPlayDone.center.x;
    }
    
    self.labelDone.hidden = NO;
    self.labelLeft.hidden = NO;
    self.labelRight.hidden = NO;
    
    CGPoint center = self.labelLeft.center;
    center.x = xLeft;
    self.labelLeft.center = center;
    
    center = self.btnMakeVideo.center;
    center.x = xLeft;
    self.btnMakeVideo.center = center;
    
    center = self.labelRight.center;
    center.x = xRight;
    self.labelRight.center = center;
    
    center = self.btnPlayDone.center;
    center.x = xRight;
    self.btnPlayDone.center = center;
    
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
    self.viewNumber.hidden = YES;
    self.viewSeconds.hidden = YES;
    self.labelSeconds.hidden = YES;
    self.labelName.hidden = YES;
    
    [self setImage:nil];
    
    self.labelLeft.text = kMakeString;
    self.labelRight.text = kPreviewString;
    self.labelCenter.text = kEditText;
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
    self.btnRetake.enabled = NO;
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
    
    if (!currentInstruction.videoURL) return;
    
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
        if (inst.videoURL) {
            VideoPlayerViewController *player = [[VideoPlayerViewController alloc] initWithView:self.imageViewVideo andURL:inst.videoURL];
            player.enableAutoRotation = NO;
            [player setDelegate:self withInfo:player];
            [player setFadingDuration:0.0f];
            [playerList addObject:player];
            NSLog(@"Insert to the play list: %@", inst.videoURL);
        }
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
        
        [self.superCtrl videoPlayEnded];

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
#pragma mark Actions

- (void)itemClicked
{
    NSLog(@"itemClicked");
}

- (IBAction)btnRetakeClicked:(id)sender {
    [self.superCtrl btnRetakeClicked];
}

- (IBAction)btnPlayListClicked:(id)sender {
    [self playVideoList];
}

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

    self.labelDone.text = NSLocalizedString(@"GREAT!!! YOU ARE DONE", nil);

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
    
    
    
    
    [self.superCtrl makeOneClicked];
}

- (IBAction)btnEditTextClicked:(id)sender {
    [self.superCtrl startEditText];
}

- (void)updateMakeOneCount
{
    [self processUploadIndicator];
}

@end
