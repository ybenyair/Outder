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
@synthesize tabController, myVideoVC, featuredVideoVC, templatesVC;

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
    
    // Adding observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MakeOne:)
                                                 name:@"MakeOne"
                                               object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void) dealloc
{
    // Adding observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MakeOne"
                                                  object:nil];
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
    tabController = [[CustomTabBarVC alloc] init];
    
    templatesVC = [[TemplatesVC alloc] init];
    templatesVC.managedObjectContext = self.managedObjectContext;
    //templatesVC.tabBarItem.title = NSLocalizedString(@"Create", nil);
    templatesVC.tabBarItem.image = [[UIImage imageNamed:@"tabs_create_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    templatesVC.tabBarItem.selectedImage = [UIImage imageNamed:@"tabs_create_on"];
    
    UINavigationController *navhome = [[UINavigationController alloc] init];
    [navhome pushViewController:templatesVC animated:NO];
    navhome.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];
    
    myVideoVC = [[FeedTableViewController alloc] init];
    myVideoVC.managedObjectContext = self.managedObjectContext;
    //myVideoVC.tabBarItem.title = NSLocalizedString(@"My Video", nil);
    myVideoVC.feedType = kMyVideoType;
    myVideoVC.tabBarItem.image = [[UIImage imageNamed:@"tabs_myvideos_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    myVideoVC.tabBarItem.selectedImage = [UIImage imageNamed:@"tabs_myvideos_on"];
    
    
    UINavigationController *navmyvideo = [[UINavigationController alloc] init];
    [navmyvideo pushViewController:myVideoVC animated:NO];
    navmyvideo.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    featuredVideoVC = [[FeedTableViewController alloc] init];
    featuredVideoVC.managedObjectContext = self.managedObjectContext;
    //featuredVideoVC.tabBarItem.title = NSLocalizedString(@"Popular", nil);
    featuredVideoVC.feedType = kFeaturedVideoType;
    featuredVideoVC.tabBarItem.image = [[UIImage imageNamed:@"tabs_popular_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    featuredVideoVC.tabBarItem.selectedImage = [UIImage imageNamed:@"tabs_popular_on"];
    
    UINavigationController *navfeatured = [[UINavigationController alloc] init];
    [navfeatured pushViewController:featuredVideoVC animated:NO];
    navfeatured.navigationController.navigationBar.BarTintColor = [UIColor viewFlipsideBackgroundColor];

    [tabController setViewControllers:[NSArray arrayWithObjects:navfeatured ,navhome, navmyvideo, nil] animated:YES];
    
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
        [myVideoVC loadData];
        [featuredVideoVC loadData];
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


- (void)MakeOne:(NSNotification *)notification
{
    self.tabController.selectedIndex = 2;
    [self.myVideoVC resetScroll];
    [self.templatesVC removeSubTemplatesViewController];
}

@end
