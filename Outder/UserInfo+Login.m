//
//  UserInfo+Login.m
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "UserInfo+Login.h"
#import "AppDelegate.h"

@implementation UserInfo (Login)

+ (void)storeInDB:(NSManagedObjectContext *)context
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

+ (void)clearUserInfo:(UserInfo *)userInfo
{
    userInfo.userName = @"";
    userInfo.emailAddress = @"";
    userInfo.facebookID = @"";
    userInfo.isValid = [NSNumber numberWithBool:NO];
}

+ (UserInfo *)getUserInfo:(NSManagedObjectContext *)context
{
    // Query for the current existing user information (if exists)
    UserInfo *userInfo = nil;
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:context];
	
	NSError *error = nil;
	userInfo = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (!error && !userInfo) {
        // Create the initial userInfo entity in the DB
        NSLog(@"Initializing the userInfo in DB");
		userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
        [UserInfo clearUserInfo:userInfo];
        
	}
    
    return userInfo;
}

+ (void)userLoggedIn:(NSManagedObjectContext *)context
           userInfo:(UserInfo *)userInfo
{
    UserInfo *dbEntry = [self getUserInfo:context];
    userInfo.userName = dbEntry.userName;
    userInfo.emailAddress = dbEntry.emailAddress;
    userInfo.facebookID = dbEntry.facebookID;
    userInfo.isValid = dbEntry.isValid;
    [UserInfo storeInDB:context];
    NSLog(@"Logged-in with user %@ email %@",userInfo.userName, userInfo.emailAddress);
}

+ (void)userLoggedOut:(NSManagedObjectContext *)context
{
    UserInfo *dbEntry = [self getUserInfo:context];
    NSLog(@"Logged-out with user %@",dbEntry.userName);
    [UserInfo clearUserInfo:dbEntry];
    [UserInfo storeInDB:context];
}

@end
