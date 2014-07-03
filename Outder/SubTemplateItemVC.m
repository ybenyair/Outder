//
//  SubTemplateItemVC.m
//  Outder
//
//  Created by Yossi on 7/1/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "SubTemplateItemVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Instruction.h"

#define kLineHeight 35.0f

@interface SubTemplateItemVC ()

@end


@implementation SubTemplateItemVC
{
    NSMutableArray *directions;
}

@synthesize videoImage, labelTitle, btnMake, btnDirection, lineLayer, labelTitleDirection, tableDirections;
@synthesize subTemplate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.videoImage = [[UIImageView alloc] init];
        [self.view addSubview:self.videoImage];

        self.labelTitle = [[UILabel alloc] init];
        [self.view addSubview:labelTitle];
        
        self.btnMake = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.view addSubview:btnMake];
        
        self.lineLayer = [CAShapeLayer layer];
        [self.view.layer addSublayer:lineLayer];
        
        self.btnDirection = [[UIButton alloc] init];
        self.labelTitleDirection = [[UILabel alloc] init];
        
        
        self.tableDirections = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableDirections.dataSource = self;
        self.tableDirections.delegate = self;
        [self.view addSubview:tableDirections];
    }
    
    return self;
}

#pragma mark - ScrollView Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, 0)];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of rows
    NSInteger count = [directions count];
    return  count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    Instruction *instruction = [directions objectAtIndex:indexPath.row];
    [self configureCellTextLabel:cell.textLabel withInstruction:instruction];
    cell.backgroundColor = [UIColor colorWithWhite:0.985 alpha:0.5];
    return cell;
}

- (void) configureCellTextLabel: (UILabel *)textLabel withInstruction: (Instruction *)data
{
    textLabel.text = data.name;
    textLabel.adjustsFontSizeToFitWidth = NO;
    textLabel.minimumScaleFactor = 0.1;
    [textLabel setFont:[UIFont systemFontOfSize:11]];
    textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    textLabel.textAlignment = NSTextAlignmentNatural;
    textLabel.numberOfLines = 0;
}

#pragma mark - UITableViewDelegate Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header = NSLocalizedString(@"Directions:", nil);
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLineHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // handle table view selection
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureVideoImage: (UIView *)inView
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = -1;
    frame.size.width = inView.frame.size.width;
    frame.size.height = inView.frame.size.width * 9 / 16;
    self.videoImage.frame = frame;
    self.videoImage.contentMode = UIViewContentModeScaleAspectFit;

    NSLog(@"View frame = %@", NSStringFromCGRect(inView.frame));
    NSLog(@"Image frame = %@", NSStringFromCGRect(frame));
    
    NSLog(@"Image frame = %@", NSStringFromCGRect(self.videoImage.frame));
    
    [self setImage:subTemplate.imageURL];
}

- (void) configureLine: (UIView *)inView
{
    CGPoint startPoint;
    startPoint.x = 0.0;
    startPoint.y = 10;
    
    CGPoint endPoint;
    endPoint.x = inView.frame.size.width - startPoint.x;
    endPoint.y = startPoint.y;
    
    NSLog(@"Line start = %@", NSStringFromCGPoint(endPoint));

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    lineLayer.path = [path CGPath];
    lineLayer.strokeColor = [[UIColor grayColor] CGColor];
    lineLayer.lineWidth = 0.2;
    lineLayer.fillColor = [[UIColor clearColor] CGColor];
    
    CGRect frame = lineLayer.frame;
    frame.origin.y = videoImage.frame.size.height + labelTitle.frame.size.height;
    lineLayer.frame = frame;
    
    NSLog(@"Line frame = %@", NSStringFromCGRect(lineLayer.frame));
}

- (void) configureTitle: (UIView *)inView
{
    labelTitle.text = subTemplate.title;

    labelTitle.adjustsFontSizeToFitWidth = NO;
    labelTitle.minimumScaleFactor = 0.1;
    
    [labelTitle setFont:[UIFont systemFontOfSize:12]];
    
    //labelTitle.backgroundColor = [UIColor redColor];
    
    CGRect frame;
    frame.origin.x = 2;
    frame.origin.y = videoImage.frame.size.height + 5;
    frame.size.width = inView.frame.size.width - frame.origin.x;
    frame.size.height = labelTitle.intrinsicContentSize.height;
    labelTitle.frame = frame;
    
    labelTitle.userInteractionEnabled = NO;
    NSLog(@"Title frame = %@", NSStringFromCGRect(self.labelTitle.frame));
}

- (void) configureBtnMake: (UIView *)inView
{
    [btnMake setTitle: @"MAKE ONE" forState: UIControlStateNormal];
    [btnMake setTitleColor: [UIColor purpleColor] forState: UIControlStateNormal];

    [btnMake.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    btnMake.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnMake.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    CGRect frame;
    frame.size.width = 60;
    frame.size.height = 30;
    frame.origin.x = inView.frame.size.width/2 -  frame.size.width/2;
    
    CGFloat startPoint = labelTitle.frame.origin.y  + labelTitle.frame.size.height;
    CGFloat endPoint = tableDirections.frame.origin.y;
    frame.origin.y = startPoint + (endPoint - startPoint)/2 - frame.size.height/2;
    
    btnMake.frame = frame;
    NSLog(@"MAKE ONE frame = %@", NSStringFromCGRect(self.btnMake.frame));
}

- (void) configureTableDirections:(UIView *)inView
{
    CGFloat maxTableHeight = (inView.frame.size.height - (lineLayer.frame.origin.y + lineLayer.frame.size.height))/2;
    //round(inView.frame.size.height / 3);
    
    CGFloat tableHeight = kLineHeight * ([directions count] + 1);
    if (tableHeight > maxTableHeight) {
        tableHeight = maxTableHeight;
    }
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = inView.frame.size.height - maxTableHeight;
    
    frame.size.width = inView.frame.size.width - frame.origin.x;
    frame.size.height = tableHeight;
    tableDirections.frame = frame;
    
    NSLog(@"Table directions frame = %@ for subTemplate %@", NSStringFromCGRect(self.tableDirections.frame), subTemplate.order);

}

- (void)configureItem: (SubTemplate *)data inView: (UIView *)view
{
    subTemplate = data;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];

    NSArray *sortDescriptors = @[sortDescriptor];
    directions = [NSMutableArray arrayWithArray:[[data.instructions allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
    
    [tableDirections reloadData];
    
    [self configureVideoImage:view];
    [self configureTitle:view];
    [self configureLine:view];
    [self configureTableDirections:view];
    [self configureBtnMake:view];
}

- (void)setImage:(NSString *)imageURL
{
    NSURL *url = [NSURL URLWithString:imageURL];
    UIImageView *_imageView = self.videoImage;
    
    [self.videoImage setImageWithURL:url
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (image)
                              {
                                  _imageView.alpha = 0.0;
                                  [UIView animateWithDuration:0.5
                                                   animations:^{
                                                       _imageView.alpha = 1.0;
                                                   }];
                              }
                          }];
}


@end
