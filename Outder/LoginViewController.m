//
//  LoginViewController.m
//  Outder
//
//  Created by Yossi on 6/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomNavigationController.h"
#import "TermOfUseViewController.h"
#import "Defines.h"
#import "DejalActivityView.h"
#import "LoginInfo.h"
#import "CustomNavigationController.h"
#import "RootViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    DejalActivityView *dejalActivityView;
}

@synthesize managedObjectContext;
@synthesize videoCtrl;

+ (LoginViewController *) loadInstance
{
    UIStoryboard *sb = nil;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        sb = [UIStoryboard storyboardWithName:@"LoginViewController.iPhone5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        sb = [UIStoryboard storyboardWithName:@"LoginViewController.iPhone4" bundle:nil];
    }
    
    LoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
    return vc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"LoginViewController: viewDidAppear");
    [self getVideoReady];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [dejalActivityView animateRemove];
    dejalActivityView = nil;
    NSLog(@"LoginViewController: viewDidDisappear");
    [videoCtrl stopVideo:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSLog(@"LoginViewController: applicationDidBecomeActive");
    [self.videoCtrl pauseVideo:NO];
}

+ (void)signOutFacebook
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.fbLoginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.fbLoginView.loginBehavior = FBSessionLoginBehaviorForcingSafari;
    
    self.viewImageBG.backgroundColor = [UIColor viewFlipsideBackgroundColor];
}

-(BOOL)shouldAutorotate
{
    //I don't want to support auto rotate, but you can return any value you want here
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    //I want to only support portrait mode
    return UIInterfaceOrientationMaskPortrait;
}

- (void)pushDashboard
{
    [[RootViewController getInstance] startDashboardViewController:YES withTab:1];
}

- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data
{
    if (code == kCommOK) {
        NSLog(@"Login...[OK]");
        LoginInfo *info = (LoginInfo *)data;
        [info storeLoggedIn];
        [self pushDashboard];
    } else {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error", nil);
        NSString *alertTitle = NSLocalizedString(@"Login failed", nil);
        [self presentErrorMessage:alertMessage title:alertTitle];
    }
}

- (void)login:(LoginInfo *)loginInfo
{
    NSLog(@"Login...");
    dejalActivityView = [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Login...", nil)];
    [dejalActivityView animateShow];
    
    ServerCommunication *loginComm = [[ServerCommunication alloc] init];
    loginComm.delegate = self;
    [loginComm setUserData:loginInfo];
    [loginComm sendLogin:loginInfo];
}


// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"Fetching user information");
    LoginInfo *loginInfo = [LoginInfo getInstance];
    [self.videoCtrl pauseVideo:NO];
    if (!loginInfo.isValid) {
        loginInfo.userName = [NSString stringWithFormat:@"%@",user.name];
        loginInfo.facebookID = [NSString stringWithFormat:@"%@",user.objectID];
        loginInfo.emailAddress =[user objectForKey:@"email"];
        loginInfo.isValid = YES;
        [self login:loginInfo];
    }
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"ShowingLoggedInUser");
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    LoginInfo *loginInfo = [LoginInfo getInstance];
    [loginInfo storeLoggedOut];
}

- (void) presentErrorMessage: (NSString *)alertMessage title:(NSString *)alertTitle
{
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = NSLocalizedString(@"Facebook error", nil);
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = NSLocalizedString(@"Facebook error", nil);
        alertMessage = NSLocalizedString(@"Session is no longer valid. Please log in again", nil);
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle = NSLocalizedString(@"Facebook error", nil);
        alertMessage = NSLocalizedString(@"Please try again later.",nil);
        NSLog(@"Unexpected error:%@", error);
    }
    
    [self presentErrorMessage:alertMessage title:alertTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)termOfUseClicked:(UIButton *)sender
{
    UINavigationController *nav = [[UINavigationController alloc] init];
    TermOfUseViewController *touvc = [[TermOfUseViewController alloc]init];
    [nav pushViewController:touvc animated:YES];
    [self presentViewController:nav animated:YES completion:^{[videoCtrl stopVideo:NO];}];
}

- (IBAction)guestLoginClicked:(UIButton *)sender
{
    LoginInfo *loginInfo = [LoginInfo getInstance];
    loginInfo.userName = [NSString stringWithFormat:@"GUEST"];
    loginInfo.emailAddress = kGuestEmail;
    loginInfo.isValid = YES;
    [self login:loginInfo];
}


- (void) getVideoReady
{
    if (videoCtrl) {
        [videoCtrl stopVideo:NO];
    }
    // Release the previous video player and allocate a new one
    videoCtrl = nil;
    videoCtrl = [[VideoPlayerViewController alloc] init];
    videoCtrl.enableAutoRotation = NO;
    [videoCtrl setDelegate:self withInfo:nil];
    // PLay the video
    NSString *url = @"http://d167cgw0so9a1a.cloudfront.net/C1/Feed/LoginClip.mp4";
    [videoCtrl prepareVideo:url inView:self.viewVideo];
    [videoCtrl muteVideo:YES];
    [videoCtrl repeatVideo:YES];
}

- (void) videoReady:(id)userInfo
{
    self.viewVideo.alpha = 0.0f;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.viewVideo.alpha = 1.0f;
                     }];
    
    [videoCtrl playWhenPrepared:self.viewVideo];
}

- (void) videoClosed:(id)userInfo
{
    
}

@end
