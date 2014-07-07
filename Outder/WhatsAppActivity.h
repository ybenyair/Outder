//
//  WhatsAppActivity.h
//  Outder
//
//  Created by Yossi on 7/5/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharingInfo.h"

@interface WhatsAppActivity : UIActivity

- (id)initWithMessage:(SharingInfo *)message;

@property (nonatomic, strong) SharingInfo *shareInfo;

@end