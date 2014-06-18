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
#import "ServerCommunication.h"

@interface LoginViewController : CustomUIViewController <FBLoginViewDelegate, ServerCommunicationDelegate> {

}

@property NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;


- (IBAction)termOfUseClicked:(UIButton *)sender;
- (IBAction)guestLoginClicked:(UIButton *)sender;
- (IBAction)playVideoClicked:(UIButton *)sender;

+ (void)signOutFacebook;

@end
