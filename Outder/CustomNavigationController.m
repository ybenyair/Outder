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
#import "FeedViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController
static CustomNavigationController* instace = nil;

@synthesize supprtedOrientations;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    instace = self;
    return self;
}

+ (CustomNavigationController *)getInstance
{
    return instace;
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

- (void)startLoginViewController:(BOOL)logOut;
{
    if (logOut) {
        [LoginViewController signOutFacebook];
    }
    LoginViewController *lvc = [[LoginViewController alloc] init];
    lvc.managedObjectContext = self.managedObjectContext;
    [self setViewControllers:[NSArray arrayWithObject:lvc] animated:YES];
}

- (void) signOutClicked
{
    [self startLoginViewController: YES];
}

- (void) setNavigationBarItems: (UITabBarController *)tbc
{
    //create the image for your button, and set the frame for its size
    UIImage *image = [UIImage imageNamed:@"signOut"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(signOutClicked) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    [tbc.navigationItem setRightBarButtonItem:barButtonItem];
}

- (void)startDashboardViewController
{
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    DashboardViewController *homevc = [[DashboardViewController alloc] init];
    homevc.managedObjectContext = self.managedObjectContext;
    homevc.tabBarItem.title = @"Home";
    homevc.tabBarItem.image	 = [UIImage imageNamed:@"home"];
    
    FeedViewController *myvideovc = [[FeedViewController alloc] init];
    myvideovc.managedObjectContext = self.managedObjectContext;
    myvideovc.tabBarItem.title = @"My Video";
    myvideovc.tabBarItem.image	 = [UIImage imageNamed:@"myvideos"];
    
    FeedViewController *featuredvideovc = [[FeedViewController alloc] init];
    featuredvideovc.managedObjectContext = self.managedObjectContext;
    featuredvideovc.tabBarItem.title = @"Featured";
    featuredvideovc.tabBarItem.image	 = [UIImage imageNamed:@"featured"];
    
    tbc.viewControllers = [NSArray arrayWithObjects:myvideovc,homevc, featuredvideovc, nil];
    
    CustomNavigationController *cnc = [CustomNavigationController getInstance];
    [cnc setNavigationBarItems:tbc];
    
    [self setViewControllers:[NSArray arrayWithObject:tbc] animated:YES];
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
