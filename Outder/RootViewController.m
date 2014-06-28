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
#import "TemplateViewController.h"
#import "AppDelegate.h"
#import "UserInfo+Login.h"
#import "TemplateCoreData.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize managedObjectContext = _managedObjectContext;

static RootViewController *instance = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        instance = self;
        AppDelegate *app = [AppDelegate getInstance];
        instance.managedObjectContext = app.managedObjectContext;
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
    UserInfo *userInfo = [UserInfo getUserInfo:self.managedObjectContext];
    if ([userInfo.isValid boolValue] == YES) {
        [self startDashboardViewController];
    } else {
        [self startLoginViewController:YES];
    }
}

- (void)setActiveView: (UIViewController *)viewController
{
    AppDelegate *app = [AppDelegate getInstance];
    app.window.rootViewController = viewController;
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
    [self getTemplates];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    TemplateViewController *homevc = [[TemplateViewController alloc] init];
    homevc.managedObjectContext = self.managedObjectContext;
    homevc.tabBarItem.title = @"Home";
    homevc.tabBarItem.image	 = [UIImage imageNamed:@"home"];
    UINavigationController *navhome = [[UINavigationController alloc] init];
    [navhome pushViewController:homevc animated:NO];
    
    FeedTableViewController *myvideovc = [[FeedTableViewController alloc] init];
    myvideovc.managedObjectContext = self.managedObjectContext;
    myvideovc.tabBarItem.title = @"My Video";
    myvideovc.feedType = @"MyVideo";
    myvideovc.tabBarItem.image	 = [UIImage imageNamed:@"myvideos"];
    UINavigationController *navmyvideo = [[UINavigationController alloc] init];
    [navmyvideo pushViewController:myvideovc animated:NO];
    
    FeedTableViewController *featuredvideovc = [[FeedTableViewController alloc] init];
    featuredvideovc.managedObjectContext = self.managedObjectContext;
    featuredvideovc.tabBarItem.title = @"Featured";
    featuredvideovc.feedType = @"FeaturedVideo";
    featuredvideovc.tabBarItem.image	 = [UIImage imageNamed:@"featured"];
    UINavigationController *navfeatured = [[UINavigationController alloc] init];
    [navfeatured pushViewController:featuredvideovc animated:NO];
    
    [tbc setViewControllers:[NSArray arrayWithObjects:navmyvideo,navhome, navfeatured, nil] animated:YES];
    
    [self setActiveView:tbc];
}

- (void)communicationResponse:(NSDictionary *)json userInfo:(UserInfo *)info
                 responseCode:(eCommResponseCode)code
{

    //[DejalBezelActivityView removeViewAnimated:YES];
    
    if (code == kCommOK) {
        [TemplateCoreData clearDB:self.managedObjectContext];
        [TemplateCoreData fillTemplates:self.managedObjectContext data:json];
    } else {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error", nil);
        NSLog(@"%@", alertMessage);
    }
}

- (void)getTemplates
{
    //[DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Login...", nil)];
    UserInfo *userInfo = [UserInfo getUserInfo:self.managedObjectContext];
    ServerCommunication *templateComm = [[ServerCommunication alloc] init];
    templateComm.delegate = self;
    [templateComm getTemplates:userInfo];
}

@end
