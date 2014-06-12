//
//  CustomUIViewController.h
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIViewController : UIViewController {
    NSManagedObjectContext *managedObjectContext;
}

@property NSManagedObjectContext *managedObjectContext;

@end
