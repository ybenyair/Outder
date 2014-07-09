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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelRotate.text = NSLocalizedString(@"Record in landscape mode", nil);
    self.carousel.type = iCarouselTypeCustom;
    _reusedInstructionViews = [NSMutableDictionary dictionary];
    _currentPage = 0;

    [self registerToDeviceOrientationNotification];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsPortrait(orientation)) {
        [self configureViewPortrait];
    } else {
        [self configureViewLandscape];
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
     NSLog(@"carousel.scrollOffset = %f", carousel.scrollOffset);
     NSInteger maxOffest = [_promotedTemplates count] - 1;
     if (carousel.scrollOffset > maxOffest) carousel.scrollOffset = maxOffest;
     if (carousel.scrollOffset < 0.0f) carousel.scrollOffset = 0.0f;
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
        instructionItem = [[InstructionCell alloc] init];
        NSString *key = [NSString stringWithFormat:@"%p",instructionItem.view];
        [_reusedInstructionViews setObject:instructionItem forKey:key];
        view = instructionItem.view;
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%p",view];
        instructionItem = [_reusedInstructionViews objectForKey:key];
        NSLog(@"Update the view for index %ld",(long)index);
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //[promotedView setImage:promotedTemplate.imageURL];
    //instructionItem.view.frame = self.carousel.frame;
    
    [instructionItem configureItem:instruction inView:carousel];
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
    //self.pageControl.currentPage = carousel.currentItemIndex;
}


- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    
    CGFloat spacing = [self carousel:self.carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f];
    transform = CATransform3DTranslate(transform, offset * self.carousel.itemWidth * spacing, 0.0f, 0.0f);
    
    CGFloat scaleFactor = 1.15f;
    
    CGFloat absOffest = ABS(offset);
    if (absOffest > 0) scaleFactor = 1 - absOffest;
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
            return YES;
        }
            
        case iCarouselOptionVisibleItems:
        {
            return 3.0f;
        }
            
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.04f;
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //NSNumber *item = (self.items)[index];
    NSLog(@"Tapped view number: %ld", (long)index);
}


#pragma mark -
#pragma mark Actions

- (IBAction)btnBackClicked:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

@end
