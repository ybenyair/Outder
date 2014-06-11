//
//  UserInfo+Login.h
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "UserInfo.h"

@interface UserInfo (Login)
{
    
}

+ (UserInfo *)getUserInfo:(NSManagedObjectContext *)context;
+ (void)userLoggedIn:(NSManagedObjectContext *)context userInfo:(UserInfo *)userInfo;
+ (void)userLoggedOut:(NSManagedObjectContext *)context;

@end
