//
//  OdrNavigationController.h
//  Outder
//
//  Created by Yossi on 6/10/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController {
    NSUInteger supprtedOrientations;
}

@property NSUInteger supprtedOrientations;

@end
