//
//  CustomNavigationController.m
//  Outder
//
//  Created by Yossi on 6/10/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "CustomNavigationController.h"
#import "LoginViewController.h"
#import "DashboardViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

@synthesize supprtedOrientations;
@synthesize managedObjectContext;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.BarTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate; //you are asking your current controller what it should do
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

+ (void)startLoginViewController:(UINavigationController *)navcon logOut:(BOOL)logOut;
{
    if (logOut) {
        [LoginViewController signOutFacebook];
    }
    CustomNavigationController *nav = (CustomNavigationController *)navcon;

    LoginViewController *lvc = [[LoginViewController alloc] init];
    lvc.managedObjectContext = nav.managedObjectContext;
    [nav setViewControllers:[NSArray arrayWithObject:lvc] animated:YES];
}

+ (void)startDashboardViewController:(UINavigationController *)navcon
{
    CustomNavigationController *nav = (CustomNavigationController *)navcon;
    DashboardViewController *dvc = [[DashboardViewController alloc] init];
    dvc.managedObjectContext = nav.managedObjectContext;
    [nav setViewControllers:[NSArray arrayWithObject:dvc] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
