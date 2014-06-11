//
//  UserInfo.h
//  Outder
//
//  Created by Yossi on 6/11/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSNumber * isValid;
@property (nonatomic, retain) NSString * userName;

@end
