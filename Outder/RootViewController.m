//
//  RootViewController.m
//  Outder
//
//  Created by Yossi on 6/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "FeedTableViewController.h"
#import "TemplatesVC.h"
#import "AppDelegate.h"
#import "LoginInfo.h"
#import "TemplateCoreData.h"
#import "DejalActivityView.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tabController;

static RootViewController *instance = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        instance = self;
        AppDelegate *app = [AppDelegate getInstance];
        instance.managedObjectContext = app.managedObjectContext;
        [self initSplashView];
        
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor viewFlipsideBackgroundColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBarTintColor:[UIColor viewFlipsideBackgroundColor]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];

    }
    
    return self;
}

+ (RootViewController *)getInstance;
{
    if (!instance) {
        instance = [[RootViewController alloc] init];
    }
    return instance;
}

- (void)start
{
    LoginInfo *loginInfo = [LoginInfo getInstance];
    if (loginInfo.isValid) {
        [self setSplashView];
        [self startDashboardViewController];
    } else {
        [self startLoginViewController:YES];
    }
}

- (void)viewDidLoad
{
    [DejalBezelActivityView activityViewForView:self.view  withLabel:NSLocalizedString(@"Loading...", nil)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void) initSplashView
{

    UIImage* imageDefault = [UIImage imageNamed:@"splash.jpg"];
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = [AppDelegate getInstance].window.frame.size.width;
    frame.size.height = [AppDelegate getInstance].window.frame.size.height;
    
    UIImageView *splash = [[UIImageView alloc] initWithFrame:frame];
    splash.contentMode = UIViewContentModeScaleAspectFit;
    
    [splash setImage:imageDefault];
    [self.view addSubview:splash];
    [self.view sendSubviewToBack:splash];
    
}

- (void)setActiveView: (UIViewController *)viewController
{
    AppDelegate *app = [AppDelegate getInstance];
    app.window.rootViewController = viewController;
    [app.window makeKeyAndVisible];
}


- (void)setSplashView
{
    AppDelegate *app = [AppDelegate getInstance];
    app.window.rootViewController = self;
    [app.window makeKeyAndVisible];
}

- (void)startLoginViewController:(BOOL)logOut;
{
    if (logOut) {
        [LoginViewController signOutFacebook];
    }
    LoginViewController *lvc = [[LoginViewController alloc] init];
    lvc.managedObjectContext = self.managedObjectContext;
    UINavigationController *navcon = [[UINavigationController alloc] init];
    [navcon pushViewController:lvc animated:YES];
    [self setActiveView:navcon];
}

- (void)startDashboardViewController
{
    tabController = [[UITabBarController alloc] init];
    
    TemplateViewController *homevc = [[TemplateViewController alloc] init];
    homevc.managedObjectContext = self.managedObjectContext;
    homevc.tabBarItem.title = @"Home";
    homevc.tabBarItem.image	 = [UIImage imageNamed:@"home"];
    UINavigationController *navhome = [[UINavigationController alloc] init];
    [navhome pushViewController:homevc animated:NO];
    navhome.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];
    
    FeedTableViewController *myvideovc = [[FeedTableViewController alloc] init];
    myvideovc.managedObjectContext = self.managedObjectContext;
    myvideovc.tabBarItem.title = @"My Video";
    myvideovc.feedType = @"MyVideo";
    myvideovc.tabBarItem.image	 = [UIImage imageNamed:@"myvideos"];
    [myvideovc loadData];
    UINavigationController *navmyvideo = [[UINavigationController alloc] init];
    [navmyvideo pushViewController:myvideovc animated:NO];
    navmyvideo.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    FeedTableViewController *featuredvideovc = [[FeedTableViewController alloc] init];
    featuredvideovc.managedObjectContext = self.managedObjectContext;
    featuredvideovc.tabBarItem.title = @"Featured";
    featuredvideovc.feedType = @"FeaturedVideo";
    featuredvideovc.tabBarItem.image	 = [UIImage imageNamed:@"featured"];
    [featuredvideovc loadData];
    UINavigationController *navfeatured = [[UINavigationController alloc] init];
    [navfeatured pushViewController:featuredvideovc animated:NO];
    navfeatured.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    [tabController setViewControllers:[NSArray arrayWithObjects:navmyvideo,navhome, navfeatured, nil] animated:YES];
    
    tabController.selectedViewController=[tabController.viewControllers objectAtIndex:1];
    tabController.tabBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];
    
    [self getTemplates];
}

- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data
{
    NSString *response = (NSString *)data;
    NSLog(@"Response for %@", response);
    if (code == kCommOK) {
        [TemplateCoreData clearDB:self.managedObjectContext];
        [TemplateCoreData fillTemplates:self.managedObjectContext data:json];
        [self setActiveView:tabController];
    } else {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error", nil);
        NSLog(@"%@", alertMessage);
    }
}

- (void)getTemplates
{
    ServerCommunication *templateComm = [[ServerCommunication alloc] init];
    templateComm.delegate = self;
    [templateComm setUserData:@"templates"];
    [templateComm getTemplates];
}

@end
