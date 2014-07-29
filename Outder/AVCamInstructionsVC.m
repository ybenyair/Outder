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

@interface AVCamInstructionsVC ()

@end

@implementation AVCamInstructionsVC
{
    NSMutableArray *_instructions;
    NSMutableDictionary *_reusedInstructionViews;
    NSInteger _currentPage;
    CGFloat beginOffset;
    CGFloat endOffset;
    BOOL isRecording;
    BOOL isDone;
}

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
}

- (void) initFromSB
{
    _reusedInstructionViews = [NSMutableDictionary dictionary];
    isRecording = NO;
    isDone = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.carousel.type = iCarouselTypeCustom;
    [self.carousel setScrollToItemBoundary:YES];
    _currentPage = 0;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation) ) {
        [self configureViewLandscape];
    } else {
        [self configureViewPortrait];
    }

    self.pageControl.numberOfPages = [self numberOfItemsInCarousel:self.carousel];
    
    [self setRecordButtonHidden:YES];
    [self setRestartButtonHidden:YES];
    
    isDone = [self wereInstructionsCompleted];
    
    if (isDone) {
        [self insertDoneInstruction];
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"AVCamInstructionsVC: viewDidAppear");
    [super viewDidAppear:animated];
    [self registerToDeviceOrientationNotification];
    
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
    [self deregisterToDeviceOrientationNotification];
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
    Instruction *inst = [_instructions firstObject];
    return inst.subTemplate;
}

#pragma mark - device orientation handling

- (void) registerToDeviceOrientationNotification
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) deregisterToDeviceOrientationNotification
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            /* start special animation */
            NSLog(@"Landscape left");
            [self configureViewLandscape];
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"Portrait");
            [self configureViewPortrait];
            break;
            
        default:
            break;
    };
}


- (void)configureViewPortrait
{
    self.portraitView.hidden = NO;
    self.landscapeView.hidden = YES;
}

- (void)configureViewLandscape
{
    self.portraitView.hidden = YES;
    self.landscapeView.hidden = NO;
}

#pragma mark -
#pragma mark iCarousel methods

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
    NSInteger count = [_instructions count];
    
    if (isDone) count++;
    
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
    if (index == [_instructions count]) {
        NSLog(@"Insert DONE instruction");
        instructionItem.state = kInstructionDone;
    }
    
    instructionItem.superCtrl = self;
    instructionItem.instructions = _instructions;
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
    
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    InstructionCell *instruction = [self getCurrentItem];
    NSLog(@"carouselDidEndScrollingAnimation");

    switch (instruction.state) {
        
        case kInstructionRecord:
        case kInstructionUnknown:
            [self setRecordButtonStateRecord];
            break;
            
        case kInstructionFixed:
            [self setRecordButtonStateFixed];
            break;

        case kInstructionRetake:
            [self setRecordButtonStateRetake];
            break;

        case kInstructionDone:
            [self setRecordButtonStateDone];
            break;

        default:
            break;
    }
    
}

- (void)updateInstructionState
{
    [self carouselDidEndScrollingAnimation:self.carousel];
}

- (void) enableRecodring: (BOOL) enabled
{
    if (enabled) {
        self.recordButton.hidden = NO;
        self.recordButton.enabled = YES;
    } else {
        self.recordButton.hidden = YES;
        self.recordButton.enabled = NO;
    }
}
- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    [self setRecordButtonStateDragging];
    beginOffset = carousel.scrollOffset;
    carousel.forceScrollDirection = 0;
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
    endOffset = carousel.scrollOffset;
    CGFloat diff = endOffset - beginOffset;
    NSLog(@"carouselDidEndDragging: offset-diff %f  offset %f", diff, carousel.scrollOffset);

    // Dragging within bounds
    if (fabs(diff) < 0.5 && fabs(diff) > 0.05) {
        
        if (diff > 0) {
            if (carousel.currentItemIndex < carousel.numberOfItems - 1) carousel.forceScrollDirection = 1;
        } else {
            if (carousel.currentItemIndex > 0) carousel.forceScrollDirection = -1;
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
    return [_instructions objectAtIndex:self.carousel.currentItemIndex];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"Tapped view number: %ld", (long)index);
    InstructionCell *instructionItem = [self getCurrentItem];
    [instructionItem itemClicked];
}

#pragma mark -
#pragma mark Actions

- (IBAction)btnBackClicked:(id)sender
{
    [CoreData saveDB];
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)btnRestartClicked:(id)sender {

    [self deleteFiles];

    Instruction *inst = nil;
    for (id dataElement in _instructions) {
        
        inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO) {
            inst.imageURL = nil;
            inst.videoURL = nil;
        }
    }
    
    [self deleteDoneInstruction];
    
    isDone = NO;
    inst.subTemplate.makeOneDisable = [NSNumber numberWithBool:NO];
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

    if (videoFiles) [self deleteVideoFiles:videoFiles];
    if (imageFiles) [self deleteImageFiles:imageFiles];
}

- (void) deleteFiles
{
    NSMutableArray *imageFiles = [[NSMutableArray alloc] init];
    NSMutableArray *videoFiles = [[NSMutableArray alloc] init];

    for (id dataElement in _instructions) {
        Instruction *inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO)
        {
            if (inst.videoURL) [videoFiles addObject:inst.videoURL];
            if (inst.imageURL) [imageFiles addObject:inst.imageURL];
        }
    }
    
    [self deleteVideoFiles:videoFiles];
    [self deleteImageFiles:imageFiles];
}

- (void) deleteVideoFiles: (NSMutableArray *)files
{
    NSLog(@"Video files to delete: %ld", (long)[files count]);
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.outder.deletevideofiles",NULL);
    dispatch_async(myQueue, ^{
        
        for (id dataElement in files) {
            NSString *file = (NSString *)dataElement;
            NSError* error = nil;
            NSURL *url = [NSURL URLWithString:file];
            NSLog(@"Delete video file %@", url);
            [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSLog(@"Done removinging video files");
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
    });
}

- (void) deleteImageFiles: (NSMutableArray *)files
{
    NSLog(@"Image files to delete: %ld", (long)[files count]);
    
    dispatch_queue_t myQueue = dispatch_queue_create("com.outder.deleteimagefiles",NULL);
    dispatch_async(myQueue, ^{
        
        for (id dataElement in files) {
            NSString *file = (NSString *)dataElement;
            NSError* error = nil;
            NSLog(@"Delete image file %@", file);
            [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
            
            if (error) {
                NSLog(@"%@", error);
            }
        }
        
        NSLog(@"Done removinging images files");

        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);

    });
}

#pragma mark -
#pragma mark Actions (recording)

- (void)ntfyRecordStart
{
    // We were notified that the AVCam controller actualy started the recording
    NSLog(@"ntfyRecordStart");
    isRecording = YES;
    [self setRecordButtonStateRecording];
    [self.carousel setAlpha:1];
    
    [UIView animateWithDuration:0.5f
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
    [self setRecordButtonStateRetake];
    [self stopRecordAnimation];

    [self.carousel setAlpha:0];
    self.carousel.hidden = NO;

    [self.recordButton setAlpha:0];

    [UIView animateWithDuration:1.5f
                     animations:^{
                         [self.carousel setAlpha:1];
                         [self.recordButton setAlpha:1];
                     }];
}


- (void) setRecordButtonStateRecord
{
    [self enableRecodring:YES];
    self.btnRestart.hidden = YES;
    [[self recordButton] setImage:[UIImage imageNamed:@"recBtn1.png"] forState:UIControlStateNormal];
    CGPoint center = self.carousel.center;
    center.y = center.y + 10;
    self.recordButton.frame = CGRectMake(0, 0, 38, 38);
    self.recordButton.center = center;
}

- (void) setRecordButtonStateRecording
{
    self.btnRestart.hidden = YES;
    [[self recordButton] setImage:[UIImage imageNamed:@"recBtn3.png"] forState:UIControlStateNormal];
    self.recordButton.frame = CGRectMake(0, 0, 38, 38);
    self.recordButton.center = self.viewRecordTimer.center;
}

- (void) setRecordButtonStateFixed
{
    [self enableRecodring:NO];
    self.btnRestart.hidden = YES;
}

- (void) setRecordButtonStateRetake
{
    [self enableRecodring:YES];
    self.btnRestart.hidden = YES;
    [[self recordButton] setImage:[UIImage imageNamed:@"icon_retake_off.png"] forState:UIControlStateNormal];
    CGPoint center = self.carousel.center;
    center.y = center.y + 80;
    self.recordButton.frame = CGRectMake(0, 0, 27, 22);
    self.recordButton.bounds = CGRectMake(0, 0, 27, 22);
    self.recordButton.center = center;
}

- (void) setRecordButtonStateDone
{
    [self enableRecodring:NO];
    self.btnRestart.hidden = NO;
    
}

- (void) setRecordButtonStateDragging
{
    [self enableRecodring:NO];
    self.btnRestart.hidden = YES;
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
}

- (void)setRestartButtonHidden: (BOOL) hidden
{
    self.btnRestart.hidden = hidden;
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
            InstructionCell *cell = [self getCurrentItem];
            [cell configureUserShot:thumbImageFile withVideo:[movieURL absoluteString]];
            
            if (isDone == NO) {
                isDone = [self wereInstructionsCompleted];
                if (isDone) {
                    [self insertDoneInstruction];
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

#define kLineWidth 6

-(void)startRecordAnimation
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.viewRecordTimer.bounds.size.width/2.0, self.viewRecordTimer.bounds.size.height/2.0)  radius:self.viewRecordTimer.bounds.size.width/2.0 - kLineWidth/2 startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    
    shapeLayer.strokeStart = 0.0;
    shapeLayer.strokeEnd = 1.0;
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
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
    [self.carousel scrollToItemAtIndex:0 animated:YES];
}

#pragma mark -
#pragma mark DONE with instructions

- (BOOL) wereInstructionsCompleted
{
    if (isDone) return YES;
    
    BOOL completed = YES;
    
    Instruction *inst = nil;
    for (id dataElement in _instructions) {
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

- (void)FeedMakeOneNtfy:(NSNotification *)notification
{
    Feed *ntfyFeed = notification.object;
    SubTemplate *ntfySubTemplate = ntfyFeed.subTemplate;
    Instruction *inst = [_instructions firstObject];
    SubTemplate *subTemplate = inst.subTemplate;
    
    if (ntfySubTemplate == subTemplate) {
        InstructionCell *item = [self getCurrentItem];
        if ([ntfyFeed.progress intValue] == 0) {
            ntfySubTemplate.makeOneDisable = [NSNumber numberWithBool:YES];
        }
        [item updateMakeOneCount];
    }
}

@end