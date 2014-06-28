//
//  TemplatePromotedView.h
//  Outder
//
//  Created by Yossi on 6/26/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplatePromotedView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) NSInteger index;

- (void)setImage:(NSString *)imageURL;

@end
