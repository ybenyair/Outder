//
//  FeedCoreData.m
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedCoreData.h"
#import "Feed.h"

@implementation FeedCoreData

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

+ (void)clearDB:(NSManagedObjectContext *)context feedType:(NSString *)type
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    request.predicate = [NSPredicate predicateWithFormat:@"type = %@", type];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // handle error
    } else {
        for (NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
        [FeedCoreData saveDB:context];
    }
}

+ (void)setFeedTestData:(NSManagedObjectContext *)context feedType:(NSString *)type;
{
    Feed *feed = nil;
	for (int i = 0; i < 10; i++)
    {
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
        feed.title = [NSString stringWithFormat:@"Title %d",i];
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        //feed.time = [DateFormatter stringFromDate:[NSDate date]];
        feed.time = [NSString stringWithFormat:@"Title %d",i];
        feed.imageURL = @"https://s3.amazonaws.com/outder/C1/elal/ElAl-1.png";
        feed.type = type;
    }
}

+ (void)fillFeeds:(NSManagedObjectContext *)context data:(NSDictionary *)json feedType:(NSString *)type
{
    NSArray *dataArray = [json objectForKey:@"data"];
    for (id dataElement in dataArray) {
        NSDictionary *feedData = (NSDictionary *)dataElement;
        Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
        feed.title = [feedData objectForKey:@"title"];
        feed.time = [feedData objectForKey:@"time"];
        feed.videoURL = [feedData objectForKey:@"video_url"];
        feed.imageURL = @"https://s3.amazonaws.com/outder/C1/elal/ElAl-1.png";
        feed.type = type;
        NSLog(@"%@", feed);
    }
}

@end
