//
//  SubTemplateItemVC.m
//  Outder
//
//  Created by Yossi on 7/1/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "SubTemplateCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Instruction.h"

#define kLineHeight 35.0f

@interface SubTemplateCell ()

@end


@implementation SubTemplateCell
{
    NSMutableArray *directions;
}

@synthesize videoImage, labelTitle,btnMake,imgMake,btnDirection,lineLayer,labelTitleDirection,tableDirections;
@synthesize videoCtrl;
@synthesize subTemplate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.videoImage = [[UIImageView alloc] init];
        [self.view addSubview:self.videoImage];
        [self.videoImage setUserInteractionEnabled:YES];


        self.labelTitle = [[UILabel alloc] init];
        [self.view addSubview:labelTitle];
        
        self.btnMake = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.view addSubview:btnMake];
        
        self.imgMake =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MakeOne.png"]];
        [self.view addSubview:imgMake];
        self.videoImage.contentMode = UIViewContentModeScaleAspectFit;

        self.lineLayer = [CAShapeLayer layer];
        [self.view.layer addSublayer:lineLayer];
        
        self.btnDirection = [[UIButton alloc] init];
        self.labelTitleDirection = [[UILabel alloc] init];
        
        
        self.tableDirections = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableDirections.dataSource = self;
        self.tableDirections.delegate = self;
        [self.view addSubview:tableDirections];
        
        [self setTapGesture];
    }
    
    return self;
}

- (void)setTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(videoImageTap:)];
    [self.videoImage addGestureRecognizer:tap];
}

- (void)videoImageTap:(UIGestureRecognizer *)sender
{
    NSLog(@"Video image tapped");
    
    if (!videoCtrl) {
        videoCtrl = [[VideoPlayerViewController alloc] init];
    }
    
    if (videoCtrl.videoState == kVideoClosed) {
        [videoCtrl playVideo:subTemplate.videoURL inView:self.videoImage];
    } else {
        NSLog(@"Video is already playing...	");
    }
    
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

#define CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE 35
#define CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE 3

-(void) adjustFontSizeToFillItsContents: (UILabel *)label
{
    NSString* text = label.text;
    
    for (int i = CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE; i>CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE; i--) {
        
        UIFont *font = [UIFont fontWithName:label.font.fontName size:(CGFloat)i];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
        
        CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (rectSize.size.height <= label.frame.size.height) {
            label.font = [UIFont fontWithName:label.font.fontName size:(CGFloat)i];
            break;
        }
    }
    
}

- (void) configureBtnMake: (UIView *)inView
{
    // Set the text inside the image
    NSString *text = NSLocalizedString(@"MAKE\nONE", nil);
    [btnMake setTitle: text forState: UIControlStateNormal];
    [btnMake setTitleColor: [UIColor redColor] forState: UIControlStateNormal];

    // Locate the center of the view. It should be between the videoImage and the directionTable
    CGFloat YstartPoint = labelTitle.frame.origin.y  + labelTitle.frame.size.height + 5;
    CGFloat YendPoint = tableDirections.frame.origin.y;
    CGFloat Yheight = YendPoint - YstartPoint;
    CGPoint center;
    center.x = inView.frame.size.width/2;
    center.y = YstartPoint + Yheight/2;
    
    // Configure image frame
    CGRect imgFrame;
    imgFrame.size.height = Yheight - 4;
    imgFrame.size.width = imgFrame.size.height;
    imgMake.frame = imgFrame;
    imgMake.center = center;

    // Configure text frame
    CGRect frame;
    frame.size.width = imgFrame.size.width - 50;
    frame.size.height = imgFrame.size.height - 50;
    btnMake.frame = frame;
    btnMake.center = center;
    
    // Adjust text to fit the frame
    btnMake.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnMake.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    btnMake.titleLabel.numberOfLines = 2;
    [btnMake.titleLabel sizeToFit];
    [self adjustFontSizeToFillItsContents:btnMake.titleLabel];
    
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
    
    if (videoCtrl && (videoCtrl.videoState != kVideoClosed)) {
        [videoCtrl stopVideo];
        videoCtrl = nil;
    }
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
