//
//  AVCamInstructionsVC.m
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "AVCamInstructionsVC.h"
#import "InstructionCell.h"
#import "CoreData.h"
#import "Feed.h"
#import "Instruction.h"
#import "AVCamInstructionsPortraitView.h"
#import "Defines.h"
#import "UserText.h"
#import "FileHelpers.h"
#import "MP3Player.h"

@interface AVCamInstructionsVC ()

@end

@implementation AVCamInstructionsVC
{
    NSMutableArray *_presentedInstructions;
    NSMutableArray *_instructions;
    NSMutableDictionary *_reusedInstructionViews;
    NSInteger _previousPage;
    CGFloat beginOffset;
    CGFloat endOffset;
    BOOL isRecording;
    BOOL isDone;
    BOOL autoPlay;
    MP3Player *mpPlayer;
    NSDate *recordStartTime;
    NSDate *recordEndTime;
}

#define kRestartString NSLocalizedString(@"start over", nil);
#define kRecordString NSLocalizedString(@"Record", nil);

+ (AVCamInstructionsVC *) loadInstance
{
    UIStoryboard *sb = nil;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        sb = [UIStoryboard storyboardWithName:@"AVCamInstructionsVC.IPhone5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        sb = [UIStoryboard storyboardWithName:@"AVCamInstructionsVC.IPhone4" bundle:nil];
    }
    
    AVCamInstructionsVC *vc = [sb instantiateViewControllerWithIdentifier:@"AVCamInstructionsVC"];
    
    [vc initFromSB];
    
    return vc;
}

- (void) dealloc
{
    SubTemplate *obj = [self getSubTemplate];
    NSLog(@"dealloc AVCamInstructionsVC %@", obj.name);
    
    [_presentedInstructions removeAllObjects];
    _presentedInstructions = nil;
    
    [_instructions removeAllObjects];
    _instructions = nil;
    
    [_reusedInstructionViews removeAllObjects];
    _reusedInstructionViews = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setInstructions:(NSSet *)data
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    _instructions = [NSMutableArray arrayWithArray:[[data allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
    
    _presentedInstructions = [[NSMutableArray alloc] init];

    for (id dataElement in _instructions) {
        Instruction *inst = dataElement;
        if (![inst.hidden boolValue]) {
            [_presentedInstructions addObject:inst];
        }
    }
    
}

- (void) initFromSB
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _reusedInstructionViews = [NSMutableDictionary dictionary];
    isRecording = NO;
    isDone = NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.carousel.type = iCarouselTypeCustom;
    [self.carousel setScrollToItemBoundary:YES];
    
    self.pageControl.numberOfPages = [self numberOfItemsInCarousel:self.carousel];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"UIDeviceOrientation %ld", (long)orientation);

    [self configureViewLandscape];
    
    [self setRecordButtonHidden:YES];
    [self setRestartButtonHidden:YES];
    self.activityIndicator.hidden = YES;
    
    isDone = [self wereInstructionsCompleted];
    
    if (isDone) {
        [self insertDoneInstruction];
    }

    autoPlay = [self shouldAutoPlay];
    
    self.recordButton.showsTouchWhenHighlighted = YES;
    self.btnBack.showsTouchWhenHighlighted = YES;
    self.btnFlip.showsTouchWhenHighlighted = YES;
    self.btnRestart.showsTouchWhenHighlighted = YES;
    
    self.labelRecord.font = [UIFont fontWithName:kFontBold size:14];
    self.labelRecord.textColor = [UIColor whiteColor];
    self.labelRecord.text = kRecordString;
    
    self.btnRestart.titleLabel.font = [UIFont fontWithName:kFontBold size:14];
    self.btnRestart.titleLabel.textColor = [UIColor whiteColor];
    self.btnRestart.titleLabel.text = kRestartString;
    
    [self.viewEditText setSuperCtrl:self];
    [self.viewEditText setUserTextHints:[[self getSubTemplate] userTexts]];
    self.viewEditText.hidden = YES;
    
    mpPlayer = [[MP3Player alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"AVCamInstructionsVC: viewDidAppear");
    [super viewDidAppear:animated];
    
    // Adding observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FeedMakeOneNtfy:)
                                                 name:@"FeedMakeOneStart"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FeedMakeOneNtfy:)
                                                 name:@"FeedMakeOneDone"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"AVCamInstructionsVC: viewDidDisappear");
    [super viewDidDisappear:animated];
    // Removig observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"FeedMakeOneStart"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"FeedMakeOneDone"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SubTemplate *) getSubTemplate
{
    Instruction *inst = [_presentedInstructions firstObject];
    return inst.subTemplate;
}

- (void)configureViewLandscape
{
    NSLog(@"configureViewLandscape");
    if (self.viewEditText.hidden == YES) {
        self.landscapeView.hidden = NO;
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (void) moveToNextInstruction: (CGFloat) delay
{
    NSUInteger nextIndex = self.carousel.currentItemIndex + 1;
    
    if (nextIndex < self.carousel.numberOfItems) {
        
        [UIView animateWithDuration:delay
                         animations:^{
                             [self.carousel setAlpha:0.9];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self.carousel setAlpha:1.0];
                                 [self.carousel scrollToItemAtIndex:nextIndex animated:YES];
                             }
                         }];
        
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    CGFloat minOffset = -0.1f;
    CGFloat maxOffest = self.carousel.numberOfItems - 1 + 0.1f;
    //NSLog(@"carousel.scrollOffset = %f", carousel.scrollOffset);
    if (carousel.scrollOffset > maxOffest) {
        carousel.scrollOffset = maxOffest;
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex animated:YES];
    }
    if (carousel.scrollOffset < minOffset) {
        carousel.scrollOffset = minOffset;
        [self.carousel scrollToItemAtIndex:self.carousel.currentItemIndex animated:YES];
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSInteger count = [_presentedInstructions count];
    
    if (isDone) count++;
    
    _previousPage = count;

    NSLog(@"Number of instructions = %ld", (long)count);
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    InstructionCell *instructionItem = nil;
    NSLog(@"viewForItemAtIndex %ld", (long)index);
    //create new view if no view is available for recycling
    if (view == nil)
    {
        NSLog(@"Create a new view for index %ld",(long)index);
        instructionItem = [InstructionCell loadInstance];
        NSString *key = [NSString stringWithFormat:@"%p",instructionItem.view];
        [_reusedInstructionViews setObject:instructionItem forKey:key];
        NSLog(@"insert key %@", key);
        view = instructionItem.view;
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%p",view];
        NSLog(@"find key %@", key);
        instructionItem = [_reusedInstructionViews objectForKey:key];
        NSLog(@"Update the view for index %ld",(long)index);
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //[promotedView setImage:promotedTemplate.imageURL];
    //instructionItem.view.frame = self.carousel.frame;
    if (index == [_presentedInstructions count]) {
        NSLog(@"Insert DONE instruction");
        instructionItem.state = kInstructionDone;
    }
    
    instructionItem.superCtrl = self;
    instructionItem.instructions = _instructions;
    
    if (index < [_presentedInstructions count]) {
        instructionItem.currentInstruction = [_presentedInstructions objectAtIndex:index];
    } else {
        instructionItem.currentInstruction = nil;
    }
    
    instructionItem.index = index;
    [instructionItem configureItem: carousel];
    
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return nil;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    self.pageControl.currentPage = carousel.currentItemIndex;
    
    InstructionCell *item = [self getCurrentItem];
    if (item.state == kInstructionDone) {
        SubTemplate *sub = [self getSubTemplate];
        item.btnMakeVideo.enabled = (![sub.makeOneDisable boolValue]);
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    NSLog(@"carouselDidEndDecelerating: offset = %f", carousel.scrollOffset);
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if (isRecording) return;
    
    InstructionCell *instruction = [self getCurrentItem];
    NSLog(@"carouselDidEndScrollingAnimation");

    switch (instruction.state) {
        
        case kInstructionRecord:
        case kInstructionUnknown:
            [self configureCameraPosition];
            [self setRecordButtonStateRecord];
            break;
            
        case kInstructionFixed:
            [self setRecordButtonStateFixed];
            break;

        case kInstructionRetake:
            [self configureCameraPosition];
            [self setRecordButtonStateRetake];
            break;

        case kInstructionDone:
            [self setRecordButtonStateDone];
            break;

        default:
            break;
    }
    
    if (_previousPage != carousel.currentItemIndex) {
        
        [instruction currentlyPresented];
        
        //autoPlay = [self shouldAutoPlay];
        
        if (autoPlay) {
            
            switch (instruction.state) {
                case kInstructionDone:
                    [instruction playVideoList];
                    break;
                case kInstructionFixed:
                    [instruction playVideo];
                default:
                    break;
            }
        }
        
    }
    
    _previousPage = carousel.currentItemIndex;
    
}

- (void) videoPlayEnded
{
    if (autoPlay) {
    
        InstructionCell *instruction = [self getCurrentItem];
        
        switch (instruction.state) {
            case kInstructionDone:
                autoPlay = NO;
                break;
            case kInstructionFixed:
                [self moveToNextInstruction:0.25f];
            default:
                break;
        }
    }
}

- (void) startEditText
{
    [self setLockInterfaceRotation:YES];

    self.viewEditText.hidden = NO;
    self.viewEditText.userInteractionEnabled = YES;
    self.landscapeView.hidden = YES;
    self.landscapeView.userInteractionEnabled = NO;
    [self.viewEditText startEditText];
    
}

- (void) editTextEnded
{
    [self setLockInterfaceRotation:NO];

    [self.viewEditText endEditText];
    self.landscapeView.hidden = NO;
    self.landscapeView.userInteractionEnabled = YES;
    self.viewEditText.hidden = YES;
    self.viewEditText.userInteractionEnabled = NO;
    
    if (autoPlay) {
        [self moveToNextInstruction:0.75f];
    }

}

- (void)updateInstructionState
{
    [self carouselDidEndScrollingAnimation:self.carousel];
}

- (void) enableRecodring: (BOOL) enabled
{
    if (enabled) {
        [self setRecordButtonHidden:NO];
        self.recordButton.enabled = YES;
    } else {
        [self setRecordButtonHidden:YES];
        self.recordButton.enabled = NO;
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    if (carousel.numberOfItems == 1) return;

    NSLog(@"carouselWillBeginDragging");
    [self setRecordButtonStateDragging];
    beginOffset = carousel.scrollOffset;
    carousel.forceScrollDirection = 0;
    InstructionCell *item = [self getCurrentItem];
    [item currentlyDragging];
}

#define minDraggingToSwipe 0.02

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
    if (carousel.numberOfItems == 1) return;
    
    endOffset = carousel.scrollOffset;
    CGFloat diff = endOffset - beginOffset;
    NSLog(@"carouselDidEndDragging: offset-diff %f  offset %f", diff, carousel.scrollOffset);

    if (fabs(diff) > minDraggingToSwipe) {
        autoPlay = NO;
        NSLog(@"Auto play disabled");
    }
    
    // Dragging within bounds
    if (fabs(diff) < 0.5 && fabs(diff) > minDraggingToSwipe) {
        
        if (diff > 0) {
            if (carousel.currentItemIndex < carousel.numberOfItems - 1) {
                NSLog(@"Force move right");
                carousel.forceScrollDirection = 1;
            }
        } else {
            if (carousel.currentItemIndex > 0) {
                NSLog(@"Force move left");
                carousel.forceScrollDirection = -1;
            }
        }
        
    }
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    
    CGFloat spacing = [self carousel:self.carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f];
    transform = CATransform3DTranslate(transform, offset * self.carousel.itemWidth * spacing, 0.0f, 0.0f);
    
    CGFloat scaleFactor = 1.0f;
    CGFloat absOffest = ABS(offset);
    
    scaleFactor = 1 - absOffest;
    if (scaleFactor < 0.9f) scaleFactor = 0.9f;
    
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0f);
    return transform;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        
        case iCarouselOptionWrap:
        {
            //YES you would hard-code this to YES or NO
            return NO;
        }
            
        case iCarouselOptionVisibleItems:
        {
            return 3.0f;
        }
            
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * [InstructionCell getSpacingBetweenItems];
        }
        case iCarouselOptionFadeMax:
        {
            return 0.4f;
        }
            
        case iCarouselOptionFadeMin:
        {
            return -0.4f;
        }
            
        default:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (InstructionCell *) getCurrentItem
{
    NSString *key = [NSString stringWithFormat:@"%p",self.carousel.currentItemView];
    NSLog(@"find key %@", key);			
    InstructionCell *instructionItem = [_reusedInstructionViews objectForKey:key];
    return instructionItem;
}

- (Instruction *) getCurrentInstruction
{
    return [_presentedInstructions objectAtIndex:self.carousel.currentItemIndex];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Tapped view number: %ld", (long)index);
    InstructionCell *instructionItem = [self getCurrentItem];
    [instructionItem itemClicked];
}

#pragma mark -
#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
    NSString *sound;
    if (isRecording) {
        NSLog(@"toggleMovieRecording: end record");
        sound = @"camera_end";
    } else {
        NSLog(@"toggleMovieRecording: start record");
        sound = @"camera_start";
    }
    
    [mpPlayer playMP3FileNamed:sound completion:nil];
    
    [super toggleMovieRecording:nil];
}

- (void)btnRetakeClicked
{
    self.labelRecord.hidden = YES;
    [self toggleMovieRecording:nil];
}

- (IBAction)btnBackClicked:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [CoreData saveDB];
    [self.carousel scrollToItemAtIndex:0 animated:NO];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnRestartClicked:(id)sender {

    [self setRecordButtonHidden:YES];
    
    SubTemplate *subTemplate = [self getSubTemplate];
    [FileHelpers deleteFiles:subTemplate.instructions];
    
    Instruction *inst = nil;
    for (id dataElement in _presentedInstructions) {
        
        inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO) {
            inst.imageURL = nil;
            inst.videoURL = nil;
        }
    }
    
    for (id dataElement in [[self getSubTemplate] userTexts]) {
        UserText *userText = dataElement;
        userText.text = @"";
    }
    
    [self.viewEditText setUserTextHints:[[self getSubTemplate] userTexts]];
    
    [self deleteDoneInstruction];
    
    if (self.carousel.numberOfItems == 1) {
        InstructionCell *item = [self getCurrentItem];
        [item configureItem:self.carousel];	
    }
    
    isDone = NO;
    autoPlay = YES;
    inst.subTemplate.makeOneDisable = [NSNumber numberWithBool:NO];
    [CoreData saveDB];
}


- (void) deletePreviousRecordedFiles
{
    Instruction *inst = [self getCurrentInstruction];
    
    NSMutableArray *imageFiles = nil;
    NSMutableArray *videoFiles = nil;
    
    if ([inst.fixed boolValue] == NO)
    {
        if (inst.videoURL) {
            videoFiles = [[NSMutableArray alloc] init];
            [videoFiles addObject:inst.videoURL];
        }
        
        if (inst.imageURL) {
            imageFiles = [[NSMutableArray alloc] init];
            [imageFiles addObject:inst.imageURL];
        }
    }

    if (videoFiles) [FileHelpers deleteVideoFiles:videoFiles];
    if (imageFiles) [FileHelpers deleteImageFiles:imageFiles];
}

#pragma mark -
#pragma mark Actions (recording)

- (void)ntfyRecordStart
{
    // We were notified that the AVCam controller actualy started the recording
    NSLog(@"ntfyRecordStart");
    recordStartTime = [NSDate date];
    recordEndTime = [NSDate date];
    isRecording = YES;
    [self setRecordButtonStateRecording];
    [self setBackButtonHidden:YES];
    [self setCameraButtonHidden:YES];
    self.pageControl.hidden = YES;
    [self.carousel setAlpha:1];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self.carousel setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.carousel.hidden = YES;
                             [self startRecordAnimation];
                         }
                     }];
    
    SubTemplate *sub = [self getSubTemplate];

    sub.makeOneDisable = [NSNumber numberWithBool:NO];
}

- (void)ntfyRecordEnd
{
    // We were notified that the AVCam controller actualy ended the recording
    NSLog(@"ntfyRecordEnd");
    isRecording = NO;
    recordEndTime = [NSDate date];
    [self startBusyIndicator];
    [self stopRecordAnimation];
    [self setRecordButtonHidden:YES];
    self.pageControl.hidden = NO;
}

- (void) executeRecordEnd
{
    NSLog(@"executeRecordEnd");
    [self stopBusyIndicator];
    [self setBackButtonHidden:NO];
    [self setCameraButtonHidden:NO];
    
    BOOL validRecordLen = [self isValidRecordLength];
    if (validRecordLen) {
        // Recording is OK
        [self setRecordButtonStateRetake];
    } else {
        // Recording is too short: go back to the previous state
        [self updateInstructionState];
        [self showAlertForRecordLength];
    }
    
    [self.carousel setAlpha:0];
    self.carousel.hidden = NO;
    [UIView animateWithDuration:1.0f
                     animations:^{
                         [self.carousel setAlpha:1];
                     }];
}

- (void) startBusyIndicator
{
    NSLog(@"startBusyIndicator");
    self.carousel.scrollEnabled = NO;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}


- (void) stopBusyIndicator
{
    NSLog(@"stopBusyIndicator");
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    self.carousel.scrollEnabled = YES;
}

- (void) setRecordButtonStateRecord
{
    NSLog(@"setRecordButtonStateRecord");
    [self enableRecodring:YES];
    //[self setRecordButtonHidden:NO];
    [self setRestartButtonHidden:YES];
    
    [[self recordButton] setImage:[UIImage imageNamed:@"icon_record_off.png"] forState:UIControlStateNormal];

    CGPoint center = self.carousel.center;
    center.y = center.y + 10;
    self.recordButton.frame = CGRectMake(0, 0, 62, 62);
    self.recordButton.center = center;
    self.recordButton.titleLabel.text = nil;
}

- (void) setRecordButtonStateRecording
{
    [self setRestartButtonHidden:YES];
    [self setRecordButtonHidden:NO];
    
    [[self recordButton] setImage:[UIImage imageNamed:@"button_stop_off.png"] forState:UIControlStateNormal];
    
    self.recordButton.frame = CGRectMake(0, 0, 62, 62);
    self.recordButton.center = self.viewRecordTimer.center;
    self.labelRecord.hidden = YES;
}

- (void) setRecordButtonStateFixed
{
    [self enableRecodring:NO];
    [self setRestartButtonHidden:YES];
}

- (void) setRecordButtonStateRetake
{
    [self enableRecodring:NO];
}

- (void) setRecordButtonStateDone
{
    [self enableRecodring:NO];
    [self setRestartButtonHidden:NO];
}

- (void) setRecordButtonStateDragging
{
    [self enableRecodring:NO];
    [self setRestartButtonHidden:YES];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"RecordTimerAnimation"];
    if ([value isEqualToString:@"RecordTimerEnd"])
    {
        NSLog(@"Record animation ended");
        if (isRecording) {
            // Animation stoped on a timer
            NSLog(@"Record animation ended on a timer");
            [self toggleMovieRecording:nil];
        }
        return;
    }
}

-(void) stopRecordAnimation
{
    [[[self.viewRecordTimer.layer sublayers] lastObject] removeAllAnimations];
    [[[self.viewRecordTimer.layer sublayers] lastObject] removeFromSuperlayer];
}

- (void)setRecordButtonHidden: (BOOL) hidden
{
    self.recordButton.hidden = hidden;
    self.labelRecord.hidden = hidden;
}

- (void)setRestartButtonHidden: (BOOL) hidden
{
    self.btnRestart.hidden = hidden;
    self.labelRestart.hidden = hidden;
}

- (void)setBackButtonHidden: (BOOL) hidden
{
    self.btnBack.hidden = hidden;
    self.btnBack.enabled = !hidden;
}

- (void)setCameraButtonHidden: (BOOL) hidden
{
    self.cameraButton.hidden = hidden;
    self.cameraButton.enabled = !hidden;
}

#pragma mark -
#pragma mark Save recorded file

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)ntfyFileSaved: (NSURL *)outputFileURL
{
    NSLog(@"ntfyFileSaved");
    [self ntfyRecordEnd];

    BOOL validRecordLen = [self isValidRecordLength];
    if (!validRecordLen) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:&error];
        if (error) NSLog(@"%@", error);
        [self executeRecordEnd];
        return;
    }
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.outder.camerafiles",NULL);
    dispatch_async(myQueue, ^{
        
        NSString *fileGuid = [[NSUUID new] UUIDString];
        
        // Perform long running process
        NSURL *movieURL =  [self copyFileToAppDomain:outputFileURL in:fileGuid];
        
        NSString *thumbImageFile = nil;
        if (movieURL) {
            thumbImageFile = [self extractThumbnailImage:movieURL in:fileGuid];
        }
        
        [self deletePreviousRecordedFiles];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self executeRecordEnd];
            
            InstructionCell *cell = [self getCurrentItem];
            [cell configureUserShot:thumbImageFile withVideo:[movieURL absoluteString]];
            
            if (isDone == NO) {
                isDone = [self wereInstructionsCompleted];
                if (isDone) {
                    [self insertDoneInstruction];
                }
            }

            BOOL completed = [self wereInstructionsCompleted];
            if (completed && ![self.viewEditText isCompleted]) {
                NSLog(@"Open edit text dialog before DONE instruction");
                [self startEditText];
            } else {
                if (autoPlay) {
                    [self moveToNextInstruction:0.75f];
                }
            }
            
            if (!thumbImageFile) {
                NSString *title = NSLocalizedString(@"CAMERA ERROR", nil);
                NSString *message = NSLocalizedString(@"RETAKE THE SHOT", nil);
                NSString *btn = NSLocalizedString(@"OK", @"OK button title");

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:btn
                                                          otherButtonTitles:nil];
                [alertView show];
            }
           
        });
    });
    
    
}

- (NSURL *) copyFileToAppDomain: (NSURL *)outputFileURL in:(NSString *) fileGuid
{
    if (!outputFileURL) return nil;
    
    NSURL *homeDir = [self applicationDocumentsDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.mov", homeDir, fileGuid];
    NSURL *fileURL = [NSURL URLWithString:fullPath];
    NSError* error = nil;
    
    [[NSFileManager defaultManager] copyItemAtURL:outputFileURL toURL:fileURL error:&error];
    if (error) {
        NSLog(@"%@", error);
        fileURL = nil;
    }
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:&error];
    if (error) NSLog(@"%@", error);
    
    NSLog(@"Saved new recording file %@", fullPath);
    return fileURL;
}

- (NSString *) extractThumbnailImage: (NSURL *)movieURL in:(NSString *) fileGuid
{
    if (!movieURL) return nil;
    
    NSString *fileName = [NSString stringWithFormat:@"Documents/%@.jpg", fileGuid];
    NSString  *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:fileName];

    MPMoviePlayerController *movie = [[MPMoviePlayerController alloc]
                                      initWithContentURL:movieURL];
    movie.shouldAutoplay = NO;
    UIImage *singleFrameImage = [movie thumbnailImageAtTime:0
                                                 timeOption:MPMovieTimeOptionExact];
    	
    [UIImageJPEGRepresentation(singleFrameImage, 0.2f) writeToFile:fullPath atomically:YES];
    
    NSLog(@"Saved new image file %@", fullPath);
    
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
    if (!singleFrameImage) fullPath = nil;
    
    return fullPath;
}

#define kLineWidth 7

-(void)startRecordAnimation
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.viewRecordTimer.bounds.size.width/2.0, self.viewRecordTimer.bounds.size.height/2.0)  radius:self.viewRecordTimer.bounds.size.width/2.0 - kLineWidth/2 startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 1.0;
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor redColor] CGColor];
    shapeLayer.lineWidth = kLineWidth;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [self.viewRecordTimer.layer addSublayer:shapeLayer];
    Instruction *inst = [self getCurrentInstruction];
    float duration = [inst.length intValue];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    animateStrokeEnd.removedOnCompletion = YES;
    animateStrokeEnd.fillMode = kCAFillModeForwards;
    animateStrokeEnd.delegate = self;
    [animateStrokeEnd setValue:@"RecordTimerEnd" forKey:@"RecordTimerAnimation"];
    [shapeLayer addAnimation:animateStrokeEnd forKey:nil];
}


- (void) insertDoneInstruction
{
    self.pageControl.numberOfPages = self.pageControl.numberOfPages + 1;
    [self.carousel insertItemAtIndex:self.carousel.numberOfItems animated:NO];
}

- (void) deleteDoneInstruction
{
    self.pageControl.numberOfPages = self.pageControl.numberOfPages - 1;
    [self.carousel removeItemAtIndex:self.carousel.numberOfItems animated:NO];
    CGFloat duration = self.carousel.numberOfItems * 0.25f;
    [self.carousel scrollToItemAtIndex:0 duration:duration];
}

#pragma mark -
#pragma mark EVENTS

- (void) makeOneClicked
{
    [UIView animateWithDuration:0.75f
                     animations:^{
                         [self.carousel setAlpha:0.9];
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             [self.carousel setAlpha:1.0];
                             [self btnBackClicked:nil];
                         }
                     }];
}

#pragma mark -
#pragma mark DONE with instructions

- (BOOL) wereInstructionsCompleted
{
    if (isDone) return YES;
    
    BOOL completed = YES;
    
    Instruction *inst = nil;
    for (id dataElement in _presentedInstructions) {
        inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO) {
            NSLog(@"Checking completion of instruction: %d", [inst.id intValue]);
            if (inst.imageURL == nil) {
                NSLog(@"NOT completed");
                completed = NO;
                break;
            } else {
                NSLog(@"Completed");
            }
        }
    }
    
    if (completed) {
        NSLog(@"All instructions were completed");
    }

    return completed;
}

- (BOOL) shouldAutoPlay
{
    BOOL enabled = YES;
    
    Instruction *inst = nil;
    for (id dataElement in _presentedInstructions) {
        inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO) {
            
            if (inst.imageURL != nil) {
                NSLog(@"Auto play disabled");
                enabled = NO;
                break;
            }
        }
    }
    
    if (enabled) {
        NSLog(@"Auto play enabled");
    } else {
        NSLog(@"Auto play disabled");
    }
    
    return enabled;
}

- (void)FeedMakeOneNtfy:(NSNotification *)notification
{
    Feed *ntfyFeed = notification.object;
    SubTemplate *ntfySubTemplate = ntfyFeed.subTemplate;
    Instruction *inst = [_presentedInstructions firstObject];
    SubTemplate *subTemplate = inst.subTemplate;
    
    if (ntfySubTemplate == subTemplate) {
        InstructionCell *item = [self getCurrentItem];
        if ([ntfyFeed.progress intValue] == 0) {
            ntfySubTemplate.makeOneDisable = [NSNumber numberWithBool:YES];
        }
        [item updateMakeOneCount];
    }
}

#pragma mark -
#pragma mark CAMERA positions

- (void) configureCameraPosition
{
    Instruction *inst = [self getCurrentInstruction];
    if ([inst.selfi boolValue] == YES) {
        [self setCameraFront];
    } else {
        [self setCameraBack];
    }
}


- (void) setCameraFront {
    AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];

    switch (currentPosition)
    {
        case AVCaptureDevicePositionBack:
            [self changeCamera:nil];
            break;
        case AVCaptureDevicePositionFront:
        case AVCaptureDevicePositionUnspecified:
            break;
    }
}

- (void) setCameraBack
{
    AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
    AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionBack:
            break;
        case AVCaptureDevicePositionFront:
        case AVCaptureDevicePositionUnspecified:
            [self changeCamera:nil];
            break;
    }
}

#pragma mark Alerts

- (BOOL) isValidRecordLength
{
    Instruction *inst = [self getCurrentInstruction];
    CGFloat minDuration = [inst.minlength intValue];
    NSTimeInterval diff = [recordEndTime timeIntervalSinceDate:recordStartTime];
    NSLog(@"Recorded duration is %f", diff);
    
    if (minDuration && diff < minDuration) {
        return NO;
    }
    return YES;
}

- (void) showAlertForRecordLength
{
    Instruction *inst = [self getCurrentInstruction];
    int minDuration = [inst.minlength intValue];
    NSString *title = NSLocalizedString(@"RECORDING ALERT", nil);
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"MINIMUM SHOT LENGTH IS %d SECOND. PLEASE RECORD AGAIN", nil), minDuration] ;
    NSString *btn = NSLocalizedString(@"OK", @"OK button title");
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                        delegate:nil
                                                cancelButtonTitle:btn
                                                otherButtonTitles:nil];
    [alertView show];
}


@end
