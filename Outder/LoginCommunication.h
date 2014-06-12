//
//  LoginCommunication.h
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@class LoginCommunication;

@protocol LoginCommunicationDelegate
- (void)loginResponse:(UserInfo *)userInfo result:(BOOL)ok;
@end

@interface LoginCommunication : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (nonatomic, weak) id <LoginCommunicationDelegate> delegate;
@property (nonatomic, weak) UserInfo *userInfo;

- (void)sendLogin:(UserInfo *)userInfo;

@end
