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
#import "Defines.h"

@interface SubTemplateCell ()

@end


@implementation SubTemplateCell
{
    NSMutableArray *directions;
    CGRect btnMakeDirectionHideFrame;
    NSTimer *autoPlayTimer;
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

    self.videoImage.contentMode = UIViewContentModeScaleAspectFit;
    self.videoImage.userInteractionEnabled = YES;
    
    self.tableDirections.dataSource = self;
    self.tableDirections.delegate = self;

    UIColor *color = [FontHelpers colorFromHexString:@"#41beb1"];

    NSString *text = NSLocalizedString(@"HIDE", nil);
    [self.btnHideDirections setTitle: text forState: UIControlStateNormal];
    self.btnHideDirections.titleLabel.font = [UIFont fontWithName:kFontRegular size:14];
    [self.btnHideDirections setTitleColor:color forState: UIControlStateNormal];
    
    text = NSLocalizedString(@"SHOW DIRECTIONS", nil);
    self.btnShowDirections.titleLabel.font = [UIFont fontWithName:kFontBold size:14];
    [self.btnShowDirections setTitle: text forState: UIControlStateNormal];
    [self.btnShowDirections setTitleColor:color forState: UIControlStateNormal];
    UIImage *imageOff = [UIImage imageNamed:@"button_show_directions_off"];
    UIImage *imagePress = [UIImage imageNamed:@"button_show_directions_press"];
    
    //init a normal UIButton using that image
    [self.btnShowDirections setBackgroundImage:imageOff forState:UIControlStateNormal];
    [self.btnShowDirections setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    
    // Button MakeOne
    imagePress = [UIImage imageNamed:@"button_makeone_press"];
    [self.btnMake setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    
    // Mute button
    imagePress = [UIImage imageNamed:@"icon_audio_press"];
    [self.btnMute setBackgroundImage:imagePress forState:UIControlStateHighlighted];
    
    self.labelMakePlace.hidden = YES;
    self.tableDirections.hidden = YES;
    self.btnHideDirections.hidden = YES;
    self.btnHideDirections.enabled = NO;
    
    self.labelTitle.font = [UIFont fontWithName:kFontBold size:16];
    self.labelTitle.textColor = [FontHelpers colorFromHexString:@"#545454"];
    
    self.lableInstructionNum.font = [UIFont fontWithName:kFontBlack size:18];
    self.lableInstructionNum.textColor = [FontHelpers colorFromHexString:@"#545454"];
    
    self.labelName.font = [UIFont fontWithName:kFontBlack size:42];
    self.labelName.textColor = [UIColor whiteColor];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self disableAutoPlay];
}

- (void) disableAutoPlay
{
    NSLog(@"disableAutoPlay: %@", subTemplate.title);
    
    if (autoPlayTimer) {
        NSLog(@"Cancel autoPlay timer: %@", subTemplate.title);
        [autoPlayTimer invalidate];
        autoPlayTimer = nil;
    }
    
    if (videoCtrl.videoState != kVideoClosed)
    {
        NSLog(@"Close video: %@", subTemplate.title);
        [videoCtrl stopVideo:NO];
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
    
    textLabel.font = [UIFont fontWithName:kFontRegular size:14];
    textLabel.textColor = [FontHelpers colorFromHexString:@"#606060"];

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
    view.backgroundColor = [UIColor whiteColor];
    
    view.frame = CGRectMake(0,0,tableView.frame.size.width,20);

    UIImage *myImage = [UIImage imageNamed:@"directions_separator_shadow.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    imageView.frame = view.frame;
    
    UILabel *label = [[UILabel alloc] init];
    CGRect frame = view.frame;
    frame.origin.x += 10;
    label.frame = frame;
    label.text = NSLocalizedString(@"Directions:", nil);
    
    label.font = [UIFont fontWithName:kFontBlack size:16];
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

#pragma mark configure item

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
    [self configureBtnMute];
    
    if (videoCtrl && (videoCtrl.videoState != kVideoClosed)) {
        [videoCtrl stopVideo:NO];
        videoCtrl = nil;
    }
    
    videoCtrl = [[VideoPlayerViewController alloc] initWithView:self.videoView andURL:subTemplate.videoURL];
    [videoCtrl setDelegate:self withInfo:nil];
    [videoCtrl setTapGesture:YES];
}

- (void) configureBtnMake
{
    // Set the text inside the image
    NSString *text = NSLocalizedString(@"MAKE\nONE", nil);
    
    self.btnMake.titleLabel.font = [UIFont fontWithName:kFontBlack size:28];
    UIColor *color = [FontHelpers colorFromHexString:@"#ee3322"];
    [self.btnMake setTitle: text forState: UIControlStateNormal];
    [self.btnMake setTitleColor:color forState: UIControlStateNormal];
    
    // Adjust text to fit the frame
    self.btnMake.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnMake.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.btnMake.titleLabel.numberOfLines = 2;
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
    self.labelName.text = subTemplate.name;
    
    self.labelName.adjustsFontSizeToFitWidth = NO;
    self.labelName.numberOfLines = 0;
    
    CGFloat fontSize = 42;
    while (fontSize > 0.0)
    {
        UIFont *font = [UIFont fontWithName:kFontBlack size:fontSize];
        CGSize size = [self.labelName.text sizeWithFont:font constrainedToSize:CGSizeMake(self.labelName.frame.size.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];

        if (size.height <= self.labelName.frame.size.height) break;
        
        fontSize -= 1.0;
    }
    
    NSLog(@"Set font size %f", fontSize);
    self.labelName.font = [UIFont fontWithName:kFontBlack size:fontSize];
    [self setImage:subTemplate.imageURL];
}

- (void) configureTitle
{
    self.labelTitle.text = subTemplate.title;
    self.lableInstructionNum.text = [NSString stringWithFormat:@"%ld",(long)[subTemplate.instructions count]];
}

- (void) configureBtnMute
{
    self.btnMute.hidden = YES;
    self.btnMute.enabled = NO;
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

-(void)aAutoPlay: (NSTimer *)timer
{
    NSLog(@"aAutoPlay %@", subTemplate.title);
    self.btnMute.hidden = NO;
    self.btnMute.enabled = YES;
    autoPlayTimer = nil;
    [videoCtrl muteVideo:YES];
    [videoCtrl playVideo];
}

#pragma mark - Events from owner

- (void)currentlyPresented
{
    NSLog(@"currentlyPresented %@", subTemplate.title);
    
    if (videoCtrl.videoState == kVideoOpened) {
        NSLog(@"Video is already playing: do not set timer");
    } else {
        autoPlayTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(aAutoPlay:) userInfo:nil repeats:NO];
    }
}

- (void)currentlyDragged
{
    [self disableAutoPlay];
}


#pragma mark - Actions (MakeOne)

- (IBAction)btnMakeOneClicked:(id)sender {
    NSLog(@"btnMakeClicked for subTemplate: %@", subTemplate.title);
    [self.delegate makeOneClicked:subTemplate];
}

- (IBAction)btnMuteClicked:(id)sender {
    NSLog(@"btnMuteClicked for subTemplate: %@", subTemplate.title);
    [videoCtrl muteVideo:!videoCtrl.isMute];
    self.btnMute.hidden = YES;
    self.btnMute.enabled = NO;
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
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self setMakeOneSmaller];
                     }];
}

- (void) setDirectionTableUnhide
{
    CGRect frame = self.tableDirections.frame;
    frame.origin.y = self.btnHideDirections.frame.origin.y;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.tableDirections.frame= frame;
}

#define kMakeScale 0.6

- (void) setMakeOneSmaller
{
    self.btnMake.titleLabel.font = [UIFont fontWithName:kFontBlack size:18];
    self.btnMake.frame = self.labelMakePlace.frame;
    self.btnMake.bounds = self.labelMakePlace.bounds;
    self.btnMake.center = self.labelMakePlace.center;
    self.btnMake.alpha = 1.0f;
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
    self.btnMake.titleLabel.font = [UIFont fontWithName:kFontBlack size:28];
    self.btnMake.frame= btnMakeDirectionHideFrame;
    self.btnMake.alpha = 1.0f;
}

#pragma mark - Video player delegate

// The user tapped on the Video view
- (BOOL)videoShouldPlay: (id)userInfo
{
    [autoPlayTimer invalidate];
    autoPlayTimer = nil;
    return YES;
}

// The user tapped on the Video view
- (BOOL)videoShouldClose: (id)userInfo
{
    return YES;
}

// The video is ready to be played
- (void)videoIsReady: (id)userInfo
{

}

// The video was just closed
- (void)videoDidClose: (id)userInfo
{
    self.btnMute.hidden = YES;
    self.btnMute.enabled = NO;
    [videoCtrl muteVideo:NO];
}

// Do we support in one than one video instance
- (BOOL)videoShouldKeepActivePlayers: (id)userInfo
{
    return NO;
}

@end
