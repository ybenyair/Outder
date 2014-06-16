//
//  FeedTableViewController.h
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface FeedTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
