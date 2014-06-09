//
//  LoginViewController.h
//  Outder
//
//  Created by Yossi on 6/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate> {
    BOOL loggedIn;
}

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property BOOL loggedIn;

- (IBAction)termOfUseClicked:(UIButton *)sender;
- (IBAction)guestLoginClicked:(UIButton *)sender;

@end
