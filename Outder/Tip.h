//
//  Tip.h
//  Outder
//
//  Created by Yossi on 8/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SubTemplate;

@interface Tip : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) SubTemplate *subTemplate;

@end
