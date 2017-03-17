//
//  SMPDFDetailsViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMPDFDetailsViewController.h"


@interface SMPDFDetailsViewController ()

@end

@implementation SMPDFDetailsViewController
{   NSString *initialName;
    UIDatePicker *datePicker;
}

@synthesize reportNameTextField;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize passwordProtectionSwitch;
@synthesize pdfDelegate;
@synthesize passwordLabel;
@synthesize notesTextField;
@synthesize dateTextField;
@synthesize containerScrollView;
@synthesize remainingCharactersLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil andSelectedTags:(NSMutableArray *)tagsArray bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedTagsArray = [[NSMutableArray alloc] initWithArray:tagsArray];
        username =  nil;
        password = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.reportNameTextField becomeFirstResponder];
    int count =(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultReportID"];
    NSString *path;
    // Find default available name for new PDF by traversing through saved PDFs
    do{
        path = [NSString stringWithFormat:@"%@/Report %d",[Utility dataStoragePath],++count];
    }while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    
    initialName = reportName = [NSString stringWithFormat:@"Report %d",count];
    [self.reportNameTextField setText:reportName];
    username = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
    [self.usernameTextField setText:username];
    [self setTextFieldAttributes];
    // Apply fonts to text fields
    [self.usernameTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.dateTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.notesTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.passwordTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.reportNameTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.passwordLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.passwordLabel setTextColor:[UIColor whiteColor]];
    self.passwordTextField.layer.borderWidth=self.reportNameTextField.layer.borderWidth=self.usernameTextField.layer.borderWidth =self.notesTextField.layer.borderWidth=self.dateTextField.layer.borderWidth = 1;
    self.passwordTextField.layer.borderColor = self.reportNameTextField.layer.borderColor = self.usernameTextField.layer.borderColor=self.notesTextField.layer.borderColor=self.dateTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.date = [NSDate date];
    [self.dateTextField setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker]];
    [self.containerScrollView setContentSize:CGSizeMake(self.containerScrollView.frame.size.width, self.passwordTextField.frame.origin.y + 50)];
    [self.containerScrollView setContentOffset:CGPointMake(0, 0)];
    NSInteger count1=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-self.reportNameTextField.text.length;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count1]];
    self.reportNameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.reportNameTextField)
        return YES;
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    NSInteger afterCount = (self.reportNameTextField.text.length-range.length+string.length);
    // Don't allow more characters than allowed to be entered in report title text field
    if(afterCount>=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME+1 && textField == self.reportNameTextField && isBackSpace != -8)
        return NO;
    NSInteger count=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME - afterCount;
    [self.remainingCharactersLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
    return YES;
}

/**
 *  Initialise and present date picker to animate in
 */
-(void) presentDatePicker
{
    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, DEFAULT_RESPONDER_HEIGHT);
    if (!datePicker)
        datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    else
        [datePicker setFrame:frame];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.view addSubview:datePicker];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height - datePicker.frame.size.height/2)];
    [datePicker addTarget:self action:@selector(datePickerDidRoll:) forControlEvents:UIControlEventValueChanged];
    [UIView commitAnimations];
}

-(void) datePickerDidRoll:(UIDatePicker *)datePicker1
{
    // Set date string as text to date text field
    if (datePicker1.date!=nil)
        [self.dateTextField setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker1]];
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
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}

-(BOOL)shouldAutorotate{
    return NO;
}

/**
 *  Set padding properties to text fields
 */
-(void)setTextFieldAttributes{
    self.reportNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
    self.usernameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
    self.dateTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(8, 0, 0);
    self.notesTextField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Called when password protection switch changes value
 *
 *  @param sender passwordSwitch
 */
- (IBAction)passwordProtectionToggled:(id)sender {
    BOOL currentState = [self.passwordProtectionSwitch isOn];
    [self.passwordTextField setHidden:!currentState];
    if(currentState)
       [self.passwordTextField becomeFirstResponder];
    else
    {
        [self.usernameTextField becomeFirstResponder];
        [self.passwordTextField setText:nil];
    }
}

/**
 *  Cancel PDF creation
 *
 *  @param sender <#sender description#>
 */
- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self textFieldShouldReturn:(UITextField *)textView];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Switch text field by next button. Handle last text field's return action
    int tag = (int)textField.tag;
    if (tag==100) {
        [self textFieldShouldBeginEditing:self.dateTextField];
    }
    else{
    if((![self.passwordProtectionSwitch isOn]&&tag==102)||tag==103)
        tag = 99; // If password protection is off, jump to first text field
        UITextField *field = (UITextField *)[self.view viewWithTag:++tag];
        [field becomeFirstResponder];
        if ([self.notesTextField isFirstResponder]) {
            return NO;
        }
    }
    return YES;
}

/**
 *  Save and continue to PDF generation
 *
 *  @param sender saveButton
 */
- (IBAction)saveButtonAction:(id)sender {
    NSURL *newURL;
    self.reportNameTextField.text = [self.reportNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *reportNameByUser = self.reportNameTextField.text;
    NSInteger lastReportID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultReportID"];
    // Validate title text field
    if(!self.reportNameTextField.text || [self.reportNameTextField.text isEqualToString:@""])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please enter report title" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    fileName = [NSString stringWithFormat:@"%@",reportNameByUser];
    if([reportNameByUser isEqualToString:initialName]){
        [[NSUserDefaults standardUserDefaults] setInteger:++lastReportID forKey:@"LastDefaultReportID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", fileName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:newURL.path])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Report with same name already exists" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
   reportName = [NSString stringWithFormat:@"%@.pdf",reportNameByUser];
    // Validate other text fields
   if([usernameTextField.text isEqualToString:@""] || usernameTextField.text== nil )
    {
       UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please enter a author name" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        return;
    }
    if([self.passwordProtectionSwitch isOn])
    {
        if(([self.passwordTextField.text isEqualToString:@""]|| self.passwordTextField.text== nil ))
        {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Please enter a password" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        return;
        }
        if([self.passwordTextField.text length]<=5)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password must contain at least 6 charaters" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

            alert=nil;
            return;
        }
    }
    // Save username in user defaults
    [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"Username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *capitalized = [[[reportName substringToIndex:1] uppercaseString] stringByAppendingString:[reportName substringFromIndex:1]];
    SMPDFViewController * pdfViewController = [[SMPDFViewController alloc] initWithNibName:@"SMPDFViewController" bundle:nil andArrayOfTags:selectedTagsArray andPassword:self.passwordTextField.text andReportName:capitalized andUsername:self.usernameTextField.text andNotes:[Utility color:self.notesTextField.textColor matchesColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]]?@"":self.notesTextField.text andDateString:self.dateTextField.text];
    [pdfViewController setDelegate:self.pdfDelegate];
    [self.navigationController pushViewController:pdfViewController animated:YES];
    [self savePDFToTags];
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([Utility color:textView.textColor matchesColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]])
    {
        [textView setText:@""];
        [textView setTextColor:[UIColor darkGrayColor]];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.dateTextField) {
            [self.reportNameTextField resignFirstResponder];
            [self.usernameTextField resignFirstResponder];
            [self.passwordTextField resignFirstResponder];
            [self.notesTextField resignFirstResponder];
            if(!datePicker)
                [self presentDatePicker];
            [self.containerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
            return NO;
    }
    if(datePicker)
    {
        [self.containerScrollView hideDatePickerForTextField:self.dateTextField andKeyboardRect:self.dateTextField.frame];
        [self resignDatePicker];
    }
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [self textFieldShouldBeginEditing:(UITextField *)textView];
}

/**
 *  Dismiss and animate date picker to hide
 */
-(void)resignDatePicker
{
    if(datePicker)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height + datePicker.frame.size.height/2)];
        [UIView commitAnimations];
        datePicker = nil;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@""]){
        [textView setText:@"Notes"];
        [textView setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]];
    }
}

/**
 *  Add PDF to files collection to be shown on home screen
 */
-(void)savePDFToTags{
    SMTag *pdfTag = [[SMTag alloc] init];
    pdfTag.name = fileName;
    pdfTag.type = 5;
    [[SMSharedData sharedManager] addDefaultStampsToTag:pdfTag];
    [[SMSharedData sharedManager] addNewTag:pdfTag];
}

- (void)viewDidUnload {
    [self setPasswordLabel:nil];
    [super viewDidUnload];
}
@end
