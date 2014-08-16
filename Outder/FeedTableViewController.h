//
//  FeedTableViewController.h
//  Outder
//
//  Created by Yossi on 6/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "ServerCommunication.h"
#import "TitleNavBarVC.h"

@interface FeedTableViewController : TitleNavBarVC <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, ServerCommunicationDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    // First time to load data
    BOOL loading;
    // Pull down to refresh
    BOOL _reloading;
    // Scrolled till the end of feed list
    BOOL loadingMore;
}

@property (nonatomic,strong) NSString* feedType;
@property (nonatomic,strong) NSString* lastFeedTime;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *loadingMoreView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingMoreIndicator;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)loadData;
- (void)resetScroll;

@end
