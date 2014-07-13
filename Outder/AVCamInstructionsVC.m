//
//  AVCamInstructionsVC.m
//  Outder
//
//  Created by Yossi on 7/9/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "AVCamInstructionsVC.h"
#import "InstructionCell.h"

@interface AVCamInstructionsVC ()

@end

@implementation AVCamInstructionsVC
{
    NSMutableArray *_instructions;
    NSMutableDictionary *_reusedInstructionViews;
    NSInteger _currentPage;
    CGFloat beginOffset;
    CGFloat endOffset;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.carousel.type = iCarouselTypeCustom;
    [self.carousel setScrollToItemBoundary:NO];
    _currentPage = 0;

    [self registerToDeviceOrientationNotification];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation) ) {
        [self configureViewLandscape];
    } else {
        [self configureViewPortrait];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    /*
    CGFloat diff = carousel.scrollOffset - carousel.currentItemIndex;
    NSLog(@"carousel.scrollOffset = %f diff = %f", carousel.scrollOffset, diff);
    
    if (diff > 0.02 && !carousel.scrolling)
    {
        NSLog(@"Move to index %ld", (long)carousel.currentItemIndex + 1);
        [self.carousel scrollToOffset:(carousel.currentItemIndex + 1) duration:0.5];
        //[self.carousel scrollByNumberOfItems:1 duration:0.1f];
    }
    
    if (diff < -0.02 && !carousel.scrolling)
    {
        NSLog(@"Move to index %ld", (long)carousel.currentItemIndex - 1);
        [self.carousel scrollToOffset:(carousel.currentItemIndex - 1) duration:0.5];
    }
     */
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSInteger count = [_instructions count];
    NSLog(@"Number of instructions = %ld", (long)count);
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    InstructionCell *instructionItem = nil;
    Instruction *instruction = [_instructions objectAtIndex:index];
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
    instructionItem.superCtrl = self;
    [instructionItem configureItem:instruction inView:carousel withIndex:index];
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

}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    Instruction *instruction = [_instructions objectAtIndex:carousel.currentItemIndex];
    
    if ([instruction.fixed boolValue] == YES)
    {
        self.recordButton.hidden = YES;
        self.recordButton.enabled = NO;
        
        
    } else {
        self.recordButton.hidden = NO;
        self.recordButton.enabled = YES;
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    self.recordButton.hidden = YES;
    self.recordButton.enabled = NO;
    beginOffset = carousel.scrollOffset;
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
    endOffset = carousel.scrollOffset;
    if (endOffset > beginOffset) {
        [self.carousel scrollByNumberOfItems:1 duration:0.5f];
    } else {
        [self.carousel scrollByNumberOfItems:-1 duration:0.5f];
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
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

- (void) btnRecordClicked
{
    [self toggleMovieRecording:nil];
}


#pragma mark -
#pragma mark Actions (recording)

- (void)ntfyRecordStart
{
    // We were notified that the AVCam controller actualy started the recording
    NSLog(@"ntfyRecordStart");
    [[self recordButton] setImage:[UIImage imageNamed:@"recBtn3.png"] forState:UIControlStateNormal];
    self.recordButton.center = self.viewRecordTimer.center;
    
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
}

- (void)ntfyRecordEnd
{
    // We were notified that the AVCam controller actualy ended the recording
    NSLog(@"ntfyRecordEnd");
    [[self recordButton] setImage:[UIImage imageNamed:@"recBtn1.png"] forState:UIControlStateNormal];
    CGPoint center = self.carousel.center;
    center.y = center.y + 10;
    self.recordButton.center = center;
    [self stopRecordAnimation];

    [self.carousel setAlpha:0];
    self.carousel.hidden = NO;

    [self.recordButton setAlpha:0];

    [UIView animateWithDuration:1.5f
                     animations:^{
                         [self.carousel setAlpha:1];
                         [self.recordButton setAlpha:1];
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             
                         }
                     }];
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
    
    float duration = 5;
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = duration;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    animateStrokeEnd.removedOnCompletion = YES;
    animateStrokeEnd.fillMode = kCAFillModeForwards;
    [shapeLayer addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
}

-(void) stopRecordAnimation
{
    [[[self.viewRecordTimer.layer sublayers] lastObject] removeAllAnimations];
    [[[self.viewRecordTimer.layer sublayers] lastObject] removeFromSuperlayer];
}

@end
