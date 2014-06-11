//
//  LoginViewController.m
//  Outder
//
//  Created by Yossi on 6/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "LoginViewController.h"
#import "DashboardViewController.h"
#import "TermOfUseViewController.h"
#import "Constants.h"
#import "DejalActivityView.h"
#import "UserInfo+Login.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize closingFBSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)pushDashboard
{
    DashboardViewController *dvc = [[DashboardViewController alloc] init];
    [dvc initManagedObjectContext:self.managedObjectContext];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:dvc] animated:YES];
}

- (NSError *)login:(UserInfo *)userInfo
{
    NSError *error = nil;
    NSString *deviceUdid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *methodWithParams = [kLogin stringByAppendingFormat:@"?%@=%@&%@=%@&%@=%@&%@=%@",kEmail,@"",kPassword,kDefaultPassword,kCompanyid,kCompanyDefaultId,kDid,deviceUdid];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kOutderURL,methodWithParams];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response;
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:NSLocalizedString(@"Login...", nil)];
    
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // check for an error. If there is a network error, you should handle it here.
    if(!error)
    {
        //log response
        NSLog(@"Response from server = %@", responseString);
    }
    [DejalBezelActivityView removeViewAnimated:NO];
    return error;
}


// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"Fetching user information %d", closingFBSession);
    
    UserInfo *userInfo = [UserInfo getUserInfo:self.managedObjectContext];
    if ([userInfo.isValid boolValue] == NO) {
        
        userInfo.userName = [NSString stringWithFormat:@"%@",user.name];
        userInfo.facebookID = [NSString stringWithFormat:@"%@",user.objectID];
        userInfo.isValid = [NSNumber numberWithBool:YES];
        
        NSError *error = [self login:userInfo];
        if (error == nil) {
            [UserInfo userLoggedIn:self.managedObjectContext userInfo:userInfo];
            [self pushDashboard];
        }
    }
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"ShowingLoggedInUser %d", closingFBSession);

}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [UserInfo userLoggedOut:self.managedObjectContext];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
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
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
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
    if ([userInfo.isValid boolValue] == NO) {
        
        userInfo.userName = [NSString stringWithFormat:@"GUEST"];
        userInfo.isValid = [NSNumber numberWithBool:YES];

        NSError *error = [self login:userInfo];
        if (error == nil) {
            [UserInfo userLoggedIn:self.managedObjectContext userInfo:userInfo];
            [self pushDashboard];
        }
    }
}

- (IBAction)playVideoClicked:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    NSURL *url;
    url = [NSURL URLWithString:@"http://d167cgw0so9a1a.cloudfront.net/media/loginsamplevideo.mp4"];
    MPMoviePlayerViewController *mpMoviewPlayerCon = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:mpMoviewPlayerCon];
    
    [mpMoviewPlayerCon.moviePlayer play];

    /* Playing an Embedded Video
     
     MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
     
     [player prepareToPlay];
     [player setFullscreen:true animated:true];
     [player setShouldAutoplay:true];
     [player.view setFrame: self.videoView.bounds];
     [player setControlStyle:MPMovieControlStyleNone];
     [player setScalingMode:MPMovieScalingModeAspectFill];
     [self.videoView addSubview: player.view];
     
     [player play];
     */

}

-(void)MPMoviePlayerPlaybackDidFinishNotification:(NSNotification*)notif {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

@end
