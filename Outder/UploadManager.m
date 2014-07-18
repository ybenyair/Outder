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

@interface UploadServerCommunication : ServerCommunication

@property (nonatomic, strong) Feed *feed;

@end

@implementation UploadServerCommunication

@end


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
    [self uploadFeed:notification.object];
}

- (void) uploadFeed: (Feed *)feed
{
    UploadServerCommunication *comm = [[UploadServerCommunication alloc] init];
    comm.uploadDelegate = self;
    comm.userData = comm;
    comm.feed = feed;
    
    [self addActiveUploader: comm];
    [comm uploadFeed:feed];
    
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

- (void) processStateInProgress: (UploadServerCommunication *)uploader withProgress:(NSInteger) progress
{
    NSLog(@"FEED UPLOAD PROGRESS [%ld]: %@", (long)progress, uploader.feed.title);
    uploader.feed.progress = [NSNumber numberWithInteger:progress];
}

- (void) processStateOK: (UploadServerCommunication *)uploader
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

- (void) processStateError: (UploadServerCommunication *)uploader
{
    NSLog(@"FEED UPLOAD ERROR: %@", uploader.feed.title);
    [self removeActiveUploader:uploader];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"FeedMakeOneDone"
                                      object:uploader.feed
                                    userInfo:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(aTime:) userInfo:uploader.feed repeats:NO];
}

-(void)aTime: (NSTimer *)timer
{
    Feed *feed = (Feed *)[timer userInfo];
    NSLog(@"FEED UPLOAD RETRY: %@", feed);
    [self uploadFeed:feed];
}

- (void)uploadResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code progress:(NSInteger)progress userData:(NSObject *)data;
{
    UploadServerCommunication *uploader = (UploadServerCommunication *)data;
    
    switch (code) {
        case kCommInProgress:
            [self processStateInProgress:uploader withProgress:progress];
            break;
        case kCommOK:
            [self processStateOK:uploader];
            break;
        case kCommErrorNetwork:
        case kCommErrorServer:
            [self processStateError:uploader];
            break;

    }
}


- (NSInteger)getNumOfMakeOne: (SubTemplate *)subTemplate
{
    NSInteger num = 0;
    for(id key in _activeUploaders) {
        UploadServerCommunication *comm = [_activeUploaders objectForKey:key];
        if (comm.feed.subTemplate == subTemplate) {
            num++;
        }
    }
    
    return num;
}

@end
