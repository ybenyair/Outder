//
//  UploadManager.h
//  Outder
//
//  Created by Yossi on 7/18/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "ServerCommunication.h"
#import "SubTemplate.h"
#import "FeedUploader.h"

@interface UploadManager : NSObject <FeedUploaderDelegate>

+ (UploadManager *) getInstance;

- (id)initWithContext:(NSManagedObjectContext *) context;

- (void) resumePendingUploads;
- (void)uploadFeed: (Feed *)feed;
- (NSInteger)getNumOfMakeOne: (SubTemplate *)subTemplate;

@end
