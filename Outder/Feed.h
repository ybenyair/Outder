//
//  Feed.h
//  Outder
//
//  Created by Yossi on 7/31/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTemplate;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * pageURL;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSNumber * subTemplateID;
@property (nonatomic, retain) SubTemplate *subTemplate;

@end
