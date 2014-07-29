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
    _currentPage = 0;
    self.pageControl.numberOfPages = [_subTemplates count];
    [self setBackNavigationBarItems];
    [self setNavigationBarTitle];
    self.tabBarController.tabBar.hidden = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void) backClicked: (id) sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) setNavigationBarTitle
{
    SubTemplate *sub = [_subTemplates firstObject];
    
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:kFontBlack size:24];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = [UIColor whiteColor]; // Change to desired color
        
        self.navigationItem.titleView = titleView;
    
    }
    titleView.text = [sub.template.title uppercaseString];
    [titleView sizeToFit];
}

- (void) setBackNavigationBarItems
{
    //create the image for your button, and set the frame for its size
    UIImage *imageOff = [UIImage imageNamed:@"back_off"];
    UIImage *imagePress = [UIImage imageNamed:@"back_press"];
    CGRect frame = CGRectMake(0, 0, 20, 20);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:imageOff forState:UIControlStateNormal];
    [button setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

#pragma mark -
#pragma mark iCarousel methods

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    SubTemplateCell *item = [self getCurrentItem];
    [item currentlyPresented];
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
#pragma mark SubTemplateCellDelegate

- (void)makeOneClicked:(SubTemplate *)subTemplate
{
    AVCamInstructionsVC *vc = [AVCamInstructionsVC loadInstance];
    [vc setInstructions:subTemplate.instructions];
    [self presentViewController:vc animated:YES completion:^{}];
}

@end
