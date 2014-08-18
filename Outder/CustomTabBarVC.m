//
//  CustomTabBarVC.m
//  Outder
//
//  Created by Yossi on 6/10/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "CustomTabBarVC.h"
#import "Defines.h"

@interface CustomTabBarVC ()

@end

@implementation CustomTabBarVC


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
    [self setBarItemColors];
}

- (void) setBarItemColors
{
    UIColor *colorPress = [FontHelpers colorFromHexString:@"#41beb1"];
    
    [self.tabBar setTintColor:colorPress];
    
    [self.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] } forState:UIControlStateNormal];
    
    [self.tabBar setTintColor:[UIColor whiteColor]];
    
    [self.tabBar setSelectedImageTintColor:colorPress];
    
    [self.tabBarItem setTitleTextAttributes:@{UITextAttributeTextColor : colorPress } forState:UIControlStateSelected];
}

-(void) setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    [self centerTabBarItems];
}

-(void) centerTabBarItems
{
    NSArray *array = self.viewControllers;
    for (UIViewController *vc in array) {
        vc.title = nil;
        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
