//
//  TagsDetailViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/19/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "TagsDetailViewController.h"
#import "SMSharedData.h"
#import "MBProgressHUD.h"
#import "SMPhotoFullScreenViewController.h"
#import "Utility.h"
#import "AdditionalInfoViewController.h"

@interface TagsDetailViewController ()
{
    NSDate *resumeDate;
    NSString *extension;
    NSString *uploadingExt;
    SMDropboxProgressViewController *progressVC;
    NSTimer *movieTimer;
    NSString *mainFileName;
}
@end

@implementation TagsDetailViewController
@synthesize detailImageView;
@synthesize tag;
@synthesize progressViewBGView;
@synthesize containerDetailsView;
@synthesize tagDetailsCaption;
@synthesize timerLabel;
@synthesize circularSlider;
@synthesize mainContainerScrollView;
@synthesize remainingCharactersLabel;
@synthesize tagDetailsCopyright;
@synthesize maxCharactersLabel;
@synthesize remainingCharacterCountLabel;
@synthesize statusBarView;
@synthesize videoControlsView;
@synthesize audioContainerView;
@synthesize movieSlider;
@synthesize videoTimeElapsedLabel;
@synthesize videoTimeRemainingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withDefaultView:(DefaultView)view
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        defaultView = view;
    }
    return self;
}

/**
 *  Enter video full screen mode
 *
 *  @param sender fullScreenButton
 */
- (IBAction)moviePlayerFullScreenButtonAction:(id)sender {
    [[SMSharedData sharedManager] setShouldAutorotate:YES];
    [moviePlayer setFullscreen:YES animated:YES];
    [moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
}

- (BOOL)shouldAutorotate{
    if ([[SMSharedData sharedManager] shouldAutorotate]==YES) {
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if([[SMSharedData sharedManager] shouldAutorotate]==YES)
    {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveMethod) name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)kbDidShow:(NSNotification *)note
{
    UITextRange *selectionRange = noteTextView.selectedTextRange;
    if([noteTextView isFirstResponder]) {
        CGRect selectionEndRect = [noteTextView caretRectForPosition:selectionRange.end];
        CGRect finalRect = CGRectMake(selectionEndRect.origin.x, selectionEndRect.origin.y + noteTextView.frame.origin.y, 10, 100);
        [self.mainContainerScrollView scrollRectToVisible:finalRect animated:YES];
    }
}

/**
 *  Returns the view to be zoomed and faded in/out while being presented or dismissed
 *
 *  @return viewToBeZoomed
 */
-(UIView *)getViewToFade{
    switch ((int)tag.type) {
        case 2:
            return moviePlayer.view;
        case 3:
            return self.detailImageView;
        case 4:
            return noteTextView;
    }
    return  self.progressViewBGView;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.view.alpha==0) {
        UIView *viewToFade=[self getViewToFade];
        CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
        f.origin.x  = f.origin.x + 10;
        CGRect firstFrame= viewToFade.frame;
        // Zoom in animation
        [viewToFade setFrame:f];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:firstFrame];
            [self.view setAlpha:1.0];
        } completion:^(BOOL finished) {
            // Show cancel(Back) button when zoomed in
            [cancelButton setHidden:NO];
            if (tag.type==2) {
                // Show movie seek bar once presented completely
                [UIView animateWithDuration:k_ANIMATION animations:^{
                    [self.movieSlider setAlpha:1.0];
                }];
            }
        }];
    }
    if (tag.type==2) {
        // Settings according to video view
        if(moviePlayer.playbackState == MPMoviePlaybackStatePaused)
            [self.moviePlayPauseButton setSelected:NO];
        [moviePlayer setControlStyle:MPMovieControlStyleNone];
        [[SMSharedData sharedManager] setShouldAutorotate:NO];
        
        
        [self tagUpdated];
        
        if(tag.points.count > 0)
        {
            [self.recordBarButton setEnabled:YES];

            [self.recordBarButton setTitle:[NSString stringWithFormat:@"Records (%lu)",tag.points.count]];
        }
        else
        {
            [self.recordBarButton setEnabled:NO];
            [self.recordBarButton setTitle:[NSString stringWithFormat:@"No Records"]];

        }

        
    }
    if(tag.type==4)
    {
        // Scroll notes text view to top initially
        [noteTextView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    }
    
    
    
    /// Check Point: Destination for method : afterAnimation

    if (!isloaded){
        // viewController is visible
        [self afterAnimation];

    }
    
    
}

- (void)tagUpdated
{
    if(tag.points.count > 0 || tag.sabrepoints > 0 || tag.foilpoints)
    {
        [self.recordBarButton setEnabled:YES];
        
        
        if (tag.pointType == POINT_EPEE || tag.pointType == POINT_FOIL || tag.pointType == POINT_SABRE) {
            [self.recordBarButton setTitle:[NSString stringWithFormat:@"Records (%lu)",tag.points.count]];
        }
//        else if (tag.pointType == POINT_FOIL)
//        {
//            [self.recordBarButton setTitle:[NSString stringWithFormat:@"Records (%lu)",tag.foilpoints.count]];
//
//        }
//        else if (tag.pointType == POINT_SABRE)
//        {
//            [self.recordBarButton setTitle:[NSString stringWithFormat:@"Records (%lu)",tag.sabrepoints.count]];
//
//        }
    }
    else
    {
        [self.recordBarButton setEnabled:NO];
        [self.recordBarButton setTitle:[NSString stringWithFormat:@"No Records"]];
        
    }
    
    // Nav title
    NSString *name =tag.name ;
    navItem.title =  [name stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                   withString:[[name substringToIndex:1] capitalizedString]] ;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagUpdated) name:UPDATE_LIST  object:nil];

    
    self.wantsFullScreenLayout = YES;
    NSString *filename =tag.name;
    // Set filename in title field, if length is more than maximum number of characters allowed, trim the name and show it.
    self.tagDetailsName.text = (filename.length>MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME)?[filename substringToIndex:MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME]:filename;
    // Feed into other fields
    self.tagDetailsLocation.text = tag.address;
    self.tagDetailsCaption.text = tag.caption;
    self.tagDetailsCopyright.text = tag.copyright;
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    NSDate *date = tag.dateTaken;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
//    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    self.tagDetailsDate.text = [NSString stringWithFormat:@"%@",dateString];
    self.tagDetailsName.delegate = self;
    self.tagDetailsLocation.delegate= self;
    self.tagDetailsCaption.delegate= self;
    self.tagDetailsCopyright.delegate=self;
    [self.tagDetailsDate setDelegate:self];
    shouldDismiss = YES;
    NSString *name =tag.name ;
    navItem.title =  [name stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                   withString:[[name substringToIndex:1] capitalizedString]] ;
    mainFileName = tag.name;
    
    
    
    /// Check Point: Origin for method : afterAnimation
   
}


- (void)afterAnimation
{
    isloaded = TRUE;
    
    // Default view - type of file being shown
    if (defaultView == 3) {
        [self displayImage];
    }
    if (defaultView == 1) {
        [self initializeAudioPlayer];
        NSTimeInterval elapsedTime = roundf([audioPlayer duration]);
        // Divide the interval by 3600 and keep the quotient and remainder
        div_t h = div(elapsedTime, 3600);
        // int hours =  floor(h.quot);
        // Divide the remainder by 60; the quotient is minutes, the remainder
        // is seconds.
        div_t m = div(h.rem, 60);
        int minutes = floor(m.quot);
        int seconds = floor(m.rem);
        // If you want to get the individual digits of the units, use div again
        // with a divisor of 10.
        [totalAudioDurationLabel setText:[NSString stringWithFormat:@" / %02d:%02d", minutes,seconds]];
        [playButton setHidden:NO];
        [self.detailImageView setHidden:YES];
    }
    if (defaultView == 2) {
        [self displayVideo];
    }
    if (defaultView == 4) {
        [self.view bringSubviewToFront:navigationBar];
        [noteTextView setHidden:NO];
        [noteTextView setDelegate:self];
        NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
        NSString *strTest = url.path;
        // NSLog{@"? %d",[[NSFileManager defaultManager] fileExistsAtPath:strTest]);
        NSData *data = [NSData dataWithContentsOfFile:strTest];
        noteTextView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.audioContainerView setHidden:YES];
        [self.detailImageView setHidden:YES];
    }
    // Editing mode flag initially set to NO
    startedEditing = NO;
    [self setDetailViewAttributes];
    if(tag.type == 1)
        [progressViewBGView setHidden:NO];
    [self customizeTextFont];
    if (tag.dateTaken)
        newDate = tag.dateTaken;
    else
        newDate = tag.dateTaken = [NSDate date];
    [self textViewDidEndEditing:self.tagDetailsCaption];
    if(![self.tagDetailsCaption.text isEqualToString:@"Caption"])
        [self.tagDetailsCaption setTextColor:[UIColor darkGrayColor]];
    //  Double Tap Gesture for entering in photo full screen mode
    UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    [tapGestureRecoginzer setNumberOfTapsRequired:2];
    [tapGestureRecoginzer setNumberOfTouchesRequired:1];
    [self.detailImageView addGestureRecognizer:tapGestureRecoginzer];
    [self.circularSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    [self.circularSlider setDelegate:self];     [self.circularSlider setMinimumValue:0.0];
    [self.circularSlider setMaximumValue:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinishPlaying)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVideoLabels:) name:MPMovieDurationAvailableNotification object:nil];
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-self.tagDetailsName.text.length;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    // Set auto capitalize sentences for all text fields
    self.tagDetailsName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsLocation.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsCopyright.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsCaption.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [self adjustMainScrollViewFrame];
    if (tag.type==4)
        [self adjustScrollViewAccordingToNoteTextView];
    if (self.tagDetailsCaption && [self.tagDetailsCaption.text isEqualToString:@""]) {
        [self.tagDetailsCaption setText:@"Caption"];
        [self.tagDetailsCaption setTextColor:PLACEHOLDER_TEXT_COLOR]; //optional
    }
    [saveBarButton setEnabled:YES];
    CGFloat standardHeight=IS_IPHONE5?443:355;
    CGRect frame = self.containerDetailsView.frame;
    frame.origin.y = standardHeight;
    frame.origin.y = frame.origin.y +20;
    
    [self.containerDetailsView setFrame:frame];
    
    if (IS_IPAD)
    {
        [self.containerDetailsView setFrame:CGRectMake(self.mainContainerScrollView.frame.size.width/2 - self.containerDetailsView.frame.size.width/2 , self.videoControlsView.frame.origin.y+self.videoControlsView.frame.size.height + 10, self.containerDetailsView.frame.size.width, self.containerDetailsView.frame.size.height)];
    }
    
    CGSize cSize = self.mainContainerScrollView.contentSize;
    cSize.height = standardHeight + self.containerDetailsView.frame.size.height;
    [self.mainContainerScrollView setContentSize:cSize];
}

-(void)tapGestureDetected:(UIGestureRecognizer *)gesture{
    if (tag.type == 3) {
        // Detect if it is photo
        NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", tag.name]];
        }
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //[window makeKeyAndVisible];
        [[SMSharedData sharedManager] setMainWindow:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
        [[SMSharedData sharedManager] setShouldAutorotate:YES];
        [[UIApplication sharedApplication].delegate setWindow:window];
        // Enter full screen mode
        SMPhotoFullScreenViewController *photoVC = [[SMPhotoFullScreenViewController alloc] initWithNibName:@"SMPhotoFullScreenViewController" bundle:nil andWithImageAtPath:url.path];
        [window setRootViewController:photoVC];
        [window makeKeyAndVisible];
    }
}

/**
 *  Set video duration and remaining time labels
 *
 *  @param note notification
 */
-(void)setVideoLabels:(NSNotification *)note{
    int currentPlayback =(int)moviePlayer.currentPlaybackTime;
    [self.videoTimeElapsedLabel setText:[NSString stringWithFormat:@"%02d:%02d",currentPlayback/60,currentPlayback%60]];
    [self.videoTimeRemainingLabel setText:[NSString stringWithFormat:@"-%02d:%02d",(int)(moviePlayer.duration-currentPlayback)/60,(int)(moviePlayer.duration-currentPlayback)%60]];
}

-(void)moviePlayerDidFinishPlaying{
    // Reset movie player to start
    [moviePlayer setCurrentPlaybackTime:0.0];
    [movieTimer invalidate];
    [self.movieSlider setValue:0.0];
    [self.moviePlayPauseButton setSelected:NO];
    [self setVideoLabels:nil];
    
    [self displayVideo];
}

/**
 *  Adjust main scroll view according to the contents in customised caption field
 */
-(void) adjustMainScrollViewFrame{
    NSString *str = self.tagDetailsCaption.text;
    CGSize textSize = [str sizeWithFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL] constrainedToSize:CGSizeMake(self.tagDetailsCaption.contentSize.width-10, 20000) lineBreakMode: NSLineBreakByTruncatingTail];
    textSize.width = self.tagDetailsCaption.frame.size.width;
    textSize.height = textSize.height+13;
    if (textSize.height > 30) {
        textSize.height = textSize.height + 3;
    } else {
        textSize.height = 30;
    }
    [self.tagDetailsCaption setContentSize:textSize];
    CGRect frame = self.tagDetailsCaption.frame;
    CGFloat heightDifference =  self.tagDetailsCaption.contentSize.height - frame.size.height;
    frame.size = self.tagDetailsCaption.contentSize;
    // Adjust origins and heights of all metadata fields and container view according to the contents of caption field
    [self.tagDetailsCaption setFrame:frame];
    [self.tagDetailsLocation setCenter:CGPointMake(self.tagDetailsLocation.center.x, self.tagDetailsLocation.center.y+heightDifference)];
    [self.tagDetailsDate setCenter:CGPointMake(self.tagDetailsDate.center.x, self.tagDetailsDate.center.y+heightDifference)];
    [self.tagDetailsCopyright setCenter:CGPointMake(self.tagDetailsCopyright.center.x, self.tagDetailsCopyright.center.y+heightDifference)];
    CGRect containerFrame2 = self.containerDetailsView.frame;
    containerFrame2.size.height = containerFrame2.size.height+heightDifference;
    [self.containerDetailsView setFrame:containerFrame2];
    
    if (IS_IPAD)
    {
        [self.containerDetailsView setFrame:CGRectMake(self.mainContainerScrollView.frame.size.width/2 - self.containerDetailsView.frame.size.width/2 , self.videoControlsView.frame.origin.y+self.videoControlsView.frame.size.height + 10, self.containerDetailsView.frame.size.width, self.containerDetailsView.frame.size.height)];
    }
    
    [self.mainContainerScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.containerDetailsView.frame.origin.y+self.containerDetailsView.frame.size.height)];
}

/**
 *  Adjust main container scroll view according to the notes text view
 */
-(void)adjustScrollViewAccordingToNoteTextView{
    CGFloat oldHeight = noteTextView.frame.size.height;
    CGRect rect = noteTextView.frame;
    [noteTextView sizeToFit];
    CGFloat standardHeight=IS_IPHONE5?393:305;
    if (noteTextView.frame.size.height<standardHeight)
        rect.size.height = standardHeight;
    else
        rect.size.height = noteTextView.frame.size.height;
    [noteTextView setFrame:rect];
    if (noteTextView.frame.size.height > standardHeight-30)
    {
        rect.size.height = noteTextView.frame.size.height;
        [noteTextView setFrame:rect];
        CGFloat heightDifference  = rect.size.height - oldHeight;
        CGSize cSize = self.mainContainerScrollView.contentSize;
        cSize.height = cSize.height+heightDifference;
        [self.mainContainerScrollView setContentSize:cSize];
        [self.containerDetailsView setCenter:CGPointMake(self.containerDetailsView.center.x, self.containerDetailsView.center.y+heightDifference)];
    }
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // return view to be zoomed
    return self.detailImageView;
}

/**
 *  Circular Progress Seeking Completed Delegate
 *
 *  @param value value to be seek audio at
 */
-(void)seekAudioTo:(float)value{
    if(!audioPlayer)
        [self initializeAudioPlayer];
    
    float duration = [audioPlayer duration]*value;
    [audioPlayer setCurrentTime:duration];
    // Calculate the percentage of audio
    NSInteger currentTime= audioPlayer.duration*value;
    self.percentage =(currentTime/[audioPlayer duration]);
    countmin=(int)currentTime/60;
    countsec=(int)currentTime%60;
}

/**
 *  Circular Progress Seeking in progress delegate
 *
 *  @param value seeking at value
 */
-(void)seekingInProgressAtValue:(float)value{
    if(!audioPlayer)
        [self initializeAudioPlayer];
    
    NSInteger currentTime= audioPlayer.duration*value;
    self.percentage =(currentTime/[audioPlayer duration]);
    countmin=(int)currentTime/60;
    countsec=(int)currentTime%60;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec];
//    if(audioPlayer.isPlaying)
//        [self pauseAudio];
}

- (void)updateProgress:(UISlider *)sender {
	[self.circularSlider setValue:sender.value];
}

-(void) initializeAudioPlayer{
    // Initialize audio player with file url
    NSError *error = nil;
    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:url.path] error:&error];
    [audioPlayer setDelegate:self];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {
        // handle error
    }
}

/**
 *  Activate edit mode
 */
-(void) startEditing{
    startedEditing = YES;
    [saveBarButton.customView setHidden:NO];
    [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
}

/**
 *  Deactivate edit mode
 */
-(void) endEditing{
    startedEditing = NO;
    [saveBarButton.customView setHidden:YES];
    [cancelButton setTitle:@"BACK" forState:UIControlStateNormal];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // Handle customised placeholder of caption field
    if (textView == self.tagDetailsCaption && [textView.text isEqualToString:@"Caption"]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    if (textView==noteTextView)
        return;
    // If not Notes text view then respond to delegate methods of keyboard avoiding scroll view's delegate methods
    [self textFieldDidBeginEditing:nil];
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // Handle customised placeholder of caption field
    if(textView==self.tagDetailsCaption)
    {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Caption";
            textView.textColor = PLACEHOLDER_TEXT_COLOR; //optional
        }
    }
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Dismiss keyboard after tapping on return key
    if([text isEqualToString:@"\n"])
        [self showFullScrollView];
    if (textView != noteTextView)
        return YES;
    const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
    // Don't allow more characters than allowed to be entered except backspace
    int isBackSpace = strcmp(_char, "\b");
    NSInteger afterCount = (noteTextView.text.length-range.length+text.length);
    if(afterCount>=kMaximumCharacterCountForNote+1 && textView == noteTextView && isBackSpace != -8)
        return NO;
    return YES;
}

/**
 *  Apply text attributes to all customised text fields
 */
-(void) customizeTextFont{
    [self.tagDetailsCaption setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsName setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsDate setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsLocation setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsCopyright setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [noteTextView setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [timerLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TIMER_LABEL]];
    [timerLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [totalAudioDurationLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [totalAudioDurationLabel setTextColor:REPORTABLE_CREAM_COLOR];
    if (tag.type == 4) {
        // It it's Note details view
        [self.maxCharactersLabel setFont:[FONT_LIGHT size:FONT_SIZE_FOR_TAG]];
        [self.maxCharactersLabel setTextColor:REPORTABLE_CREAM_COLOR];
        [self.remainingCharacterCountLabel setFont:[FONT_LIGHT size:FONT_SIZE_FOR_TAG]];
        [self.remainingCharacterCountLabel setTextColor:REPORTABLE_ORANGE_COLOR];
        [self.maxCharactersLabel setText:[NSString stringWithFormat:@"Max characters: %d",kMaximumCharacterCountForNote]];
        [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)noteTextView.text.length]];
        [self.maxCharactersLabel setHidden:NO];
        [self.remainingCharacterCountLabel setHidden:NO];
        [noteTextView.layer setZPosition:-100];
    }
}

- (void)timerFired:(NSTimer *)timer
{
    // Timer method for audio play
    CGFloat currentTime =[audioPlayer currentTime];
    self.percentage =(currentTime/[audioPlayer duration]);
    countmin=(int)currentTime/60;
    countsec=(int)currentTime%60;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec];
    CGFloat elapsedTime = countsec+(countmin*60);
    if (elapsedTime>=audioPlayer.duration) {
        [self.timer invalidate];
        self.timer = nil;
        self.percentage = 0;
        countsec = countmin = 0;
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec];
    }
    [self.circularSlider setValue:self.percentage];
}
/**
 *  Returns a subview to be added on left in a text field as a padding
 *
 *  @return paddingView
 */
-(UIView *)addSideView
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
}

/**
 *  Set inset attributes to details view metadata fields
 */
-(void) setDetailViewAttributes
{
    [self.tagDetailsLocation setRightView:[self addSideView]];
    [self.tagDetailsLocation setRightViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsLocation setLeftView:[self addSideView]];
    [self.tagDetailsLocation setLeftViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsDate setRightView:[self addSideView]];
    [self.tagDetailsDate setRightViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsDate setLeftView:[self addSideView]];
    [self.tagDetailsDate setLeftViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsName setLeftView:[self addSideView]];
    [self.tagDetailsName setLeftViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsCopyright setRightView:[self addSideView]];
    [self.tagDetailsCopyright setRightViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsCopyright setLeftView:[self addSideView]];
    [self.tagDetailsCopyright setLeftViewMode:UITextFieldViewModeAlways];
    self.tagDetailsCaption.layer.sublayerTransform = CATransform3DMakeTranslation(2, -1, 0);
}

-(void)textViewDidChange:(UITextView *)textView{
    if (textView == noteTextView){
        // Count remaining characters in notes text view and update label
        NSInteger currentCount= [textView.text length];
        [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)currentCount]];
        if(currentCount >=kMaximumCharacterCountForNote)
        {
            [textView setText:[textView.text substringToIndex:kMaximumCharacterCountForNote]];
            [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)kMaximumCharacterCountForNote]];
        }
        [self adjustScrollViewAccordingToNoteTextView];
    }
    else{
        // Check if caption field reaches maximum number of lines allowed
        NSUInteger numLines = textView.contentSize.height/textView.font.lineHeight;
        if (numLines > MAXIMUM_LINES_LIMIT_FOR_CAPTION_FIELD)
        {
            textView.text = [textView.text substringToIndex:textView.text.length - 1];
            return;
        }
        [self adjustMainScrollViewFrame];
    }
    [self startEditing];
    NSRange range =[textView.text rangeOfString:[textView.text substringFromIndex:textView.text.length]];
    [textView scrollRangeToVisible:range];
}

/**
 *   Resign first responders of metadata fields
 */
-(void) showFullScrollView{
    [noteTextView resignFirstResponder];
    if(datePicker)
        [self resignDatePicker];
    [self.tagDetailsName resignFirstResponder];
    [self.tagDetailsLocation resignFirstResponder];
    [self.tagDetailsCaption resignFirstResponder];
    [self.tagDetailsCopyright resignFirstResponder];
}

/**
 *  Stop audio playback
 *
 *  @param sender stopButton
 */
-(IBAction)stopPlayingAudio:(id)sender{
    if(audioPlayer)
    {
        [self stop:nil];
        audioPlayer = nil;
        [self.timer invalidate];
        self.timer = nil;
        [stopButton setEnabled:NO];
        countsec = countmin = 0;
        self.percentage = 0;
        [self.circularSlider setValue:self.percentage];
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec];
    }
}

/**
 *  Pause audio playback
 */
-(void)pauseAudio{
    [audioPlayer pause];
    [self.timer invalidate];
    [playButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
}

/**
 *  Toggle Audio play/pause playback
 *
 *  @param sender playPauseButton
 */
- (IBAction)playAudio:(id)sender{
    if(audioPlayer.isPlaying){
        [self pauseAudio];
    }
    else{
        [playButton setImage:[UIImage imageNamed:@"stopRecording.png"] forState:UIControlStateNormal];
        [stopButton setEnabled:YES];
        [self initializeTimer];
        if(!audioPlayer)
            [self initializeAudioPlayer];
        [audioPlayer play];
        if (audioPlayer.currentTime==0.0&&self.percentage!=0.0) {
            [self stopPlayingAudio:nil];
        }
    }
}

-(void) initializeTimer{
    // Initialise the timer for audio playback
    if(self.timer)
        [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05f
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // Audio playback finised playing. Reset timers and change button states
    [self stopPlayingAudio:nil];
    [self setupPlayButton];
}

- (void)displayImage{
    // Set image in details view
    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
    UIImage *image = [UIImage imageWithContentsOfFile:url.path];
    selectedTagImage = image;
    [detailImageView setImage:image];
    [detailImageView setAlpha:1.0];
    self.title = tag.name;
    navItem.title = tag.name;
}

- (void)setupStopPlayButton
{
    [playButton setTag:2001];
    [playButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupPlayButton
{
    [playButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
    [playButton setTag:2000];
}

- (void)stop:(id)sender
{
    if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    [self setupPlayButton];
}

-(void)applicationWillResignActiveMethod{
    if (tag.type==1)
        [self pauseAudio];
    if (tag.type==2)
    {
        [self.moviePlayPauseButton setSelected:NO];
        [self pauseVideo];
    }
}

/**
 *  Initialise and present movie player with video file loaded
 */
- (void) displayVideo{
    if( moviePlayer )
        moviePlayer = nil;
    NSURL *videoURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
    moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:videoURL.path]];
    moviePlayer.controlStyle = MPMovieScalingModeFill;
    [moviePlayer.view setContentMode:UIViewContentModeScaleToFill];
    moviePlayer.fullscreen=YES;

    [self.movieSlider setThumbImage:[UIImage imageNamed:@"seeker_icon.png"] forState:UIControlStateNormal];
    [self.movieSlider setMaximumTrackTintColor:[UIColor blackColor]];
    [self.movieSlider setMinimumTrackTintColor:[UIColor colorWithRed:162/255.0 green:65/255.0 blue:14/255.0 alpha:1.0]];
    [moviePlayer.view setAutoresizingMask:self.detailImageView.autoresizingMask];
    [self.mainContainerScrollView addSubview:moviePlayer.view];
    CGRect scrolViewFrame = self.mainContainerScrollView.frame;
    CGRect f = self.detailImageView.frame;
    self.detailImageView.frame = CGRectMake(0, f.origin.y, scrolViewFrame.size.width, f.size.height);
     f = self.detailImageView.frame;
    
    f.size.height = f.size.height - self.videoControlsView.frame.size.height-40;
    [moviePlayer.view setFrame:f];
    [self.mainContainerScrollView addSubview:self.videoControlsView];
    [self.videoControlsView setFrame:CGRectMake(moviePlayer.view.frame.origin.x, moviePlayer.view.frame.origin.y+ moviePlayer.view.frame.size.height+(IS_IPHONE5?0:8), moviePlayer.view.frame.size.width, self.videoControlsView.frame.size.height)];
    
    
    // Remove the movie player view controller from the "playback did finish" notification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    
    [moviePlayer setShouldAutoplay:NO];
    [moviePlayer  setRepeatMode:MPMovieRepeatModeOne];
    [moviePlayer setCurrentPlaybackTime:0.0];
    [self.view bringSubviewToFront:navigationBar];
    
    
    for (UIButton * btn in self.containerDetailsView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn removeFromSuperview];
        }
    }
    
    [self.containerDetailsView setFrame:CGRectMake(-20, moviePlayer.view.frame.size.height+145, self.containerDetailsView.frame.size.width, self.containerDetailsView.frame.size.height)];
    
    if (IS_IPAD)
    {
        [self.containerDetailsView setFrame:CGRectMake(self.mainContainerScrollView.frame.size.width/2 - self.containerDetailsView.frame.size.width/2 , self.videoControlsView.frame.origin.y+self.videoControlsView.frame.size.height + 10, self.containerDetailsView.frame.size.width, self.containerDetailsView.frame.size.height)];
    }
    
    UIImage *image = [UIImage imageNamed:@"toolBar.png"];
    [tagToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    
//    UIButton * addPoint = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [addPoint addTarget:self action:@selector(showFormVC) forControlEvents:UIControlEventTouchUpInside];
//    [addPoint setTintColor:[UIColor whiteColor]];
//
//    // CGFloat x = (self.containerDetailsView.frame.size.width/2) - 20 ;
//    [addPoint setFrame:CGRectMake(20, 5, self.containerDetailsView.frame.size.width/2 - 30, 35)];
//   // [addPoint setImage:[UIImage imageNamed:@"addPoint.png"] forState:UIControlStateNormal];
//    [addPoint setTitle:@"Add Point" forState:UIControlStateNormal];
//
//     [addPoint setBackgroundImage:[UIImage imageNamed:@"Btn_02.png"] forState:UIControlStateNormal];
//
//    [self.containerDetailsView addSubview:addPoint];
//
//    
//
//    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn addTarget:self action:@selector(grabPhotoAndLoadVC) forControlEvents:UIControlEventTouchUpInside];
//    [btn setTintColor:[UIColor whiteColor]];
//    [btn setFrame:CGRectMake(self.containerDetailsView.frame.size.width - self.containerDetailsView.frame.size.width/2 - 5, 5, self.containerDetailsView.frame.size.width/2 - 30, 35)];
//    [btn setTitle:@"Grab Photo" forState:UIControlStateNormal];
//
//    [btn setBackgroundImage:[UIImage imageNamed:@"Btn_02.png"] forState:UIControlStateNormal];
//    
//    [self.containerDetailsView addSubview:btn];

    
//    UIButton * btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn3 addTarget:self action:@selector(grabPhotoAndLoadVC) forControlEvents:UIControlEventTouchUpInside];
//    [btn3 setTintColor:[UIColor whiteColor]];
//    // CGFloat x = (self.containerDetailsView.frame.size.width/2) - 20 ;
//    [btn3 setFrame:CGRectMake(self.containerDetailsView.frame.size.width - (self.containerDetailsView.frame.size.width/3 +10 ), 5, self.containerDetailsView.frame.size.width/3 - 30, 35)];
//    //    [btn setImage:[UIImage imageNamed:@"imageediting.png"] forState:UIControlStateNormal];
//    [btn3 setTitle:@"More..." forState:UIControlStateNormal];
//    
//    [btn3 setBackgroundImage:[UIImage imageNamed:@"Btn_02.png"] forState:UIControlStateNormal];
//
//    
//    
//    
//    [self.containerDetailsView addSubview:btn3];
    
    

    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidShowNotification object:self];
    
    [moviePlayer setControlStyle:MPMovieControlStyleNone];
    
    
    if (IS_IPAD)
    {
        [self.containerDetailsView setFrame:CGRectMake(self.mainContainerScrollView.frame.size.width/2 - self.containerDetailsView.frame.size.width/2 , self.videoControlsView.frame.origin.y+self.videoControlsView.frame.size.height + 10, self.containerDetailsView.frame.size.width, self.containerDetailsView.frame.size.height)];
   }

}


- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
        
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        // Dismiss the view controller
    }
}


#pragma mark - Toolbar Button Action

- (IBAction)addPointButtonAction:(id)sender
{
    if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying||moviePlayer.playbackState==MPMoviePlaybackStateSeekingForward||moviePlayer.playbackState==MPMoviePlaybackStateSeekingBackward) {
        [moviePlayer pause];
        [self.moviePlayPauseButton setSelected:NO];
    }
    
    
    [self showFormVC];
}

- (IBAction)grabPhotoButtonAction:(id)sender
{
    if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying||moviePlayer.playbackState==MPMoviePlaybackStateSeekingForward||moviePlayer.playbackState==MPMoviePlaybackStateSeekingBackward) {
        [moviePlayer pause];
        [self.moviePlayPauseButton setSelected:NO];
    }

    
    [self grabPhotoAndLoadVC];
}


- (IBAction)recordedPointButtonAction:(id)sender
{
  //  PointsDetailViewController * vc = [[PointsDetailViewController alloc] init];
    
    if(tag.points.count > 0|| tag.sabrepoints.count > 0 || tag.foilpoints.count > 0)
    {
        
        NSMutableArray * tmpOBJ = [[NSMutableArray alloc] init];
        
        
        if (tag.pointType == POINT_SABRE || tag.pointType == POINT_FOIL || tag.pointType == POINT_EPEE)
        {
            for (NSDictionary * dict in tag.points)
            {
                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
            }

        }
//        else if (tag.pointType == POINT_FOIL)
//        {
//            for (NSDictionary * dict in tag.foilpoints)
//            {
//                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
//            }
//        }
//        else if (tag.pointType == POINT_EPEE)
//        {
//            for (NSDictionary * dict in tag.points)
//            {
//                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
//            }
//        }
        
        SSPopup* selection=[[SSPopup alloc]init];
        selection.backgroundColor=[UIColor blackColor];
        
        selection.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
        selection.SSPopupDelegate=self;
        [self.view  addSubview:selection];
        
        [selection CreateTableview:tmpOBJ withSender:sender  withTitle:@"Recorded Points" setCompletionBlock:^(NSString * actionName){
            
            NSLog(@"Tag--->%@",actionName);
            
            
            if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying||moviePlayer.playbackState==MPMoviePlaybackStateSeekingForward||moviePlayer.playbackState==MPMoviePlaybackStateSeekingBackward) {
                [moviePlayer pause];
                [self.moviePlayPauseButton setSelected:NO];
            }
            
            
            
            NSInteger index = [tmpOBJ indexOfObject:actionName];
            
            NSMutableDictionary * dict;
            
            FormViewController *formVC = nil;
            
            NSString * xibName = nil;
            
//            if (tag.pointType == POINT_SABRE) {
//              xibName = @"FormViewController";
//                dict = [tag.sabrepoints objectAtIndex:index];
//            }
//            else if (tag.pointType == POINT_FOIL)
//            {
//                xibName = @"FormViewController";
//                dict = [tag.foilpoints objectAtIndex:index];
//            }
             if (tag.pointType == POINT_EPEE || tag.pointType == POINT_SABRE || tag.pointType == POINT_FOIL)
            {
                xibName = @"FormViewController";
                dict = [tag.points objectAtIndex:index];
            }
            
            formVC = [[FormViewController alloc] initWithNibName:xibName bundle:nil];
            
            formVC.modalPresentationStyle=UIModalPresentationFormSheet;
            
            if (dict) {
                formVC.currentFormData = [[NSMutableDictionary alloc] initWithDictionary:dict];
            }
            
            formVC.isUpdatingPoint = TRUE;
            formVC.selectedAction = actionName;
            formVC.smtag = self.tag;
            
            
            [formVC.view setFrame:[[UIScreen mainScreen] bounds]];
            
            [self presentViewController:formVC animated:YES completion:nil];

            
        }];
        
    }

    
}


#pragma mark - Image EDITING Button Action

- (void)showFormVC
{
    if(self.mainVC)
    {
//       CFRelease((__bridge CFTypeRef)(self.mainVC));
//        self.mainVC = nil;
    }
    
//    self.mainVC = [[FormViewController alloc] initWithNibName:@"FormViewController" bundle:nil];
    
    
    FormViewController *formVC = nil;
    
    
    
    NSString * xibName = nil;
    
    if (tag.pointType == POINT_SABRE) {
        xibName = @"FormViewController";
    }
    else if (tag.pointType == POINT_FOIL)
    {
        xibName = @"FormViewController";
    }
    else if (tag.pointType == POINT_EPEE)
    {
        xibName = @"FormViewController";
    }
    
    formVC = [[FormViewController alloc] initWithNibName:xibName bundle:nil];

    
    formVC.modalPresentationStyle=UIModalPresentationFormSheet;
    
    formVC.smtag = self.tag;
    
    
    [formVC.view setFrame:[[UIScreen mainScreen] bounds]];
    
    [self presentViewController:formVC animated:YES completion:nil];

}

- (void) grabPhotoAndLoadVC
{
    
    if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying)
    {
        [self.moviePlayPauseButton setSelected:NO];
        [self pauseVideo];
    }

    UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:moviePlayer.currentPlaybackTime timeOption:MPMovieTimeOptionExact];

    
    self.viewController = [ACEViewController new];

    [self.viewController.view setFrame:self.view.bounds];
    
    
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromTop;
//    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [self.viewController.view.layer addAnimation:transition forKey:nil];
    [self.view addSubview:self.viewController.view];
    
    [self.viewController.baseImageView setImage:thumbnail];
    
}


#pragma mark - playback time of video according to the timer


/**
 *  Update playback time of video according to the timer
 *
 *  @param theTimer timer
 */
- (void)updatePlaybackTime:(NSTimer*)theTimer {
    if(moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
        [self.movieSlider setValue:moviePlayer.currentPlaybackTime/moviePlayer.duration animated:YES];
    [self setVideoLabels:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(datePicker)
    {
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    self.mainContainerScrollView.currentTextView = textView;
    return YES;
}

/**
 *  Save file wit edited metadata
 *
 *  @param sender saveButton
 */
- (IBAction)saveEditedButtonAction:(id)sender
{
    // INFO button Action
     AdditionalInfoViewController * viewController = [[AdditionalInfoViewController alloc] initWithNibName:@"AdditionalInfoViewController" bundle:nil];
    viewController.modalPresentationStyle=UIModalPresentationFormSheet;

    viewController.smtag = self.tag;
    
//    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:viewController animated:YES completion:^{
    }];
    
    return;
    
    
////////////////////////////////////////////////////////////
    
    if (newDate==nil) {
        if (tag.dateTaken)
            newDate = tag.dateTaken;
        else
            tag.dateTaken = newDate = [NSDate date];
    }
    else
        tag.dateTaken = newDate;
    // Check if title exists. Alert if it does not.
    if([self.tagDetailsName.text isEqualToString:@""])
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Filename cannot be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    // Check if customised caption field has text entered in it
    if ([Utility color:self.tagDetailsCaption.textColor matchesColor:PLACEHOLDER_TEXT_COLOR]) {
        self.tagDetailsCaption.text = tag.caption = @"";
    }
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    [self.tagDetailsName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *fname=[[[self.tagDetailsName.text substringToIndex:1] uppercaseString] stringByAppendingString:[self.tagDetailsName.text substringFromIndex:1]];
    [self.tagDetailsName setText:[fname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if(![self.tagDetailsCaption.text isEqualToString:@""])
        [self.tagDetailsCaption setText:[[[self.tagDetailsCaption.text substringToIndex:1] uppercaseString] stringByAppendingString:[self.tagDetailsCaption.text substringFromIndex:1]]];
    if(![self.tagDetailsLocation.text isEqualToString:@""])
        [self.tagDetailsLocation setText:[[[self.tagDetailsLocation.text substringToIndex:1] uppercaseString] stringByAppendingString:[self.tagDetailsLocation.text substringFromIndex:1]]];
    if(![self.tagDetailsCopyright.text isEqualToString:@""])
        [self.tagDetailsCopyright setText:[[[self.tagDetailsCopyright.text substringToIndex:1] uppercaseString] stringByAppendingString:[self.tagDetailsCopyright.text substringFromIndex:1]]];
    if(!startedEditing)
    {
        // No changes made, just close
        [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
        UIView *viewToFade=[self getViewToFade];
        CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
        f.origin.x  = f.origin.x + 10;
        CGRect firstFrame= viewToFade.frame;
        [viewToFade setFrame:firstFrame];
        [self.mainContainerScrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
        [cancelButton setHidden:YES];
//        [saveButton setHidden:YES];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:f];
            [self.view setAlpha:0.0];
        } completion:^(BOOL finished) {
            
            if( audioPlayer )
            {
                [self stop:nil];
                audioPlayer = nil;
            }
            if(moviePlayer)
            {
                [moviePlayer stop];
                moviePlayer = nil;
            }
            [self.view removeFromSuperview];
        }];
        return;
    }
    if(!tag)
        return;
    if(![self.tagDetailsName.text isEqualToString:@""])
    {
        // Check if file with same name exists
        for(SMTag *i in [[SMSharedData sharedManager] tags])
        {
            if([i.name isEqualToString:[NSString stringWithFormat:@"%@" ,self.tagDetailsName.text]] && ![i.name isEqualToString:mainFileName] && !([i.name isEqualToString:tag.name]) )
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"File with same name exists" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                return;
            }
        }
        NSURL *oldURL,*newURL,*oldthumbnailURL,*newthumbnailURL;
        switch ((int)tag.type)
        {
                // Change file names and move files with thumbnails if exist
            case 3:
            {
                oldURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", self.tagDetailsName.text]];
                oldthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name, THUMBNAIL_IMAGE]];
                newthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", self.tagDetailsName.text, THUMBNAIL_IMAGE]];
            }
                break;
            case 1:
            {
                oldURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tag.name]];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", self.tagDetailsName.text]];
            }
                break;
            case 2:
            {
                oldURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", self.tagDetailsName.text]];
                oldthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", tag.name, THUMBNAIL_VIDEO]];
                newthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", self.tagDetailsName.text, THUMBNAIL_VIDEO]];
            }
                break;
            case 4:
            {
                [self saveEditedNote];
                oldURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.tagDetailsName.text]];
            }
                break;
            default:
                break;
        }
        NSFileManager *filemgr;
        filemgr = [NSFileManager defaultManager];
        if ([filemgr moveItemAtPath:
             oldURL.path toPath:
             newURL.path error: NULL]  == YES)
        {
            NSLog (@"Main File Move successful");
        }
        else
            NSLog (@"Main File Move failed");
        if(tag.type == 2 || tag.type == 3)
        {
            // Move thumbnail images
            if ([filemgr moveItemAtPath:
                 oldthumbnailURL.path toPath:
                 newthumbnailURL.path error: NULL]  == YES)
                NSLog (@"Thumnail Move successful");
            else
                NSLog (@"Thumnail Move failed");
        }
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        NSString *soughtPid=[NSString stringWithString:tag.name];
        NSEntityDescription *productEntity=[NSEntityDescription entityForName:@"Tags" inManagedObjectContext:context];
        NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
        [fetch setEntity:productEntity];
        NSPredicate *p=[NSPredicate predicateWithFormat:@"name == %@", soughtPid];
        [fetch setPredicate:p];
        //... add sorts if you want them
        NSError *fetchError;
        NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
        // handle error
        
        for (NSManagedObject *product in fetchedProducts) {
            // Save changes in core data
            tag.name =[NSString stringWithFormat:@"%@",self.tagDetailsName.text];
            tag.address=self.tagDetailsLocation.text;
            tag.caption =self.tagDetailsCaption.text;
            tag.copyright = self.tagDetailsCopyright.text;
            [product setValue:tag.name forKey:@"name"];
            [product setValue:[NSNumber numberWithDouble:tag.type] forKey:@"type"];
            [product setValue:[NSNumber numberWithDouble:tag.coordinate.latitude] forKey:@"latitude"];
            [product setValue:[NSNumber numberWithDouble:tag.coordinate.longitude] forKey:@"longitude"];
            [product setValue:[NSNumber numberWithBool:tag.uploadStatus] forKey:@"uploadStatus"];
            [product setValue:tag.dateTaken forKey:@"dateTaken"];
            [product setValue:tag.address forKey:@"location"];
            [product setValue:tag.caption forKey:@"caption"];
            [product setValue:tag.copyright forKey:@"copyright"];
        }
        NSError *error;
        if (![context save:&error]) {
            // NSLog{@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        else{
            if (tag.type == 3) {
                // Save TIFF metadata in image's tiff dictionary
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:newURL]];
                [[SMSharedData sharedManager] getPhotoUrlWithMetadata:image withMetaData:tag withName:tag.name];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
        if(shouldDismiss == YES)
        {
            // Dismiss view with animation fade out
            [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
            UIView *viewToFade=[self getViewToFade];
            CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
            f.origin.x  = f.origin.x + 10;
            CGRect firstFrame= viewToFade.frame;
            [viewToFade setFrame:firstFrame];
            [self.mainContainerScrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
            [cancelButton setHidden:YES];
//            [saveButton setHidden:YES];
            [UIView animateWithDuration:k_ANIMATION animations:^{
                [viewToFade setFrame:f];
                [self.view setAlpha:0.0];
            } completion:^(BOOL finished) {
                if(audioPlayer)
                {
                    [self stop:nil];
                    audioPlayer = nil;
                }
                if(moviePlayer)
                {
                    [moviePlayer stop];
                    moviePlayer = nil;
                }
                [self.view removeFromSuperview];
            }];
        }
        else
        {
            if(audioPlayer)
            {
                [self stop:nil];
                audioPlayer = nil;
            }
            if(moviePlayer)
            {
                [moviePlayer stop];
                moviePlayer = nil;
            }
        }
    }
    else
    {
        // Alert if file title field is left empty
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Filename required" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }
}

-(void)saveEditedNote
{
    // Save changes made in Note contents
    NSURL *finalURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name ]];
    NSError *error = nil;
    [noteTextView.text writeToFile:finalURL.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [NSData dataWithContentsOfURL:finalURL];
    if(tag.uploadStatus){
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        NSString *soughtPid=[NSString stringWithString:tag.name];
        NSEntityDescription *productEntity   =[NSEntityDescription entityForName:@"Tags" inManagedObjectContext:context];
        NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
        [fetch setEntity:productEntity];
        NSPredicate *p=[NSPredicate predicateWithFormat:@"name == %@", soughtPid];
        [fetch setPredicate:p];
        //... add sorts if you want them
        NSError *fetchError;
        NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
        // handle error
        for (NSManagedObject *product in fetchedProducts) {
            [product setValue:data forKey:@"data"];
        }
        NSError *error;
        if (![context save:&error]) {
            // NSLog{@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

/**
 *  Dismiss and animate date picker out
 */
-(void)resignDatePicker
{
    if(datePicker)
    {
        [self.tagDetailsDate setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker]];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height + datePicker.frame.size.height/2)];
        [UIView commitAnimations];
        datePicker = nil;
    }
}

/**
 *  Get date in string format from a datepicker
 *
 *  @param dp datePicker
 *
 *  @return converted date string
 */
- (NSString *)getDateFromDatePickerInReadableFormatWithDatePicker:(UIDatePicker *)dp{
    NSDate *date = dp.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
//    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.tagDetailsName)
    {
        // Enable save and cancel buttons
        [self startEditing];
        return YES;
    }
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");  // Check if it's backspace
    NSInteger afterCount = (self.tagDetailsName.text.length-range.length+string.length);
    // Don't allow more characters to be entered than allowed in file title field except backspace
    if(afterCount>=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME+1 && textField == self.tagDetailsName && isBackSpace != -8)
        return NO;
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME - afterCount;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    // Enable save and cancel buttons
    [self startEditing];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (![self.tagDetailsName.text isEqualToString:@""]) {
        // Force capitalise first letter of file title
        [self.tagDetailsName setText:[[[self.tagDetailsName.text substringToIndex:1] uppercaseString] stringByAppendingString:[self.tagDetailsName.text substringFromIndex:1]]];
    }
    if(datePicker)
    {
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    if(textField == self.tagDetailsName)
    {
        [self.tagDetailsLocation resignFirstResponder];
        [self.tagDetailsCaption resignFirstResponder];
        [self.tagDetailsName becomeFirstResponder];
        [self.tagDetailsCopyright resignFirstResponder];
    }
    else if(textField == self.tagDetailsLocation){
        [self.tagDetailsName resignFirstResponder];
        [self.tagDetailsCaption resignFirstResponder];
        [self.tagDetailsCopyright resignFirstResponder];
    }
    else {
        [self.tagDetailsName resignFirstResponder];
        [self.tagDetailsLocation resignFirstResponder];
    }
    if (textField == self.tagDetailsCopyright) {
        // Handle customised placeholder of copyright text field
        NSString *copyrightText = self.tagDetailsCopyright.text;
        if([copyrightText isEqualToString:@""]){
            [self.tagDetailsCopyright setText:@"©"];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.mainContainerScrollView.currentTextView = (UITextView *)textField;
    if(textField == self.tagDetailsDate)
    {
        [noteTextView resignFirstResponder];
        [self.tagDetailsLocation resignFirstResponder];
        [self.tagDetailsName resignFirstResponder];
        [self.tagDetailsCaption resignFirstResponder];
        [self.tagDetailsCopyright resignFirstResponder];
        if(!datePicker)
            [self presentDatePicker];
        startedEditing = YES;
        [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
        return NO;
    }
    return YES;
}

/**
 *  Initialise and present date picker animating from bottom
 */
-(void) presentDatePicker
{
    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, DEFAULT_RESPONDER_HEIGHT);
    datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    [self.view addSubview:datePicker];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height - datePicker.frame.size.height/2)];
    [datePicker addTarget:self action:@selector(datePickerDidRoll:) forControlEvents:UIControlEventValueChanged];
    [UIView commitAnimations];
}

-(void) datePickerDidRoll:(UIDatePicker *)datePicker1{
    // Set date and enable save and cancel buttons
    [self.tagDetailsDate setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker1]];
    newDate = datePicker.date;
    [self startEditing];
}

-(void)viewDidDisappear:(BOOL)animated{
    if(tag.type == 1)
        [self stopPlayingAudio:nil];
}

- (void)viewDidUnload {
    [self setProgressViewBGView:nil];
    [self setContainerDetailsView:nil];
    [self setTagDetailsCaption:nil];
    totalAudioDurationLabel = nil;
    dividerImageView = nil;
    saveBarButton = nil;
    [super viewDidUnload];
}

/**
 *  Dismiss file details view
 *
 *  @param sender cancelButton
 */
- (IBAction)cancelButtonAction:(id)sender {
    [navItem setTitle:@""];  // Set empty title for better zooming animation
    UIView *viewToFade=[self getViewToFade];
    CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
    f.origin.x  = f.origin.x + 10;
    CGRect firstFrame= viewToFade.frame;
    [viewToFade setFrame:firstFrame];
    if (tag.type==2) {
        [UIView animateWithDuration:0.05 animations:^{
            [self.movieSlider setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.mainContainerScrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
            [cancelButton setHidden:YES];
           // [saveButton setHidden:YES];
            [UIView animateWithDuration:k_ANIMATION animations:^{
                [viewToFade setFrame:f];
                [self.view setAlpha:0.5];
                [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
            } completion:^(BOOL finished) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    @try {
                        if(moviePlayer)
                            [moviePlayer stop];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Player crashed %@", exception.reason);
                    }
                    
                    @try {
                            [self.view removeFromSuperview];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Remove View crashed %@", exception.reason);
                    }
                    
                });
            }];
        }];
    }
    else
    {
        [self.mainContainerScrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
        [cancelButton setHidden:YES];
//        [saveButton setHidden:YES];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:f];
            [self.view setAlpha:0.5];
            [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
}

/**
 *  Remove file button action
 *
 *  @param sender trashButton
 */
- (IBAction)deleteButtonAction:(id)sender
{
    if (tag.type==1) {
        [self pauseAudio];
    }
    if (tag.type==2) {
        [self.moviePlayPauseButton setSelected:NO];
        [self pauseVideo];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Do you really want to delete this file?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView ==  editAlert)
    {
        // Ask while sending, whether to save changes first or just send anyway
        if (buttonIndex == 1)
        {
            // Save first
            shouldDismiss = NO;
            [self saveEditedButtonAction:nil];
            [self endEditing];
            shouldDismiss = YES;
            startedEditing = FALSE;
            [self shareButtonAction:nil];
            [navigationBar.topItem setTitle:self.tagDetailsName.text];
        }
        else
        {
            // Just send
            startedEditing = FALSE;
            [self shareButtonAction:nil];
            startedEditing = TRUE;
        }
        return;
    }
    if(buttonIndex == 1){
        // Remove file
        NSSet *deleteSet = [NSSet setWithObject:tag];
        [[SMSharedData sharedManager] removeTags:deleteSet];
        [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
        UIView *viewToFade=[self getViewToFade];
        CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
        f.origin.x  = f.origin.x + 10;
        CGRect firstFrame= viewToFade.frame;
        [viewToFade setFrame:firstFrame];
        [self.mainContainerScrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
        [cancelButton setHidden:YES];
//        [saveButton setHidden:YES];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:f];
            [self.view setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
}

/**
 *  Share file button action
 *
 *  @param sender shareButton
 */
- (IBAction)shareButtonAction:(id)sender {
    [self.tagDetailsName resignFirstResponder];
    [self.tagDetailsCaption resignFirstResponder];
    [self.tagDetailsCopyright resignFirstResponder];
    [self.tagDetailsDate resignFirstResponder];
    [self.tagDetailsLocation resignFirstResponder];
    if([self.tagDetailsName.text isEqualToString:@""])
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Filename cannot be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (startedEditing == true) {
        editAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Save your metadata before sending!" delegate:self cancelButtonTitle:@"Just Send" otherButtonTitles:@"Save First", nil];
        [editAlert show];
        return;
    }
    NSURL *finalURL;
    NSString *ext;
    
    if (tag.type==1) {
        [self pauseAudio];
    }
    if (tag.type==2) {
        [self.moviePlayPauseButton setSelected:NO];
        [self pauseVideo];
    }
    
    switch ((int)tag.type) {
        case 1:
            ext = @"caf";
            break;
        case 2:
            ext = @"mov";
            break;
        case 3:
            ext = @"jpeg";
            break;
        case 4:
            ext = @"txt";
            break;
    }
    finalURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", tag.name,ext]];
    
    NSString *descriptionString = [NSString stringWithFormat:@"%@%@%@%@%@\n",
                                   //1
                                   tag.name ? [NSString stringWithFormat:@"Filename : %@",tag.name] : @"",
                                   //2
                                   (tag.caption && ![tag.caption isEqualToString:@""]) ? [NSString stringWithFormat:@"\nCaption : %@",tag.caption] : @"",
                                   //3
                                   (tag.address && ![tag.address isEqualToString:@""]) ? [NSString stringWithFormat:@"\nLocation : %@",tag.address] : @"",
                                   //4
                                   tag.dateTaken ? [NSString stringWithFormat:@"\nDate Created : %@",[self getDateInReadableFormatWithDate:tag.dateTaken]] : @"",
                                   //5
                                   (tag.copyright && ![tag.copyright isEqualToString:@""]) ? [NSString stringWithFormat:@"\nCredit : %@",tag.copyright] : @""];
    NSArray *arr = [NSArray arrayWithObjects:finalURL,descriptionString, nil];
    
    [Utility presentShareActivitySheetForViewController:self andObjects:arr andTagType:tag.type andSubjectLine:tag.name];
}

/**
 *  Get string converted from date in selected format
 *
 *  @param date date
 *
 *  @return Converted date string
 */
- (NSString *)getDateInReadableFormatWithDate:(NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
//    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}

/**
 *  Dropbox option selected delegate method
 */
-(void)delegatedDropboxActivitySelected
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if([Utility connectedToInternet]){
                                     switch ((int)tag.type) {
                                         case 1:
                                             extension = @"caf";
                                             break;
                                         case 2:
                                             extension = @"mov";
                                             break;
                                         case 3:
                                             extension = @"jpeg";
                                             break;
                                         case 4:
                                             extension = @"txt";
                                             break;
                                         case 5:
                                             extension = @"pdf";
                                             break;
                                     }
                                     NSString *fileName= [NSString stringWithFormat:@"%@.%@", tag.name,extension];
                                     NSURL *fileURL = [[Utility dataStoragePath] URLByAppendingPathComponent:fileName];
                                     if([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
                                     {
                                         // File exists to be updloaded
                                         if([[DBSession sharedSession] isLinked]){
                                             // Already logged in, present dropbox List view controller
                                             SMDropboxListViewController *dropboxListVC = [[SMDropboxListViewController alloc] initWithNibName:@"SMDropboxListViewController" bundle:nil andDirectory:@"" andMode:1];
                                             [dropboxListVC setDelegate:self];
                                             UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:dropboxListVC];
                                             [navigationVC setNavigationBarHidden:YES];
                                             [self presentViewController:navigationVC animated:YES completion:nil];
                                             
                                         }
                                         else   // Present dropbox login screen first
                                             [[DBSession sharedSession] linkFromController:self];
                                         
                                     }
                                     else
                                     {
                                         // File not found
                                         // NSLog{@"File not found at path : %@",fileURL.path);
                                     }
                                     
                                 }
                             }];
}

/**
 *  Dropbox export file to path delegate method
 *
 *  @param path path to upload files to
 */
-(void)delegatedDropboxExportActionWithDirectoryPath:(NSString *)path{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *fileName= [NSString stringWithFormat:@"%@.%@", tag.name,extension];
    NSURL *fileURL = [[Utility dataStoragePath] URLByAppendingPathComponent:fileName];
    NSString *destDir = path;
    [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
    uploadingExt = extension;
    progressVC = [[SMDropboxProgressViewController alloc] initWithNibName:@"SMDropboxProgressViewController" bundle:nil];
    [self.view addSubview:progressVC.view];
    [progressVC.dropboxProgressActivityIndicatorView startAnimating];
    [progressVC.dropboxProgressView setProgress:0.0f];
    [progressVC.dropboxProgressLabel setText:@"Exporting"];
    // Start uploading
    [[SMDropboxComponent sharedComponent].restClient uploadFile:fileName toPath:destDir withParentRev:nil fromPath:fileURL.path];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    [progressVC.dropboxProgressView setProgress:progress];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSString *ext = [[destPath  componentsSeparatedByString:@"."] lastObject];
    if(![ext isEqualToString:@"json"])
    {
        // Main file uploaded
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSArray *objArray = [NSArray arrayWithObjects:tag.name,tag.caption?tag.caption:@"",[df stringFromDate:tag.dateTaken]?[df stringFromDate:tag.dateTaken]:@"",tag.address?tag.address:@"",tag.copyright?tag.copyright:@"", nil];
        NSArray *keysArray = [NSArray arrayWithObjects:@"Filename",@"Caption",@"Date",@"Location",@"Copyright",nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objArray forKeys:keysArray];
        NSError *err;
        // Create a JSON file with all metadata written in it
        int tempIndex = (int)([srcPath rangeOfString:@"." options:NSBackwardsSearch].location);
        NSString *jsonPath = [NSString stringWithFormat:@"%@_md.%@.json",[srcPath substringToIndex:tempIndex],ext];
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
        [jsonData writeToFile:jsonPath options:NSDataWritingAtomic error:&err];
        NSString *destDir = @"/";
        NSString *uploadedFileName=jsonPath;
        uploadingExt = @"json";
        // Upload JSON metadata file
        [[SMDropboxComponent sharedComponent].restClient uploadFile:uploadedFileName toPath:destDir withParentRev:nil fromPath:jsonPath];
    }
    else{
        // Uploaded JSON metadata file. Exporting completed
        [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
        [progressVC.dropboxProgressActivityIndicatorView setHidden:YES];
        [progressVC.dropboxSuccessImageView setHidden:NO];
        [progressVC.dropboxProgressLabel setText:@"Exported"];
        [progressVC.dropboxCancelButton setEnabled:NO];
        [progressVC.dropboxDoneButton setEnabled:YES];
        [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    // NSLog{@"File upload failed with error: %@", error);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 *  Pauses video playback
 */
-(void)pauseVideo{
    [moviePlayer pause];
    if(movieTimer)
        [movieTimer invalidate];
}

/**
 *  Toggle video play/pause playback
 *
 *  @param sender playPauseButton
 */
- (IBAction)moviePlayPauseButtonAction:(id)sender {
    [self.moviePlayPauseButton setSelected:!self.moviePlayPauseButton.isSelected];
    if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying) {
        [self pauseVideo];
    }
    else
    {
        [moviePlayer play];
        movieTimer =  [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                       target:self
                                                     selector:@selector(updatePlaybackTime:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

/**
 *  Seek video action
 *
 *  @param sender slider
 */
- (IBAction)seekVideoAction:(id)sender {
//    if (moviePlayer.playbackState==MPMoviePlaybackStatePlaying) {
//        [moviePlayer pause];
//        [self.moviePlayPauseButton setSelected:NO];
//    }
    [moviePlayer setCurrentPlaybackTime:moviePlayer.duration*self.movieSlider.value];
    // Update video duration and time labels
    [self setVideoLabels:nil];
}

@end

