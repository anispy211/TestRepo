//
//  SMAudioRecorderViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/1/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMLocationTracker.h"
#import "SMAudioRecorderViewController.h"

@interface SMAudioRecorderViewController (){
    SMTag *audioTag;
    UIDatePicker *datePicker;
}
@end

@implementation SMAudioRecorderViewController

@synthesize recorderButton;
@synthesize stopRecordingButton;
@synthesize mainContainerScrollView;
@synthesize timerLabel;
@synthesize containerDetailsView;
@synthesize tagDetailsCaption;
@synthesize tagDetailsCopyright;
@synthesize tagDetailsDate;
@synthesize tagDetailsLocation;
@synthesize tagDetailsName;
@synthesize saveButton;
@synthesize remainingCharactersLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *tempName = @"@@@@@#####";
    self.examples = [[NSMutableArray alloc] init];
    self.percentage = 0;
    // Assign radius and other attributes to circular recorder progress view
    CGFloat radius = (self.circularProgressBackgroundView.frame.size.width/2)*1.10;
    THCircularProgressView *example2 = [[THCircularProgressView alloc] initWithCenter:CGPointMake(self.circularProgressBackgroundView.frame.size.width/2, (self.circularProgressBackgroundView.frame.size.height/2)*0.97)
                                                                               radius:radius
                                                                            lineWidth:7.0f
                                                                         progressMode:THProgressModeFill
                                                                        progressColor:REPORTABLE_ORANGE_COLOR
                                                               progressBackgroundMode:THProgressBackgroundModeCircumference
                                                              progressBackgroundColor:REPORTABLE_CREAM_COLOR
                                                                           percentage:self.percentage];
    [self.circularProgressBackgroundView addSubview:example2];
    CGRect f = self.circularProgressBackgroundView.frame;
    f.origin.y = self.view.frame.size.height/2-self.circularProgressBackgroundView.frame.size.height/2-(IS_IPHONE5?40:70);
    [self.circularProgressBackgroundView setFrame:f];
    f =recorderButton.frame;
    f.origin.y = self.circularProgressBackgroundView.frame.origin.y + self.circularProgressBackgroundView.frame.size.height+(IS_IPHONE5?15:40);
    [recorderButton setFrame:f];
    [self.examples addObject:example2];
    // Initial settings
    tempAudioURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tempName]];
    [timerLabel setFont:[FONT_LIGHT size:FONT_SIZE_FOR_TIMER_LABEL]];
    [timerLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [maxAudioDurationLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [maxAudioDurationLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [maxAudioDurationLabel setText:@"/03:00"];
    isInPlayMode = NO;
    isInPauseMode = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:NOTIFICATION_LOCATION_UPDATED  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveMethod) name:UIApplicationWillResignActiveNotification object:nil];
    [self customizeTextFont];
    [self fillTagDetails];
    [self.saveButton setEnabled:NO];
    if (self.tagDetailsCaption && [self.tagDetailsCaption.text isEqualToString:@""]) {
        [self.tagDetailsCaption setText:@"Caption"];
        [self.tagDetailsCaption setTextColor:PLACEHOLDER_TEXT_COLOR]; //optional
    }
    [self adjustMainScrollViewFrame];
    CGFloat standardHeight=IS_IPHONE5?443:355;
    CGRect frame = self.containerDetailsView.frame;
    frame.origin.y = standardHeight;
    [self.containerDetailsView setFrame:frame];
    CGSize cSize = self.mainContainerScrollView.contentSize;
    cSize.height = standardHeight + self.containerDetailsView.frame.size.height;
    [self.mainContainerScrollView setContentSize:cSize];
    // Do any additional setup after loading the view from its nib.
}

-(void)applicationWillResignActiveMethod{
    // Pause when going to background
    isInPlayMode = YES;
    isInPauseMode = NO;
    [self recordAction:nil];
}

-(void)textViewDidChange:(UITextView *)textView{
    NSUInteger numLines = textView.contentSize.height/textView.font.lineHeight;
    if (numLines > MAXIMUM_LINES_LIMIT_FOR_CAPTION_FIELD){
        textView.text = [textView.text substringToIndex:textView.text.length - 1];
        return;
    }
    [self adjustMainScrollViewFrame];
    NSRange range =[textView.text rangeOfString:[textView.text substringFromIndex:textView.text.length]];
    [textView scrollRangeToVisible:range];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        [self adjustMainScrollViewFrame];
        [textView resignFirstResponder];
    }
    return YES;
}

/**
 *  Adjust container scroll view's frame and content size according to caption view's content size.
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
    [self.tagDetailsCaption setFrame:frame];
    [self.tagDetailsLocation setCenter:CGPointMake(self.tagDetailsLocation.center.x, self.tagDetailsLocation.center.y+heightDifference)];
    [self.tagDetailsDate setCenter:CGPointMake(self.tagDetailsDate.center.x, self.tagDetailsDate.center.y+heightDifference)];
    [self.tagDetailsCopyright setCenter:CGPointMake(self.tagDetailsCopyright.center.x, self.tagDetailsCopyright.center.y+heightDifference)];
    CGRect containerFrame2 = self.containerDetailsView.frame;
    //    containerFrame2.origin.y = containerFrame2.origin.y - heightDifference;
    containerFrame2.size.height = containerFrame2.size.height+heightDifference;
    [self.containerDetailsView setFrame:containerFrame2];
    [self.mainContainerScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.containerDetailsView.frame.origin.y+self.containerDetailsView.frame.size.height)];
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
 *  Apply font and padding to all text fields
 */
-(void)customizeTextFont
{
    [self.tagDetailsCaption setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsName setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsDate setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsLocation setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsCopyright setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.tagDetailsLocation setRightView:[self addSideView]];
    [self.tagDetailsLocation setRightViewMode:UITextFieldViewModeAlways];
    [self.tagDetailsLocation setLeftView:[self addSideView]];
    [self.tagDetailsLocation setLeftViewMode:UITextFieldViewModeAlways];
    self.tagDetailsCaption.layer.sublayerTransform = CATransform3DMakeTranslation(2, -1, 0);
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
    self.tagDetailsName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsLocation.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsCopyright.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tagDetailsCaption.autocapitalizationType = UITextAutocapitalizationTypeSentences;
}

-(void)locationDidUpdate
{
    if([SMLocationTracker sharedManager].address) {
        [self.tagDetailsLocation setText:[SMLocationTracker sharedManager].address];
        audioTag.address = [SMLocationTracker sharedManager].address;
    }
}

/**
 *  Cancel Recording
 *
 *  @param sender cancelButton
 */
- (IBAction)cancelButtonAction:(id)sender {
    if(audioRecorder.recording)
    {
        [audioRecorder stop];
        [self clearTimers];
        [recordingTimer invalidate];
        recordingTimer= nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma Audio capture handlers

-(void)startTimer
{
    countsec=(float)[[NSDate date] timeIntervalSinceDate:startDate] ;
    if(countsec>=(MAXIMUM_DURATION_FOR_AUDIO_IN_MINUTES*60))
    {
        [timerLabel setText:@"00:00"];
        [self.recorderButton setImage:[UIImage imageNamed:@"recording@2x.png"] forState:UIControlStateNormal];
        [self saveButtonAction:nil];
        [recordingTimer invalidate];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Maximum limit reached" message:nil delegate:nil cancelButtonTitle:@"OK"  otherButtonTitles:nil];
        [alert show];
        return;
    }
    countmin = (int)(countsec/60);
    [timerLabel setText:[NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec%60]];
    self.percentage = (countsec/(MAXIMUM_DURATION_FOR_AUDIO_IN_MINUTES*60));
    for (THCircularProgressView* progressView in self.examples) {
        progressView.percentage = self.percentage;
    }
}

-(void)startNewTimer
{
    countsec = pauseTimeValue + (float)[[NSDate date] timeIntervalSinceDate:resumeDate];
    [timerLabel setText:[NSString stringWithFormat:@"%02d:%02d",(int)countmin,(int)countsec%60]];
    self.percentage = (countsec/(MAXIMUM_DURATION_FOR_AUDIO_IN_MINUTES*60));
    if((int)countsec>=(MAXIMUM_DURATION_FOR_AUDIO_IN_MINUTES*60))
    {
        [timerLabel setText:@"00:00"];
        [self.recorderButton setImage:[UIImage imageNamed:@"recording@2x.png"] forState:UIControlStateNormal];
        [self saveButtonAction:nil];
        [recordingTimer invalidate];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Maximum limit reached" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    if(((int)countsec)%60==0)
        countmin++;
    for (THCircularProgressView* progressView in self.examples) {
        progressView.percentage = self.percentage;
    }
}

-(void)pauseResumeTimer {
    if (isInPauseMode == YES) {
        if(recordingTimer) {
            [recordingTimer invalidate];
            recordingTimer = nil;
        }
        resumeDate = [NSDate date];
        countsec=(float)[[NSDate date] timeIntervalSinceDate:resumeDate];
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(startNewTimer) userInfo:nil repeats:YES];
    }
    else {
        pauseTimeValue = countsec;
        [recordingTimer invalidate];
        recordingTimer = nil;
    }
}

-(void) createAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
        return;
    }
}

/**
 *  Initialise and present Date Picker
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


-(void)viewDidDisappear:(BOOL)animated{
    [self.timer invalidate];
}

-(void)StopRecording:(id)sender
{
    [self continueToSaveAudio];
}

-(void) continueToSaveAudio{
    [self clearTimers];
    [self saveAudio];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                        object:self];
}

- (void)clearTimers
{
    countsec = 0;
    countmin = 0;
}

-(void)saveButtonAction:(id)sender{
    // Validate fields
    if([self.tagDetailsName.text isEqualToString:@""])
    {
        [self recordAction:nil];
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Filename cannot be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if ([Utility color:self.tagDetailsCaption.textColor matchesColor:PLACEHOLDER_TEXT_COLOR]) {
        self.tagDetailsCaption.text = audioTag.caption = @"";
    }
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    if (self.tagDetailsCaption && [self.tagDetailsCaption.text isEqualToString:@""]==NO)
        audioTag.caption = self.tagDetailsCaption.text;
    if (self.tagDetailsCopyright && [self.tagDetailsCopyright.text isEqualToString:@""]==NO)
        audioTag.copyright = self.tagDetailsCopyright.text;
    if (self.tagDetailsLocation && [self.tagDetailsLocation.text isEqualToString:@""]==NO)
        audioTag.address = self.tagDetailsLocation.text;
    self.tagDetailsName.text = [self.tagDetailsName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for(SMTag *i in [[SMSharedData sharedManager] tags])
    {
        if([i.name isEqualToString:[NSString stringWithFormat:@"%@", self.tagDetailsName.text]] && !([i.name isEqualToString:audioTag.name]))
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"File with same name exists" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }
    [self stopAction:self.stopRecordingButton];
    [self continueToSaveAudio];
}

- (void)stop:(id)sender
{
    [audioRecorder stop];
    if(isInPlayMode == YES)
        isInPlayMode = NO;
    [recordingTimer invalidate];
	recordingTimer = nil;
}

/**
 *  Feed metadata text fields initially
 */
-(void)fillTagDetails{
    NSString * fileName = nil;
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",AudioTagType];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
    if(filteredArray && [filteredArray count] > 0)
    {
        NSInteger lastaudioID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultAudioID"];
        NSURL *newURL;
        if(!fileName)
            do {
                fileName = [NSString stringWithFormat:@"Audio %d",(int)++lastaudioID];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", fileName]];
            } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
    }
    else
        fileName = [NSString stringWithFormat:@"Audio 1"];
    [self.tagDetailsName setText:fileName];
    
    audioTag = [[SMTag alloc] init];
    audioTag.name = fileName;
    audioTag.type = AudioTagType;
    [[SMSharedData sharedManager] addDefaultStampsToTag:audioTag];
    
    if (audioTag.caption)
        [self.tagDetailsCaption setText:audioTag.caption];
    [self.tagDetailsCopyright setText:audioTag.copyright];
    
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    
    [self.tagDetailsDate setText:[self getDateInReadableFormatWithDate:audioTag.dateTaken]];
    
    
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-self.tagDetailsName.text.length;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized)
        [[SMLocationTracker sharedManager] startUpdatingLocation];
}

/**
 *  Get date in string using selected date format
 *
 *  @param date date to be converted
 *
 *  @return converted date string
 */
- (NSString *)getDateInReadableFormatWithDate:(NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}

- (void)saveAudio
{
    NSString * fileName =  fileName = [NSString stringWithFormat:@"%@",self.tagDetailsName.text];
    audioTag.name = fileName;
    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", fileName]];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:tempAudioURL.path toPath:url.path error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:tempAudioURL.path error:&error];
    [[SMSharedData sharedManager] addNewTag:audioTag];
    [self clearTimers];
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    // Delegate method called when audio player finishes recording
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    // Delegate method called when audio player throws an error
}

- (void)viewDidUnload {
    [self setCircularProgressBackgroundView:nil];
    [self setStopRecordingButton:nil];
    [super viewDidUnload];
}

/**
 *  Toggle audio recording
 *
 *  @param sender recordButton
 */
- (IBAction)recordAction:(id)sender {
    [self.stopRecordingButton setEnabled:YES];
    if (isInPlayMode == NO) {
        if (isInPauseMode == NO) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (!granted) {
                    // Microphone disabled code
                    [self dismissViewControllerAnimated:YES completion:^{
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"Reportable does not have access to use microphone. Please go to Settings->Privacy->Microphone and allow access." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        return;
                    }];
                }
            }];
            self.percentage = 0;
            [self.saveButton setEnabled:YES];
            startDate = [NSDate date];
            [timerLabel setText:@"00:00"];
            if( [[NSFileManager defaultManager] fileExistsAtPath:tempAudioURL.path] )
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:tempAudioURL.path error:&error];
            }
            NSDictionary *recordSetting = @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                            AVEncoderAudioQualityKey: @(AVAudioQualityLow),
                                            AVNumberOfChannelsKey: @1,
                                            AVSampleRateKey: @22050.0f};
            // Initialise audio recorder with record settings
            [self createAudioSession];
            NSError *error = nil;
            audioRecorder = [[AVAudioRecorder alloc] initWithURL:tempAudioURL settings:recordSetting error:&error];
            audioRecorder.delegate = self;
            audioRecorder.meteringEnabled = YES;
            if (error){
//                NSLog(@"error: %@", [error localizedDescription]);
            }
            else
                [audioRecorder prepareToRecord];
            [audioRecorder record];
            countmin = countsec = 0;
            recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        }
        else {
            /*-------Record Button pressed in Paused State-----------*/
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setActive:YES error:nil];
            // Start recording
            [audioRecorder record];
            [self pauseResumeTimer];
        }
        // Set button states
        [self.recorderButton setImage:[UIImage imageNamed:@"stopRecording.png"] forState:UIControlStateNormal];
        isInPauseMode = NO;
        isInPlayMode = YES;
        
    }
    else {
        /*-------Pause Button pressed in Recording State-----------*/
        [self.recorderButton setImage:[UIImage imageNamed:@"startRecording_Highlighted.png"] forState:UIControlStateNormal];
        [self pauseResumeTimer];
        isInPauseMode = YES;
        isInPlayMode = NO;
        [audioRecorder pause];
        
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (IBAction)stopAction:(id)sender {
    [self.stopRecordingButton setEnabled:NO];
    [self.recorderButton setImage:[UIImage imageNamed:@"startRecording_Highlighted.png"] forState:UIControlStateNormal];
    [self.saveButton setEnabled:YES];
    [self stop:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.tagDetailsName)
        return YES;
    // Don't allow more characters than maximum allowed to be entered in title field except backspace
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    NSInteger afterCount = (self.tagDetailsName.text.length-range.length+string.length);
    if(afterCount>=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME+1 && textField == self.tagDetailsName && isBackSpace != -8)
        return NO;
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME - afterCount;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView == self.tagDetailsCaption && [textView.text isEqualToString:@"Caption"] && [Utility color:textView.textColor matchesColor:PLACEHOLDER_TEXT_COLOR]) {
        // Handle custom placeholder for caption field
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [self textFieldDidBeginEditing:nil];
    [textView becomeFirstResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if(textView==self.tagDetailsCaption)
    {
        // Handle custom placeholder for caption field
        if ([textView.text isEqualToString:@""]) {
            [textView setText:@"Caption"];
            [textView setTextColor:PLACEHOLDER_TEXT_COLOR]; //optional
        }
    }
    [textView resignFirstResponder];
}

/**
 *  Resign and animate date picker out
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
 *  Get date from date picker and return string using selected date format
 *
 *  @param dp datePicker
 *
 *  @return converted date string
 */
- (NSString *)getDateFromDatePickerInReadableFormatWithDatePicker:(UIDatePicker *)dp{
    NSDate *date = dp.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.mainContainerScrollView.currentTextView = (UITextView *)textField;
    if(textField == self.tagDetailsDate)
    {
        [self.tagDetailsLocation resignFirstResponder];
        [self.tagDetailsName resignFirstResponder];
        [self.tagDetailsCaption resignFirstResponder];
        [self.tagDetailsCopyright resignFirstResponder];
        if(!datePicker)
            [self presentDatePicker];
        [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
        return NO;
    }
    return YES;
}

-(void) datePickerDidRoll:(UIDatePicker *)datePicker1{
    [self.tagDetailsDate setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker1]];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(datePicker)
    {
        // Dismiss date picker if present
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    self.mainContainerScrollView.currentTextView = textView;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(datePicker)
    {
        // Dismiss date picker if present
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    if (textField == self.tagDetailsCopyright){
        NSString *copyrightText = self.tagDetailsCopyright.text;
        if([copyrightText isEqualToString:@""]){
            [self.tagDetailsCopyright setText:@"©"];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self adjustMainScrollViewFrame];
    [textField resignFirstResponder];
    return YES;
}

@end
