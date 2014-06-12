//
//  DashboardViewController.m
//  Outder
//
//  Created by Yossi on 6/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "DashboardViewController.h"
#import "CustomNavigationController.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationBarItems];
    // Do any additional setup after loading the view from its nib.
}

- (void) setNavigationBarItems
{
    //create the image for your button, and set the frame for its size
    UIImage *image = [UIImage imageNamed:@"signOut"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(signOutClicked) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //then set it.  phew.
    [self.navigationItem setRightBarButtonItem:barButtonItem];
}

- (void) signOutClicked
{
    [CustomNavigationController startLoginViewController:self.navigationController logOut: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
