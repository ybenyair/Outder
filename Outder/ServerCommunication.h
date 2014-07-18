//
//  Communication.h
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginInfo.h"
#import "Feed.h"

typedef enum {
    kCommOK,
    kCommInProgress,
    kCommErrorNetwork,
    kCommErrorServer
} eCommResponseCode;

@protocol ServerCommunicationDelegate
- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data;
@end

@protocol ServerUploadDelegate
- (void)uploadResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code progress:(NSInteger)progress userData:(NSObject *)data;
@end

@interface ServerCommunication : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic,strong) NSObject* userData;
@property (nonatomic, weak) id <ServerCommunicationDelegate> delegate;
@property (nonatomic, weak) id <ServerUploadDelegate> uploadDelegate;

- (void)getFeeds: (NSString *)time feedType:(NSString *)type;
- (void)refreshFeeds:(NSString *)type;

- (void)sendLogin:(LoginInfo *)loginInfo;
- (void)getTemplates;
- (void)setUserData: (NSObject *)obj;
- (void)uploadFeed:(Feed *)feed;

@end
