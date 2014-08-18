//
//  CreateViewController.m
//  Outder
//
//  Created by Yossi on 6/24/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TemplatesVC.h"
#import "TemplateCell.h"
#import "Template.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TemplatePromotedCell.h"
#import "TemplateCoreData.h"
#import "SubTemplatesVC.h"
#import "Defines.h"

@interface PromotedTemplate : NSObject {
    NSInteger templateID;
}

@property (nonatomic) NSInteger templateID;
@property (nonatomic,strong) NSString *imageURL;
@end

@implementation PromotedTemplate
@synthesize imageURL;
@synthesize templateID;
@end


@interface TemplatesVC ()

@end

@implementation TemplatesVC
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    NSMutableArray *_promotedTemplates;
    NSMutableDictionary *_reusedPromotedViews;
    NSInteger _currentPage;
}

@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

static NSString *CellIdentifier = @"templateCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    _promotedTemplates = [NSMutableArray array];
    _reusedPromotedViews = [NSMutableDictionary dictionary];
    
    [self setPromotedTemplates];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TemplateCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.centerItemWhenSelected = NO;
    
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    
    self.carousel.decelerationRate = 0.45;
}

- (void) dealloc
{

}


- (void) setBarItemLeft
{
    CGRect frame = CGRectMake(0, 0, 20, 20);
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //then set it.  phew.
    self.navigationItem.leftBarButtonItem = barButtonItem;
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

- (void) setNavBarView
{
    self.navigationItem.titleView = nil;
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:kFontBlack size:24];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    self.navigationItem.titleView = titleView;
    titleView.text = NSLocalizedString(@"CREATE A VIDEO", nil);
    [titleView sizeToFit];
}

- (void) setPromotedTemplates
{
    NSArray *promotedTemplates = [TemplateCoreData getPromotedTemplates:managedObjectContext];
    
    for (id dataElement in promotedTemplates) {
        PromotedTemplate *promotedTemplate = [[PromotedTemplate alloc] init];
        promotedTemplate.imageURL = ((Template *)dataElement).imageURL;
        promotedTemplate.templateID = [((Template *)dataElement).id intValue];
        NSLog(@"Promoted id: %ld Image: %@", (long)promotedTemplate.templateID, promotedTemplate.imageURL);
        [_promotedTemplates addObject:promotedTemplate];
    }

    self.pageControl.numberOfPages = [_promotedTemplates count];
    NSLog(@"Set number of pages = %ld", (long)self.pageControl.numberOfPages);
    _currentPage = 0;
    [self.carousel reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
    _objectChanges = nil;
    _sectionChanges = nil;
    _promotedTemplates = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if (scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    }
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TemplateCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Template *template = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    [myCell configureCell: template];

    return myCell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    Template *template = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Select cell %@", template.title);
    [self createSubTemplatesViewController:template];
}


#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [NSFetchedResultsController deleteCacheWithName:@"Template"];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"promoted = 0"];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Template" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"order" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Template"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
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
    NSInteger count = [_promotedTemplates count];
    NSLog(@"Promoted templates count = %ld", (long)count);
    return count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    TemplatePromotedCell *promotedView = nil;
    PromotedTemplate *promotedTemplate = [_promotedTemplates objectAtIndex:index];
    NSLog(@"viewForItemAtIndex %ld", (long)index);
    //create new view if no view is available for recycling
    if (view == nil)
    {
        NSLog(@"Create a new view for index %ld",(long)index);
        promotedView = [[TemplatePromotedCell alloc] init];
        NSString *key = [NSString stringWithFormat:@"%p",promotedView.view];
        [_reusedPromotedViews setObject:promotedView forKey:key];
        view = promotedView.view;
    }
    else
    {
        NSString *key = [NSString stringWithFormat:@"%p",view];
        promotedView = [_reusedPromotedViews objectForKey:key];
        NSLog(@"Update the view for index %ld",(long)index);
    }
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    [promotedView setImage:promotedTemplate.imageURL];
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
            return value * 1.02f;
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
    PromotedTemplate *promotedTemplate = [_promotedTemplates objectAtIndex:index];
    Template *template = [TemplateCoreData getTemplate:managedObjectContext byId:promotedTemplate.templateID];
    NSLog(@"Tapped view number: %ld with title: %@", (long)index, template.title);
    [self createSubTemplatesViewController:template];
}


#pragma mark -
#pragma mark Creating a SubTemplatesViewController

-(void) createSubTemplatesViewController: (Template *)template
{
    if ([template.subTemplates count] > 0) {
        SubTemplatesVC *subCtrl = [[SubTemplatesVC alloc] initWithSubTemplates:template.subTemplates];
        [self.navigationController pushViewController:subCtrl animated:NO];
    } else {
        NSLog(@"Empty template %@", template.title);
    }
}


-(void) removeSubTemplatesViewController
{
    SubTemplatesVC *subCtrl = (SubTemplatesVC *)[self.navigationController popViewControllerAnimated:YES];
    [subCtrl clearPresentedViewControllers];
    subCtrl = nil;
}


@end
