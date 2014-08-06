//
//  CustomUIViewController.m
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "TitleNavBarVC.h"
#import "LoginViewController.h"
#import "RootViewController.h"

@interface TitleNavBarVC ()

@end

@implementation TitleNavBarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setBarItemLeft];
    [self setBarItemRight];
    [self setNavBarView];
}

- (void) settingsClicked: (id) sender
{
    
}

- (void) backClicked: (id) sender
{
    RootViewController *root = [RootViewController getInstance];
    [root startLoginViewController: YES];
}

- (void) setBarItemLeft
{
    //create the image for your button, and set the frame for its size
    UIImage *imageOff = [UIImage imageNamed:@"back_press"];
    UIImage *imagePress = [UIImage imageNamed:@"back_off"];
    CGRect frame = CGRectMake(0, 0, 20, 20);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:imageOff forState:UIControlStateNormal];
    [button setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    button.showsTouchWhenHighlighted = YES;
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void) setBarItemRight
{
    //create the image for your button, and set the frame for its size
    UIImage *imageOff = [UIImage imageNamed:@"settings_press"];
    UIImage *imagePress = [UIImage imageNamed:@"settings_off"];
    CGRect frame = CGRectMake(0, 0, 25, 25);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:imageOff forState:UIControlStateNormal];
    [button setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    button.showsTouchWhenHighlighted = YES;

    // Hide it for now
    button.hidden = YES;
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(settingsClicked:) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void) setNavBarView
{
    self.navigationItem.titleView = nil;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    CGRect frame = CGRectMake(0, 0, 100, 26);
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setBackgroundColor:[UIColor clearColor]];
    NSLog(@"%p", self.navigationItem.titleView);

    self.navigationItem.titleView = imageView;
}

@end
