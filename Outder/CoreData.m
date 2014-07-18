//
//  CoreData.m
//  Outder
//
//  Created by Yossi on 7/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "CoreData.h"
#import "AppDelegate.h"

@implementation CoreData

+ (void)saveDB
{
    AppDelegate *app = [AppDelegate getInstance];
    NSManagedObjectContext *context = app.managedObjectContext;
    if ([context hasChanges]) {
        NSLog(@"DB changed");
    }
    
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
