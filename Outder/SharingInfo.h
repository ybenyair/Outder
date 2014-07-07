//
//  SharingInfo.h
//  Outder
//
//  Created by Yossi on 7/5/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharingInfo : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image;

- (NSString *)getEncodedText;

@end
