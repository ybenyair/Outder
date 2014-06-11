//
//  LoginViewController.h
//  Outder
//
//  Created by Yossi on 6/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CustomUIViewController.h"

@interface LoginViewController : CustomUIViewController <FBLoginViewDelegate> {
    BOOL closingFBSession;
}

@property BOOL closingFBSession;
@property NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;


- (IBAction)termOfUseClicked:(UIButton *)sender;
- (IBAction)guestLoginClicked:(UIButton *)sender;
- (IBAction)playVideoClicked:(UIButton *)sender;

+ (void)signOutFacebook;

@end
