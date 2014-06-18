//
//  RootViewController.h
//  Outder
//
//  Created by Yossi on 6/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (RootViewController *)getInstance;
- (void)startLoginViewController:(BOOL)logOut;
- (void)startDashboardViewController;
- (void)start;

@end