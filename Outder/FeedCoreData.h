//
//  FeedCoreData.h
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedTableViewCell.h"

@interface FeedCoreData : NSObject {
}

+ (void)setFeedTestData:(NSManagedObjectContext *)context feedType:(NSString *)type;
+ (void)clearDB:(NSManagedObjectContext *)context feedType:(NSString *)type;
+ (void)fillFeeds:(NSManagedObjectContext *)context data:(NSDictionary *)json feedType:(NSString *)type;

@end
