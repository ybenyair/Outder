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
#import "UserInfo+Login.h"
#import "CustomNavigationController.h"
#import "RootViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (void) viewDidAppear:(BOOL)animated
{
    
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
}

- (void)pushDashboard
{
    [[RootViewController getInstance] startDashboardViewController];
}

- (void)communicationResponse:(NSDictionary *)json userInfo:(UserInfo *)info
                 responseCode:(eCommResponseCode)code
{
    [DejalBezelActivityView removeViewAnimated:YES];

    if (code == kCommOK) {
        [UserInfo userLoggedIn:self.managedObjectContext userInfo:info];
        [self pushDashboard];
    } else {
        NSString *alertMessage = NSLocalizedString(@"Internet connection error", nil);
        NSString *alertTitle = NSLocalizedString(@"Login failed", nil);
        [self presentErrorMessage:alertMessage title:alertTitle];
    }
}

- (void)login:(UserInfo *)userInfo
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Login...", nil)];

    ServerCommunication *loginComm = [[ServerCommunication alloc] init];
    loginComm.delegate = self;
    [loginComm sendLogin:userInfo];
    
}


// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"Fetching user information");
    
    UserInfo *userInfo = [UserInfo getUserInfo:self.managedObjectContext];
    if ([userInfo.isValid boolValue] == NO) {
        
        userInfo.userName = [NSString stringWithFormat:@"%@",user.name];
        userInfo.facebookID = [NSString stringWithFormat:@"%@",user.objectID];
        userInfo.emailAddress =[user objectForKey:@"email"];
        userInfo.isValid = [NSNumber numberWithBool:YES];
        
        [self login:userInfo];
       
    }
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"ShowingLoggedInUser");
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [UserInfo userLoggedOut:self.managedObjectContext];
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
    TermOfUseViewController *touvc = [[TermOfUseViewController alloc]init];
    [self.navigationController pushViewController:touvc animated: YES];
}

- (IBAction)guestLoginClicked:(UIButton *)sender
{
    UserInfo *userInfo = [UserInfo getUserInfo:self.managedObjectContext];
    userInfo.userName = [NSString stringWithFormat:@"GUEST"];
    userInfo.emailAddress = kGuestEmail;
    userInfo.isValid = [NSNumber numberWithBool:YES];
    [self login:userInfo];
}

- (IBAction)playVideoClicked:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    NSURL *url;
    
    url = [NSURL URLWithString:@"http://d167cgw0so9a1a.cloudfront.net/media/loginsamplevideo.mp4"];

    MPMoviePlayerViewController *mpMoviewPlayerCon = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:mpMoviewPlayerCon];
    
    [mpMoviewPlayerCon.moviePlayer play];

}

-(void)MPMoviePlayerPlaybackDidFinishNotification:(NSNotification*)notif {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

@end
