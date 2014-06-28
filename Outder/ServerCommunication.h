//
//  Communication.h
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

typedef enum {
    kCommOK,
    kCommErrorNetwork,
    kCommErrorServer
} eCommResponseCode;

@protocol ServerCommunicationDelegate
- (void)communicationResponse:(NSDictionary *)json userInfo:(UserInfo *)info
                 responseCode:(eCommResponseCode)code;
@end

@interface ServerCommunication : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic,strong) UserInfo* userDetails;
@property (nonatomic, weak) id <ServerCommunicationDelegate> delegate;

- (void)getFeeds:(UserInfo *)userInfo fromTime:(NSString *)time feedType:(NSString *)type;
- (void)sendLogin:(UserInfo *)userInfo;
- (void)getTemplates: (UserInfo *)userInfo;

@end
