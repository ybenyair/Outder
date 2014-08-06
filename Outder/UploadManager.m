//
//  UploadManager.m
//  Outder
//
//  Created by Yossi on 7/18/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "UploadManager.h"
#import "ServerCommunication.h"
#import "CoreData.h"
#import "FeedCoreData.h"
#import "SubTemplate.h"
#import "Instruction.h"
#import "Defines.h"
#import "FeedUploader.h"
#import "InstructionUploader.h"

static UploadManager *instance;

@implementation UploadManager
{
    NSMutableDictionary *_activeUploaders;
    NSManagedObjectContext *_context;
}

+ (UploadManager *) getInstance
{
    return instance;
}

- (id)initWithContext:(NSManagedObjectContext *) context
{
    if (self = [super init]) {
        _activeUploaders = [[NSMutableDictionary alloc] init];
        _context = context;
        
        // Adding observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(MakeOne:)
                                                     name:@"MakeOne"
                                                   object:nil];
        
        instance = self;
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:@"MakeOne"
                                               object:nil];

}

- (void) resumePendingUploads
{
    NSArray *objects = [FeedCoreData getUploadingFeeds:kMyVideoType];
    for (id dataElement in objects) {
        Feed *feed = dataElement;
        [self uploadFeed:feed];
    }
}

- (void)MakeOne:(NSNotification *)notification
{
    [CoreData saveDB];
    Feed *feed = notification.object;
    [self uploadFeed:feed];
}

- (void) uploadFeed: (Feed *)feed
{
    FeedUploader *uploader = [[FeedUploader alloc] init];
    uploader.feed = feed;
    uploader.feedUploadDelegate = self;
    
    [self addActiveUploader: uploader];
    
    for (id dataElement in feed.subTemplate.instructions) {
        Instruction *inst = (Instruction *)dataElement;
        if ([inst.fixed boolValue] == NO) {
            [self uploadInstruction:inst withUploader:uploader];
        }
    }
    
    NSLog(@"Post UPLOAD START notification: %@", feed.title);
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"FeedMakeOneStart"
                                      object:feed
                                    userInfo:nil];

}

- (void) addActiveUploader: (id) uploader
{
    NSString *key = [NSString stringWithFormat:@"%p",uploader];
    [_activeUploaders setObject:uploader forKey:key];
    NSLog(@"Add uploader. Number of uploaders = %lu", (unsigned long)[_activeUploaders count]);
}

- (void) removeActiveUploader: (id) uploader
{
    NSString *key = [NSString stringWithFormat:@"%p",uploader];
    [_activeUploaders removeObjectForKey:key];
    NSLog(@"Remove uploader. Number of uploaders = %lu", (unsigned long)[_activeUploaders count]);
}

- (void) uploadStateDone: (FeedUploader *)uploader
{
    NSLog(@"FEED UPLOAD DONE: %@", uploader.feed.title);
    [self removeActiveUploader:uploader];

    // This is for a tests
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(aFeedReady:) userInfo:uploader.feed repeats:NO];
}

-(void)aFeedReady: (NSTimer *)timer
{
    Feed *feed = (Feed *)[timer userInfo];
    NSLog(@"FEED READY: %@ %p", feed.title, feed.subTemplate);
    
    feed.videoURL = feed.subTemplate.videoURL;
    feed.imageURL = feed.subTemplate.imageURL;
    feed.feedID = [NSNumber numberWithInt:55555];

    NSLog(@"Post FEED READY notification: %@", feed.title);
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"FeedMakeOneDone"
                                      object:feed
                                    userInfo:nil];
    [CoreData saveDB];
}

- (void) uploadStateError: (FeedUploader *)uploader
{
    NSLog(@"FEED UPLOAD ERROR: %@", uploader.feed.title);
    [self removeActiveUploader:uploader];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"FeedMakeOneDone"
                                      object:uploader.feed
                                    userInfo:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(aTime:) userInfo:uploader.feed repeats:NO];
}

-(void)aTime: (NSTimer *)timer
{
    Feed *feed = (Feed *)[timer userInfo];
    NSLog(@"FEED UPLOAD RETRY: %@", feed);
    [self uploadFeed:feed];
}

- (void)uploadResponse:(eFeedUploadCode)code progress:(NSNumber *)progress uploader:(FeedUploader *)instance
{
    switch (code) {
        case kFeedUploadDone:
            [self uploadStateDone:instance];
            break;
        case kFeedUploadError:
            [self uploadStateError:instance];
            break;
    }
}

- (NSInteger)getNumOfMakeOne: (SubTemplate *)subTemplate
{
    NSInteger num = 0;
    for(id key in _activeUploaders) {
        FeedUploader *comm = [_activeUploaders objectForKey:key];
        if (comm.feed.subTemplate == subTemplate) {
            num++;
        }
    }
    
    return num;
}



- (void)uploadInstruction:(Instruction *)instruction withUploader: (FeedUploader *)uploader
{
    NSString *fileURL = instruction.videoURL;
    NSString *filename = [fileURL lastPathComponent];
    NSString *key = [NSString stringWithFormat:@"media_test/%@",filename];
    NSURL *url = [NSURL URLWithString:fileURL];
    NSString *filePath = [url path];
    
    NSLog(@"Uploading %@ to %@", fileURL, key);
    
    InstructionUploader *instUploader = [InstructionUploader PUTRequestForFile:filePath withBucket:VIDEO_BUCKET key:key];
    [ASIS3Request setSharedSecretAccessKey:SECRET_KEY];
    [ASIS3Request setSharedAccessKey:ACCESS_KEY_ID];

    [instUploader setDelegate:instUploader];
    [instUploader setShouldContinueWhenAppEntersBackground:YES];
    [instUploader setTimeOutSeconds:kServerTimeout];
    [instUploader setUploadProgressDelegate:instUploader];
    instUploader.showAccurateProgress = YES;
    
    instUploader.feedUploader = uploader;
    instUploader.filePath = filePath;
    instUploader.instruction = instruction;
    
    [uploader addOperation:instUploader];
    [uploader go];
}

@end
