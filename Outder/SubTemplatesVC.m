//
//  SubTemplateViewController.m
//  Outder
//
//  Created by Yossi on 6/30/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "SubTemplatesVC.h"
#import "SubTemplateCell.h"
#import "Template.h"
#import "SubTemplate.h"
#import "AVCamInstructionsVC.h"
#import "AVCamViewController.h"
#import "Defines.h"

@interface SubTemplatesVC ()

@end

@implementation SubTemplatesVC
{
    NSMutableArray *_subTemplates;
    NSMutableDictionary *_reusedSubTemplateViews;
    NSInteger _previousPage;
    BOOL autoPlayVideo;
    CGFloat beginOffset;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSubTemplates:(NSSet *)data
{
    if (self = [super init]) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        _subTemplates = [NSMutableArray arrayWithArray:[[data allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _reusedSubTemplateViews = [NSMutableDictionary dictionary];
    self.pageControl.numberOfPages = [_subTemplates count];
    self.tabBarController.tabBar.hidden = YES;
    autoPlayVideo = YES;
    self.carousel.decelerationRate = 0.45;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    NSLog(@"dealloc SubTemplatesVC");
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.carousel scrollToItemAtIndex:(self.carousel.currentItemIndex + 1) animated:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void) backClicked: (id) sender
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.view.alpha = 0.9f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             [self.navigationController popViewControllerAnimated:NO];
                             self.view.alpha = 1.0f;
                         }
                     }
     ];

}

- (void) setNavBarView
{
    SubTemplate *sub = [_subTemplates firstObject];
    self.navigationItem.titleView = nil;
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:kFontBlack size:24];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    self.navigationItem.titleView = titleView;
    titleView.text = [sub.template.title uppercaseString];
    [titleView sizeToFit];
}

- (void) setBarItemRight
{
    CGRect frame = CGRectMake(0, 0, 20, 20);
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //then set it.  phew.
    self.navigationItem.rightBarButtonItem = barButtonItem;
}


#pragma mark -
#pragma mark iCarousel methods

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    SubTemplateCell *item = [self getCurrentItem];
    beginOffset = carousel.scrollOffset;
    carousel.forceScrollDirection = 0;
    [item currentlyDragged];
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
    /*
    CGFloat endOffset = carousel.scrollOffset;
    CGFloat diff = endOffset - beginOffset;
    if (diff > 1) {
        diff =  diff - round(diff);
    }
    
    NSLog(@"carouselDidEndDragging: offset-diff %f  offset %f", diff, carousel.scrollOffset);
    
    // Dragging within bounds
    if (fabs(diff) < 0.5 && fabs(diff) > 0.05) {
        if (diff > 0) {
            NSLog(@"Force move right");
            carousel.forceScrollDirection = 1;
        } else {
            NSLog(@"Force move left");
            carousel.forceScrollDirection = -1;
        }
    }
    */
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    SubTemplateCell *item = [self getCurrentItem];
    
    if (_previousPage != carousel.currentItemIndex) {
        _previousPage = carousel.currentItemIndex;
        [item setAutoPlay:autoPlayVideo];
        autoPlayVideo = NO; // Only once
        [item currentlyPresented];
    }
}

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
    NSInteger count = [_subTemplates count];
    NSLog(@"Number of sub templates = %ld", (long)count);
    _previousPage = count;
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    SubTemplateCell *subTemplateItem = nil;
    SubTemplate *subTemplate = [_subTemplates objectAtIndex:index];
    NSLog(@"viewForItemAtIndex %ld", (long)index);
    //create new view if no view is available for recycling
    if (view == nil)
    {
        NSLog(@"Create a new view for index %ld",(long)index);
        subTemplateItem = [SubTemplateCell loadInstance];
        subTemplateItem.view.frame = carousel.frame;
        subTemplateItem.view.bounds = carousel.bounds;
        
        subTemplateItem.delegate = self;
        NSString *key = [NSString stringWithFormat:@"%p",subTemplateItem.view];
        [_reusedSubTemplateViews setObject:subTemplateItem forKey:key];
        view = subTemplateItem.view;
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%p",view];
        subTemplateItem = [_reusedSubTemplateViews objectForKey:key];
        NSLog(@"Update the view for index %ld",(long)index);
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //[promotedView setImage:promotedTemplate.imageURL];
    [subTemplateItem configureItem:subTemplate inView:carousel];
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

- (SubTemplateCell *) getCurrentItem
{
    NSString *key = [NSString stringWithFormat:@"%p",self.carousel.currentItemView];
    NSLog(@"find key %@", key);
    SubTemplateCell *subTemplateItem = [_reusedSubTemplateViews objectForKey:key];
    return subTemplateItem;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    self.pageControl.currentPage = carousel.currentItemIndex;
}


- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    
    CGFloat spacing = [self carousel:self.carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f];
    transform = CATransform3DTranslate(transform, offset * self.carousel.itemWidth * spacing, 0.0f, 0.0f);
    
    CGFloat scaleFactor = 1.0f;
    
    /*
     CGFloat absOffest = ABS(offset);
     if (absOffest > 0) scaleFactor = 1 - absOffest;
     if (scaleFactor < 0.9f) scaleFactor = 0.9f;
     */
    
    transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1.0f);
    return transform;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
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
            return 0.8f;
        }
            
        case iCarouselOptionFadeMin:
        {
            return -0.8f;
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
#pragma mark SubTemplateCellDelegate

- (void)makeOneClicked:(SubTemplate *)subTemplate
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    AVCamInstructionsVC *vc = [AVCamInstructionsVC loadInstance];
    [vc setInstructions:subTemplate.instructions];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)clearPresentedViewControllers
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
