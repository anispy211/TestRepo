//
//  SMNoteViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 19/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMNoteViewController.h"
#import "SMSharedData.h"
#import "MBProgressHUD.h"
#import "SMTag.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
#import "SMLocationTracker.h"

@interface SMNoteViewController (){
    SMTag *noteTag;
    UIDatePicker *datePicker;
}

@end

@implementation SMNoteViewController
@synthesize tag;
@synthesize noteNameTextView;
@synthesize tagBeingEdited;
@synthesize fileName;
@synthesize noteNavigationBar;
@synthesize remainingCharacterCountLabel;
@synthesize maxCharactersLabel;
@synthesize mainContainerScrollView;
@synthesize containerDetailsView;
@synthesize tagDetailsCaption;
@synthesize tagDetailsCopyright;
@synthesize tagDetailsDate;
@synthesize tagDetailsLocation;
@synthesize tagDetailsName;
@synthesize remainingCharactersLabel;


#pragma Initialise
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Note", @"Note");
        self.tabBarItem.image = [UIImage imageNamed:@"note"];
    }
    return self;
}
#pragma mark View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.noteNameTextView setKeyboardType:UIKeyboardTypeAlphabet];
    [self.noteNameTextView setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.maxCharactersLabel setFont:[FONT_LIGHT size:FONT_SIZE_FOR_TAG]];
    [self.maxCharactersLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [self.remainingCharacterCountLabel setFont:[FONT_LIGHT size:FONT_SIZE_FOR_TAG]];
    [self.remainingCharacterCountLabel setTextColor:REPORTABLE_ORANGE_COLOR];
    // Assign initial values to text fields
    [self.maxCharactersLabel setText:[NSString stringWithFormat:@"Max characters: %d",kMaximumCharacterCountForNote]];
    [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)self.noteNameTextView.text.length]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:NOTIFICATION_LOCATION_UPDATED  object:nil];
    [self.noteNavigationBar.topItem.rightBarButtonItem setEnabled:NO];
    [self customizeTextFont];
    [self fillTagDetails];
    if (self.tagDetailsCaption && [self.tagDetailsCaption.text isEqualToString:@""]) {
        [self.tagDetailsCaption setText:@"Caption"];
        [self.tagDetailsCaption setTextColor:PLACEHOLDER_TEXT_COLOR]; //optional
    }
    if (self.noteNameTextView && [self.noteNameTextView.text isEqualToString:@""]) {
        [self.noteNameTextView setText:@"Notes"];
        [self.noteNameTextView setTextColor:PLACEHOLDER_TEXT_COLOR]; //optional
    }
    [self.noteNavigationBar setExclusiveTouch:YES];
    [self.noteNavigationBar setMultipleTouchEnabled:NO];
    [self adjustMainScrollViewFrame];
    [self adjustScrollViewAccordingToNoteNameTextView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.tagDetailsName)
        return YES;
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    NSInteger afterCount = (self.tagDetailsName.text.length-range.length+string.length);
    // Don't allow more characters to be entered if filename has reached maximum limit, except it is backspace.
    if(afterCount>=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME+1 && textField == self.tagDetailsName && isBackSpace != -8)
        return NO;
    // Update remaining characters for filename
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME - afterCount;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    return YES;
}

/**
 *  Observe notification and update location field
 */
-(void)locationDidUpdate{
    if([SMLocationTracker sharedManager].address)
    {
        [self.tagDetailsLocation setText:[SMLocationTracker sharedManager].address];
        noteTag.address = [SMLocationTracker sharedManager].address;
    }
}

/**
 *  Intitialises and presents a date picker from bottom
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

/**
 *  Fill all metadata text fields initially
 */
-(void)fillTagDetails{
    NSString * txtFileName = nil;
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",NoteTagType];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
    if(filteredArray && [filteredArray count] > 0)
    {
        // Detect latest counter of last saved note from user defaults storage
        NSInteger lastNoteID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultNoteID"];
        NSURL *newURL;
        if(!txtFileName)
            do {
                // Traverse through all default note names and get name
                txtFileName = [NSString stringWithFormat:@"Note %d",(int)++lastNoteID];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", txtFileName]];
            } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
    }
    else{
        // Give default name for first note i.e. Note 1
        txtFileName = [NSString stringWithFormat:@"Note 1"];
    }
    [self.tagDetailsName setText:txtFileName];
    noteTag = [[SMTag alloc] init];
    noteTag.name = txtFileName;
    noteTag.type = NoteTagType;
    [[SMSharedData sharedManager] addDefaultStampsToTag:noteTag];
    if (noteTag.caption)
        [self.tagDetailsCaption setText:noteTag.caption];
    [self.tagDetailsCopyright setText:noteTag.copyright];
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    // Calculate remaining characters and set text
    [self.tagDetailsDate setText:[self getDateInReadableFormatWithDate:noteTag.dateTaken]];
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-self.tagDetailsName.text.length;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized)
        [[SMLocationTracker sharedManager] startUpdatingLocation];
}

/**
 *  Dismiss and animate date picker to hide
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
 *  Convert NSString to NSDate with selected date format
 *
 *  @param dateString Date string to be converted
 *
 *  @return converted date value
 */
- (NSDate *)getDateFromDateString:(NSString *)dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSDate *date = [dateFormat dateFromString:dateString];
    return  date;
}

/**
 *  Get date from date picker and return string using selected date format
 *
 *  @param dp datePicker
 *
 *  @return converted date string
 */
- (NSString *)getDateFromDatePickerInReadableFormatWithDatePicker:(UIDatePicker *)dp
{
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
        // Handle if it is date field
        [noteNameTextView resignFirstResponder];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(datePicker)
    {
        // Resign and dismiss date picker if present
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    if (textField == self.tagDetailsCopyright) {
        NSString *copyrightText = self.tagDetailsCopyright.text;
        if([copyrightText isEqualToString:@""]){
            // Handle placeholder customisation
            [self.tagDetailsCopyright setText:@"©"];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(UIView *)addSideView
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
}

/**
 *  Apply custom attributes and fonts to metadata fields
 */
-(void)customizeTextFont{
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

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)kbDidShow:(NSNotification *)note
{
    UITextRange *selectionRange = noteNameTextView.selectedTextRange;
    if([noteNameTextView isFirstResponder]) {
        CGRect selectionEndRect = [noteNameTextView caretRectForPosition:selectionRange.end];
        CGRect finalRect = CGRectMake(selectionEndRect.origin.x, selectionEndRect.origin.y + noteNameTextView.frame.origin.y, 10, 100);
        [self.mainContainerScrollView scrollRectToVisible:finalRect animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveNote
{
    self.fileName = fileName = [NSString stringWithFormat:@"%@",self.tagDetailsName.text];
    if(tagBeingEdited)
    {
        // If it is saved file opened for editing
        NSURL *finalURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.fileName]];
        NSError *error = nil;
        [self.noteNameTextView.text writeToFile:finalURL.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
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
    else
    {
        // If it is new file
        NSURL *finalURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.fileName]];
        noteTag.name = self.fileName;
        noteTag.type = 4;
        NSError *error = nil;
        [self.noteNameTextView.text writeToFile:finalURL.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                            object:self];
        [[SMSharedData sharedManager] addNewTag:noteTag];
    }
    [self.noteNameTextView setText:@""];
    [self.noteNameTextView resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(BOOL)shouldAutorotate{
    return NO;
}

#pragma mark Button Actions

- (IBAction)cancelButtonAction:(id)sender{
    [saveButton setEnabled:NO];
    if ([self.noteNameTextView respondsToSelector:@selector(resignFirstResponder)])
        [self.noteNameTextView resignFirstResponder];
    self.noteNameTextView.text = @"";
    [cancelButton setEnabled:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Save note button action
 *
 *  @param sender saveButton
 */
-(IBAction)saveButtonAction:(id)sender
{
    if ([self.tagDetailsCopyright.text isEqualToString:@"©"]) {
        [self.tagDetailsCopyright setText:@""];
    }
    if ([self.tagDetailsName.text isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Filename required" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([Utility color:self.tagDetailsCaption.textColor matchesColor:PLACEHOLDER_TEXT_COLOR])
    {
        // Handle caption field placeholder customisation
        self.tagDetailsCaption.text = noteTag.caption = @"";
    }
    // Assign values to tag object if not empty
    if (self.tagDetailsCaption && [self.tagDetailsCaption.text isEqualToString:@""]==NO)
        noteTag.caption = self.tagDetailsCaption.text;
    if (self.tagDetailsCopyright && [self.tagDetailsCopyright.text isEqualToString:@""]==NO)
        noteTag.copyright = self.tagDetailsCopyright.text;
    if (self.tagDetailsLocation && [self.tagDetailsLocation.text isEqualToString:@""]==NO)
        noteTag.address = self.tagDetailsLocation.text;
    if (self.tagDetailsDate && [self.tagDetailsDate.text isEqualToString:@""]==NO)
        noteTag.dateTaken = [self getDateFromDateString:self.tagDetailsDate.text];
    self.tagDetailsName.text = [self.tagDetailsName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // Check if file with same name already exists
    for(SMTag *i in [[SMSharedData sharedManager] tags])
    {
        if([i.name isEqualToString:[NSString stringWithFormat:@"%@", self.tagDetailsName.text]] && !([i.name isEqualToString:noteTag.name]))
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"File with same name exists" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            alert=nil;
            return;
        }
    }
    [self performSelector:@selector(saveNote)
               withObject:nil];
}


#pragma mark TextField Delegates
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(datePicker)
    {
        [self.mainContainerScrollView hideDatePickerForTextField:self.tagDetailsDate andKeyboardRect:self.tagDetailsDate.frame];
        [self resignDatePicker];
    }
    self.mainContainerScrollView.currentTextView = textView;
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ((textView == self.tagDetailsCaption && [textView.text isEqualToString:@"Caption"])||(textView == self.noteNameTextView && [textView.text isEqualToString:@"Notes"] && [Utility color:textView.textColor matchesColor:PLACEHOLDER_TEXT_COLOR])) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    // Assign text as placeholder if found empty string
    if(textView==self.tagDetailsCaption)
    {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Caption";
            textView.textColor = PLACEHOLDER_TEXT_COLOR; //optional
        }
    }
    if(textView==self.noteNameTextView)
    {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Notes";
            textView.textColor = PLACEHOLDER_TEXT_COLOR; //optional
        }
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

/**
 *  Adjust container scroll view's frame and content size according to caption view's content size.
 */
-(void) adjustMainScrollViewFrame{
    NSString *str = self.tagDetailsCaption.text;
    CGSize textSize = [str sizeWithFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL] constrainedToSize:CGSizeMake(self.tagDetailsCaption.contentSize.width-10, 20000) lineBreakMode: NSLineBreakByTruncatingTail];
    textSize.width = self.tagDetailsCaption.frame.size.width;
    textSize.height = textSize.height+13;   // 13 is the offset value to get text in center vertically
    if (textSize.height > 30) { // Handle the customised text view according to the contents in it
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
    containerFrame2.size.height = containerFrame2.size.height+heightDifference;
    [self.containerDetailsView setFrame:containerFrame2];
    [self.mainContainerScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.containerDetailsView.frame.origin.y+self.containerDetailsView.frame.size.height)];
}

/**
 *  Adjust container scroll view's frame and content size according to notes text view's content size.
 */
-(void)adjustScrollViewAccordingToNoteNameTextView
{
    CGFloat oldHeight = noteNameTextView.frame.size.height;
    CGRect rect = noteNameTextView.frame;
    [noteNameTextView sizeToFit];
    CGFloat standardHeight=IS_IPHONE5?434:346;  // Initial height for notes text view depending upon the device
    if (noteNameTextView.frame.size.height<standardHeight)
        rect.size.height = standardHeight;
    else
        rect.size.height = noteNameTextView.frame.size.height;
    [noteNameTextView setFrame:rect];
    if (noteNameTextView.frame.size.height > standardHeight-30)
    {
        // If notes contents exceed standard height, increase notes text view frame's height
        rect.size.height = noteNameTextView.frame.size.height;
        [noteNameTextView setFrame:rect];
        CGFloat heightDifference  = rect.size.height - oldHeight;
        CGSize cSize = self.mainContainerScrollView.contentSize;
        cSize.height = cSize.height+heightDifference;
        [self.mainContainerScrollView setContentSize:cSize];
        [self.containerDetailsView setCenter:CGPointMake(self.containerDetailsView.center.x, self.containerDetailsView.center.y+heightDifference)];
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    if (textView == self.noteNameTextView){
        // Enable save button and update remaining characters label of notes text view
        [self.noteNavigationBar.topItem.rightBarButtonItem setEnabled:YES];
        NSInteger currentCount= [textView.text length];
        [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)currentCount]];
        if(currentCount >=kMaximumCharacterCountForNote)
        {
            [textView setText:[textView.text substringToIndex:kMaximumCharacterCountForNote]];
            [self.remainingCharacterCountLabel setText:[NSString stringWithFormat:@"%d characters",(int)kMaximumCharacterCountForNote]];
        }
        [self adjustScrollViewAccordingToNoteNameTextView];
        
    }else{
        // Handle caption field maximum number of characters allowed
        NSUInteger numLines = textView.contentSize.height/textView.font.lineHeight;
        if (numLines > MAXIMUM_LINES_LIMIT_FOR_CAPTION_FIELD)
        {
            textView.text = [textView.text substringToIndex:textView.text.length - 1];
            return;
        }
        [self adjustMainScrollViewFrame];
    }
    NSRange range =[textView.text rangeOfString:[textView.text substringFromIndex:textView.text.length]];
    [textView scrollRangeToVisible:range];
}

@end
