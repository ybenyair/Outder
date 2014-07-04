//
//  Feed.h
//  Outder
//
//  Created by Yossi on 7/4/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject

@property (nonatomic, retain) NSNumber * feedID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSString * pageURL;

@end
