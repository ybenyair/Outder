//
//  LoginInfo.h
//  Outder
//
//  Created by Yossi on 7/4/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject
{
    BOOL isValid;
}

@property (nonatomic, strong) NSString * emailAddress;
@property (nonatomic, strong) NSString * facebookID;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic) BOOL isValid;

+ (LoginInfo *)getInstance;

- (void)storeLoggedIn;
- (void)storeLoggedOut;

@end
