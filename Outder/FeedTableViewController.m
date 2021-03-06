//
//  FeedTableViewController.m
//  Outder
//
//  Created by Yossi on 6/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedTableViewController.h"
#import "Feed.h"
#import "FeedTableViewCell.h"
#import "RootViewController.h"
#import "FeedCoreData.h"
#import "ServerCommunication.h"
#import "DejalActivityView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Defines.h"

#define kDefaultTime @"9999-12-31 00:00:00"

@interface FeedTableViewController ()

@end

@implementation FeedTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;
@synthesize feedType;
@synthesize lastFeedTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loading = NO;
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
    NSLog(@"Load view %@", self.tabBarItem.title);
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self loadMoreTableViewDataSourceEnd];
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height - 5, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.viewOffset = 64.0;
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        
    }
    
    lastFeedTime = kDefaultTime;
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;

    //[DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Loading...", nil)];
    //[self reloadTableViewDataSourceStart];
}

#pragma mark - override Navigation bar settiog

- (void) setBarItemRight
{
    //create the image for your button, and set the frame for its size
    CGRect frame = CGRectMake(0, 0, 40, 40);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = [UIFont fontWithName:kFontBold size:12];
    [button setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
    button.titleLabel.textColor = [FontHelpers colorFromHexString:@"#41beb1"];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(logoutClicked:) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    if ([self.feedType isEqualToString:kFeaturedVideoType]) {
        button.hidden = YES;
        button.enabled = NO;
    }
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

- (void) setNavBarView
{
    self.navigationItem.titleView = nil;
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:kFontBlack size:24];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleView.textColor = [UIColor whiteColor]; // Change to desired color
    self.navigationItem.titleView = titleView;
    if ([self.feedType isEqualToString:kMyVideoType]) {
        titleView.text = NSLocalizedString(@"MY VIDEOS", nil);
    } else {
        titleView.text = NSLocalizedString(@"POPULAR VIDEOS", nil);
    }
    [titleView sizeToFit];
}

- (void) logoutClicked: (id) sender
{
    RootViewController *root = [RootViewController getInstance];
    [root startLoginViewController: YES];
}

- (void)loadData
{
    loading = YES;
    ServerCommunication *comm = [[ServerCommunication alloc] init];
    comm.delegate = self;
    [comm getFeeds: kDefaultTime feedType:feedType];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSourceStart
{
    _reloading = YES;
    lastFeedTime = kDefaultTime;
    [FeedCoreData clearDB:managedObjectContext feedType:feedType];
    [self performSelector:@selector(reloadTableViewDataSource) withObject:nil afterDelay:1.0];
}

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    ServerCommunication *comm = [[ServerCommunication alloc] init];
    comm.delegate = self;
    [comm getFeeds:lastFeedTime feedType:feedType];
}

- (void)reloadTableViewDataSourceEnd
{
    _reloading = NO;
    [DejalBezelActivityView removeViewAnimated:YES];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)loadMoreTableViewDataSourceStart
{
    loadingMore = YES;
    self.loadingMoreView.hidden = NO;
    self.loadingMoreView.alpha = 0.0;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.loadingMoreView.alpha = 1.0;
                     }];
    
    [self.loadingMoreIndicator startAnimating];
    [self performSelector:@selector(loadMoreTableViewDataSource) withObject:nil afterDelay:1.0];
}

- (void)loadMoreTableViewDataSource
{
    ServerCommunication *comm = [[ServerCommunication alloc] init];
    comm.delegate = self;
    [comm getFeeds:lastFeedTime feedType:feedType];
}

- (void)loadMoreTableViewDataSourceEnd
{
    loadingMore = NO;
    self.loadingMoreView.hidden = YES;
    [self.loadingMoreIndicator stopAnimating];
}

- (void)doneLoadingTableViewData{
    
    if (_reloading) {
        [self reloadTableViewDataSourceEnd];
    }
    
    if (loadingMore) {
        [self loadMoreTableViewDataSourceEnd];
    }
    
    if (loading) {
        loading = NO;
    }
}

- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data
{
    if (code == kCommOK) {
        //[FeedCoreData setFeedTestData: managedObjectContext feedType:feedType];
        [FeedCoreData fillFeeds:managedObjectContext data:json feedType:feedType];
        [self doneLoadingTableViewData];
    } else {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error", nil);
        NSString *alertTitle = NSLocalizedString(@"Failed refreshing feed", nil);
        NSLog(@"%@: %@",alertTitle, alertMessage);
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if ((scrollView.contentSize.height > 0) && (endScrolling >= scrollView.contentSize.height + 20))
    {
        if (!loadingMore && !_reloading) {
            NSLog(@"More data...");
            [self loadMoreTableViewDataSourceStart];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSourceStart];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)resetScroll
{
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *myCell = (FeedTableViewCell *)cell;
    Feed *feed = [_fetchedResultsController objectAtIndexPath:indexPath];
    [myCell configureCell:feed];
    myCell.superCtrl = self;
    lastFeedTime = feed.time;
    NSLog(@"lastFeedTime = %@", lastFeedTime);
}

#pragma mark - Table view data source (setting the tap gesture)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"feedCell";
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"FeedTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:cell atIndexPath:indexPath];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [NSFetchedResultsController deleteCacheWithName:feedType];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type = %@", feedType];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Feed" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"time" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:feedType];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            if (indexPath) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
