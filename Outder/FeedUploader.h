//
//  UploadFeed.h
//  Outder
//
//  Created by Yossi on 7/23/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

typedef enum {
    kFeedUploadDone,
    kFeedUploadError
} eFeedUploadCode;

@class FeedUploader;

@protocol FeedUploaderDelegate
- (void)uploadResponse:(eFeedUploadCode)code progress:(NSNumber *)progress uploader:(FeedUploader *)instance;
@end

@interface FeedUploader : ASINetworkQueue

- (void)queueDidFinish:(ASINetworkQueue *)queue;

@property (nonatomic, strong) Feed *feed;
@property (nonatomic, weak) id <FeedUploaderDelegate> feedUploadDelegate;

@end
