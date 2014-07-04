//
//  LoginInfo.m
//  Outder
//
//  Created by Yossi on 7/4/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "LoginInfo.h"

@implementation LoginInfo

@synthesize emailAddress, facebookID, userName, isValid;

static LoginInfo *instance = nil;

+ (LoginInfo *)getInstance;
{
    if (!instance) {
        instance = [[LoginInfo alloc] init];
        [instance readLoginInfo];
        if (instance.isValid) {
            NSLog(@"LOGIN INFO with userName %@ emailAddress %@",instance.userName, instance.emailAddress);
        }
    }
    return instance;
}

- (void)readLoginInfo
{
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"LoginUserName"];
    self.emailAddress = [defaults objectForKey:@"LoginEmailAddress"];
    self.facebookID = [defaults objectForKey:@"LoginFacebookID"];
    isValid = [defaults boolForKey:@"LoginIsValid"];
}

- (void)writeLoginInfo
{
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userName forKey:@"LoginUserName"];
    [defaults setObject:self.emailAddress forKey:@"LoginEmailAddress"];
    [defaults setObject:self.facebookID forKey:@"LoginFacebookID"];
    [defaults setBool:isValid forKey:@"LoginIsValid"];
    [defaults synchronize];
}

- (void)clearLoginInfo
{
    self.userName = @"";
    self.emailAddress = @"";
    self.facebookID = @"";
    isValid = NO;
}

- (void)storeLoggedIn
{
    NSLog(@"Storing LOGGED IN with userName %@ emailAddress %@",self.userName, self.emailAddress);
    [self writeLoginInfo];
}

- (void)storeLoggedOut;
{
    NSLog(@"Storing LOGGED OUT with userName %@ emailAddress %@",self.userName, self.emailAddress);
    [self clearLoginInfo];
    [self writeLoginInfo];
}


@end
