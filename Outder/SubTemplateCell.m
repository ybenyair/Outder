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
    CGRect btnMakeDirectionHideFrame;
    CGRect imgMakeDirectionHideFrame;
}

@synthesize videoCtrl;
@synthesize subTemplate;

+ (SubTemplateCell *) loadInstance
{
    UIStoryboard *sb = nil;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        sb = [UIStoryboard storyboardWithName:@"SubTemplateCell.iPhone5" bundle:nil];
    } else {
        // code for 3.5-inch screen
        sb = [UIStoryboard storyboardWithName:@"SubTemplateCell.iPhone4" bundle:nil];
    }
    
    SubTemplateCell *vc = [sb instantiateViewControllerWithIdentifier:@"SubTemplateCell"];
    
    //[vc initFromSB];
    
    return vc;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    btnMakeDirectionHideFrame = self.btnMake.frame;
    imgMakeDirectionHideFrame = self.imgMake.frame;

    self.videoImage.contentMode = UIViewContentModeScaleAspectFit;
    self.videoImage.userInteractionEnabled = YES;
    
    self.tableDirections.dataSource = self;
    self.tableDirections.delegate = self;
    
    NSString *text = NSLocalizedString(@"HIDE", nil);
    [self.btnHideDirections setTitle: text forState: UIControlStateNormal];
    
    text = NSLocalizedString(@"SHOW DIRECTIONS", nil);
    [self.btnShowDirections setTitle: text forState: UIControlStateNormal];
    
    self.labelMakePlace.hidden = YES;
    self.tableDirections.hidden = YES;
    self.btnHideDirections.hidden = YES;
    self.btnHideDirections.enabled = NO;
    
    [self setTapGesture];
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
    [textLabel setFont:[UIFont systemFontOfSize:12]];
    textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    textLabel.textAlignment = NSTextAlignmentNatural;
    textLabel.numberOfLines = 0;
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Instruction *instruction = [directions objectAtIndex:indexPath.row];
    NSString *str = instruction.name;
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(tableView.frame.size.width, tableView.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0,0,tableView.frame.size.width,20);

    UIImage *myImage = [UIImage imageNamed:@"directions_separator_shadow.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    imageView.frame = view.frame;
    
    UILabel *label = [[UILabel alloc] init];
    CGRect frame = view.frame;
    frame.origin.x += 10;
    label.frame = frame;
    label.text = NSLocalizedString(@"Directions:", nil);
    [label setFont:[UIFont systemFontOfSize:14]];
    label.textColor = self.btnHideDirections.titleLabel.textColor;
    
    [view addSubview:imageView];
    [view addSubview:label];
    
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header = NSLocalizedString(@"Directions:", nil);
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // handle table view selection
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configureBtnMake
{
    // Set the text inside the image
    NSString *text = NSLocalizedString(@"MAKE\nONE", nil);
    [self.btnMake setTitle: text forState: UIControlStateNormal];
    [self.btnMake setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
    
    // Adjust text to fit the frame
    self.btnMake.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnMake.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.btnMake.titleLabel.numberOfLines = 2;
    [self.btnMake.titleLabel setFont:[UIFont systemFontOfSize:22]];
}

- (void) configureTableDirections
{
    self.tableDirections.hidden = YES;
    self.btnShowDirections.hidden = NO;
    self.btnShowDirections.enabled = YES;
    self.btnHideDirections.hidden = YES;
    self.btnHideDirections.enabled = NO;
}

- (void) configureVideoImage
{
    [self setImage:subTemplate.imageURL];
}

- (void) configureTitle
{
    self.labelTitle.text = subTemplate.title;
}

- (void)configureItem: (SubTemplate *)data inView: (UIView *)view
{
    subTemplate = data;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];

    NSArray *sortDescriptors = @[sortDescriptor];
    directions = [NSMutableArray arrayWithArray:[[data.instructions allObjects] sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self.tableDirections reloadData];
    
    [self configureVideoImage];
    [self configureTitle];
    [self configureTableDirections];
    [self configureBtnMake];
    
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


#pragma mark - Actions (MakeOne)

- (IBAction)btnMakeOneClicked:(id)sender {
    NSLog(@"btnMakeClicked for subTemplate: %@", subTemplate.title);
    [self.delegate makeOneClicked:subTemplate];
}

#pragma mark - Actions (Show directions)

- (IBAction)btnShowDirectionsClicked:(id)sender {
    
    self.btnShowDirections.hidden = YES;
    self.btnShowDirections.enabled = NO;
    self.tableDirections.hidden = NO;
    
    [UIView animateWithDuration:1.0
     
                     animations:^{
                         [self setDirectionTableUnhide];
                     }
     
                     completion:^(BOOL finished){
                         if (finished) {
                             self.btnHideDirections.enabled = YES;
                             self.btnHideDirections.hidden = NO;
                         }
                     }
     ];
    
    self.btnMake.alpha = 0.0f;
    self.imgMake.alpha = 0.0f;
    [self setMakeOneSmaller];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.btnMake.alpha = 1.0f;
                         self.imgMake.alpha = 1.0f;
                     }];
}

- (void) setDirectionTableUnhide
{
    CGRect frame = self.tableDirections.frame;
    frame.origin.y = self.btnHideDirections.frame.origin.y;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableDirections.frame= frame;
}

- (void) setMakeOneSmaller
{
    CGRect frameBtn = self.btnMake.frame;
    frameBtn.size.height = frameBtn.size.height*0.75;
    frameBtn.size.width = frameBtn.size.width*0.75;
    
    CGRect frameImage = self.imgMake.frame;
    frameImage.size.height = frameImage.size.height*0.75;
    frameImage.size.width = frameImage.size.width*0.75;
    
    [self.btnMake.titleLabel setFont:[UIFont systemFontOfSize:14]];
    
    self.btnMake.frame = frameBtn;
    self.imgMake.frame= frameImage;
    
    self.btnMake.center = self.labelMakePlace.center;
    self.imgMake.center = self.labelMakePlace.center;
}

#pragma mark - Actions (Hide directions)

- (IBAction)btnHideDirectionsClicked:(id)sender {
    
    self.btnHideDirections.hidden = YES;
    self.btnHideDirections.enabled = NO;
    
    [UIView animateWithDuration:1.0
     
                     animations:^{
                         [self setDirectionTableHide];
                     }
     
                     completion:^(BOOL finished){
                         if (finished) {
                             self.btnShowDirections.hidden = NO;
                             self.btnShowDirections.enabled = YES;
                         }
                     }
     ];
    
    self.btnMake.alpha = 0.0f;
    self.imgMake.alpha = 0.0f;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self setMakeOneBigger];
                     }];
}

- (void) setDirectionTableHide
{
    CGRect frame = self.tableDirections.frame;
    frame.origin.y = frame.origin.y + frame.size.height;
    frame.size.height = 0;
    self.tableDirections.frame= frame;
}

- (void) setMakeOneBigger
{
    [self.btnMake.titleLabel setFont:[UIFont systemFontOfSize:22]];
    self.btnMake.frame= btnMakeDirectionHideFrame;
    self.imgMake.frame = imgMakeDirectionHideFrame;
    self.btnMake.alpha = 1.0f;
    self.imgMake.alpha = 1.0f;
}

@end
