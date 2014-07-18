//
//  RootViewController.h
//  Outder
//
//  Created by Yossi on 6/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "FeedTableViewController.h"

@interface RootViewController : UIViewController <ServerCommunicationDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITabBarController *tabController;
@property (strong, nonatomic) FeedTableViewController *myVideoVC;
@property (strong, nonatomic) FeedTableViewController *featuredVideoVC;

+ (RootViewController *)getInstance;
- (void)startLoginViewController:(BOOL)logOut;
- (void)startDashboardViewController: (BOOL)refreshData withTab:(NSUInteger)index;
- (void)start;
- (void)handleNotification: (NSDictionary*)ntfy;

@end
