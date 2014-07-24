//
//  UploadFeed.m
//  Outder
//
//  Created by Yossi on 7/23/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedUploader.h"

@implementation FeedUploader

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        self.showAccurateProgress = YES;
        [self setUploadProgressDelegate:self];
        [self setQueueDidFinishSelector:@selector(queueDidFinish:)];
        [self setDelegate:self];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    NSLog(@"UPLOAD FEED: progress = %f [%@]", progress, self.feed.title);
    self.feed.progress = [NSNumber numberWithFloat:(progress * 100)];
}

- (void)queueDidFinish:(ASINetworkQueue *)queue {
    NSLog(@"UPLOAD FEED: done [%@]", self.feed.title);
    if ([self.feed.progress intValue] == 100) {
        [self.feedUploadDelegate uploadResponse:kFeedUploadDone progress:self.feed.progress uploader:self];
    } else {
        [self.feedUploadDelegate uploadResponse:kFeedUploadError progress:self.feed.progress uploader:self];
    
    }
}

@end
