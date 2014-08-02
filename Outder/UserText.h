//
//  UserText.h
//  Outder
//
//  Created by Yossi on 8/2/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTemplate;

@interface UserText : NSManagedObject

@property (nonatomic, retain) NSString * textHint;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) SubTemplate *subTemplate;

@end
