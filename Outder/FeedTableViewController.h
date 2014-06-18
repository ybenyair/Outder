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

@interface FeedTableViewController : UIViewController <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, ServerCommunicationDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (nonatomic,strong) NSString* feedType;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
