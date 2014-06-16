//
//  MyVideo.h
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyVideo : NSManagedObject

@property (nonatomic, retain) NSString * feedID;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSString * templateID;
@property (nonatomic, retain) NSString * subTemplateID;

@end
