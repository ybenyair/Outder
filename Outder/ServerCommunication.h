//
//  Communication.h
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginInfo.h"

typedef enum {
    kCommOK,
    kCommErrorNetwork,
    kCommErrorServer
} eCommResponseCode;

@protocol ServerCommunicationDelegate
- (void)communicationResponse:(NSDictionary *)json responseCode:(eCommResponseCode)code userData:(NSObject *)data;
@end

@interface ServerCommunication : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic,strong) NSObject* userData;
@property (nonatomic, weak) id <ServerCommunicationDelegate> delegate;

- (void)getFeeds: (NSString *)time feedType:(NSString *)type;
- (void)refreshFeeds:(NSString *)type;

- (void)sendLogin:(LoginInfo *)loginInfo;
- (void)getTemplates;
- (void)setUserData: (NSObject *)obj;

@end
