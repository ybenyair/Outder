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
#import "Defines.h"
#import "UploadManager.h"
#import "CoreData.h"

@interface RootViewController ()

@end

@implementation RootViewController
{
    UploadManager *_uploadManager;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tabController, myVideoVC, featuredVideoVC;

static RootViewController *instance = nil;

-(BOOL)shouldAutorotate
{
    //I don't want to support auto rotate, but you can return any value you want here
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    //I want to only support portrait mode
    return UIInterfaceOrientationMaskPortrait;
}

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
        
        _uploadManager = [[UploadManager alloc] initWithContext:app.managedObjectContext];
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
        [self startDashboardViewController:YES withTab:1];
    } else {
        [self startLoginViewController:YES];
    }
    [_uploadManager resumePendingUploads];
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
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = [AppDelegate getInstance].window.frame.size.width;
    frame.size.height = [AppDelegate getInstance].window.frame.size.height;
    
    UIView *splashView = [[UIView alloc] initWithFrame:frame];
    UIImage* imageLogo = [UIImage imageNamed:@"logo.png"];
    UIImageView *splashImage = [[UIImageView alloc] initWithImage:imageLogo];
    splashImage.contentMode = UIViewContentModeScaleAspectFit;
    frame.size.height = 40;
    frame.size.width = 144;
    splashImage.frame = frame;
    
    [splashView addSubview:splashImage];
    splashImage.center = splashView.center;
    
    splashView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    splashImage.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [self.view addSubview:splashView];
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
    LoginViewController *lvc = [LoginViewController loadInstance];
    lvc.managedObjectContext = self.managedObjectContext;
    [self setActiveView:lvc];
}

- (void)startDashboardViewController: (BOOL)refreshData withTab:(NSUInteger)index
{
    tabController = [[UITabBarController alloc] init];
    
    TemplatesVC *homevc = [[TemplatesVC alloc] init];
    homevc.managedObjectContext = self.managedObjectContext;
    homevc.tabBarItem.title = @"Home";
    homevc.tabBarItem.image	 = [UIImage imageNamed:@"home"];
    UINavigationController *navhome = [[UINavigationController alloc] init];
    [navhome pushViewController:homevc animated:NO];
    navhome.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];
    
    myVideoVC = [[FeedTableViewController alloc] init];
    myVideoVC.managedObjectContext = self.managedObjectContext;
    myVideoVC.tabBarItem.title = @"My Video";
    myVideoVC.feedType = kMyVideoType;
    myVideoVC.tabBarItem.image	 = [UIImage imageNamed:@"myvideos"];
    [myVideoVC loadData];
    UINavigationController *navmyvideo = [[UINavigationController alloc] init];
    [navmyvideo pushViewController:myVideoVC animated:NO];
    navmyvideo.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    featuredVideoVC = [[FeedTableViewController alloc] init];
    featuredVideoVC.managedObjectContext = self.managedObjectContext;
    featuredVideoVC.tabBarItem.title = @"Featured";
    featuredVideoVC.feedType = kFeaturedVideoType;
    featuredVideoVC.tabBarItem.image	 = [UIImage imageNamed:@"featured"];
    [featuredVideoVC loadData];
    UINavigationController *navfeatured = [[UINavigationController alloc] init];
    [navfeatured pushViewController:featuredVideoVC animated:NO];
    navfeatured.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    [tabController setViewControllers:[NSArray arrayWithObjects:navmyvideo,navhome, navfeatured, nil] animated:YES];
    
    tabController.selectedViewController=[tabController.viewControllers objectAtIndex:index];
    tabController.tabBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];
    
    if (refreshData) {
        [self getTemplates];
    } else {
        [self setActiveView:tabController];
    }
}

- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data
{
    NSString *response = (NSString *)data;
    NSLog(@"Response for %@", response);
    if (code == kCommOK) {
        //[TemplateCoreData clearDB:self.managedObjectContext];
        [TemplateCoreData fillTemplates:self.managedObjectContext data:json];
        [CoreData saveDB];
        [self setActiveView:tabController];
    } else if (code == kCommErrorNetwork) {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error. Trying again...", nil);
        NSLog(@"%@", alertMessage);
        [self getTemplates];
    }
}

- (void)getTemplates
{
    ServerCommunication *templateComm = [[ServerCommunication alloc] init];
    templateComm.delegate = self;
    [templateComm setUserData:@"templates"];
    [templateComm getTemplates];
}

- (void)handleNotification: (NSDictionary*)ntfy
{
    NSString *value = myVideoVC.tabBarItem.badgeValue;
    NSInteger intValue = [value intValue];
    intValue++;
    value = [NSString stringWithFormat:@"%ld", (long)intValue];
    myVideoVC.tabBarItem.badgeValue = value;
}

@end
