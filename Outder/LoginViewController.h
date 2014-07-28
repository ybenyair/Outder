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
#import "ServerCommunication.h"
#import "VideoPlayerViewController.h"
#import "AVCamViewController.h"

@interface LoginViewController : UIViewController <FBLoginViewDelegate, ServerCommunicationDelegate> {

}

+ (LoginViewController *) loadInstance;

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) VideoPlayerViewController *videoCtrl;

@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIView *viewVideo;
@property (weak, nonatomic) IBOutlet UIImageView *viewImageBG;

- (IBAction)termOfUseClicked:(UIButton *)sender;
- (IBAction)guestLoginClicked:(UIButton *)sender;

+ (void)signOutFacebook;

@end
