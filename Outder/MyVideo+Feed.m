//
//  MyVideo+Feed.m
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "MyVideo+Feed.h"

@implementation MyVideo (Feed)

+ (void)saveDB:(NSManagedObjectContext *)context
{
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

+ (void)clearDB:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MyVideo"];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // handle error
    } else {
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
        [MyVideo saveDB:context];
    }
}

+ (void)setMyVideoTestData:(NSManagedObjectContext *)context
{
    [MyVideo clearDB:context];

    // Query for the current existing user information (if exists)
    MyVideo *myVideo = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"MyVideo" inManagedObjectContext:context];
	for (int i = 0; i < 10; i++)
    {
        myVideo = [NSEntityDescription insertNewObjectForEntityForName:@"MyVideo" inManagedObjectContext:context];
        myVideo.title = [NSString stringWithFormat:@"Title %d",i];
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        myVideo.time = [DateFormatter stringFromDate:[NSDate date]];
        myVideo.imageURL = @"https://s3.amazonaws.com/outder/C1/elal/ElAl-1.png";
    }
}

@end
