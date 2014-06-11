//
//  CustomUIViewController.m
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "CustomUIViewController.h"
#import "LoginViewController.h"

@interface CustomUIViewController ()

@end

@implementation CustomUIViewController

@synthesize managedObjectContext;

- (void)initManagedObjectContext:(NSManagedObjectContext *)context
{
    self.managedObjectContext = context;
}

@end
