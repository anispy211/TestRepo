//
//  AdditionalInfoViewController.m
//  FencingApp
//
//  Created by Aniruddha Kadam on 08/11/16.
//  Copyright © 2016 Krushnai. All rights reserved.
//

#import "AdditionalInfoViewController.h"
#import "GKActionSheetPicker.h"
#import "GKActionSheetPickerItem.h"

@interface AdditionalInfoViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,GKActionSheetPickerDelegate>
{
    NSArray * actionArray;
}


// You have to have a strong reference for the picker
@property (nonatomic, strong) GKActionSheetPicker *picker;

- (IBAction)cancelButtonAction:(UIButton *)btn;
- (IBAction)saveButtonAction:(UIButton *)btn;
@end

@implementation AdditionalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    actionArray = [[NSArray alloc] initWithObjects:@"POOL",@"DE", nil];

    
    if (IS_IPAD) {
        self.statusBarHeightConstraint.constant = 0;
    }
    // Do any additional setup after loading the view from its nib.
    
    [self populateTagInfo];
    
    
    UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetected:)];
    [tapGestureRecoginzer setNumberOfTapsRequired:1];
    [tapGestureRecoginzer setNumberOfTouchesRequired:1];
    [self.mainContainerScrollView addGestureRecognizer:tapGestureRecoginzer];
    
    
//    UIImageView *imgSearch=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)]; // Set frame as per space required around icon
//    [imgSearch setImage:[UIImage imageNamed:@"dropDownImg.png"]];
//    self.poolNameTxtField.rightView = imgSearch;
//    self.poolNameTxtField.rightViewMode = UITextFieldViewModeUnlessEditing;
    
}



-(void)tapGestureDetected:(UIGestureRecognizer *)gesture
{
    
    if (activeTxtFiled) {
        [activeTxtFiled resignFirstResponder];
    }
    
    if(datePicker)
    {
        [self.mainContainerScrollView hideDatePickerForTextField:self.dateTxtField andKeyboardRect:self.dateTxtField.frame];
        [self resignDatePicker];
    }
    
    if(poolVsDEPicker)
    {
        [self.mainContainerScrollView hideDatePickerForTextField:self.poolNameTxtField andKeyboardRect:self.poolNameTxtField.frame];
        [self resignPoolVsDEPicker];
    }
}

#pragma mark - SMTAG INFO

- (void)populateTagInfo
{
    if (self.smtag)
    {
        self.tournamentNameTxtField.text = self.smtag.name;
        self.poolNameTxtField.text = self.smtag.caption;
        self.opponentNameTxtField.text = self.smtag.copyright;
        
        NSDate *date = self.smtag.dateTaken;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
        
        if (self.smtag.pointType == POINT_EPEE) {
            self.weponType.text = @"EPEE";
        }
        else if (self.smtag.pointType == POINT_SABRE)
        {
            self.weponType.text = @"SABRE";
        }
        else if (self.smtag.pointType == POINT_FOIL)
        {
            self.weponType.text = @"FOIL";
        }
        
//        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
        NSString *dateString = [dateFormat stringFromDate:date];
        self.dateTxtField.text = [NSString stringWithFormat:@"%@",dateString];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)cancelButtonAction:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonAction:(UIButton *)btn
{
  
    
    
    // Check if title exists. Alert if it does not.
    if([self.tournamentNameTxtField.text isEqualToString:@""])
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Filename cannot be left blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    if(![self.tournamentNameTxtField.text isEqualToString:@""])
    {
        // Check if file with same name exists
        for(SMTag *i in [[SMSharedData sharedManager] tags])
        {
            if([i.name isEqualToString:[NSString stringWithFormat:@"%@" ,self.tournamentNameTxtField.text]] && ![i.name isEqualToString:_smtag.name] && !([i.name isEqualToString:_smtag.name]) )
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"File with same name exists" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                alert=nil;
                return;
            }
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        
        NSURL *oldURL,*newURL,*oldthumbnailURL,*newthumbnailURL;
        switch ((int)_smtag.type)
        {
                // Change file names and move files with thumbnails if exist
            case 2:
            {
                oldURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", _smtag.name]];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", self.tournamentNameTxtField.text]];
                oldthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", _smtag.name, THUMBNAIL_VIDEO]];
                newthumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", self.tournamentNameTxtField.text, THUMBNAIL_VIDEO]];
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
        if(_smtag.type == 2 || _smtag.type == 3)
        {
            // Move thumbnail images
            if ([filemgr moveItemAtPath:
                 oldthumbnailURL.path toPath:
                 newthumbnailURL.path error: NULL]  == YES)
                NSLog (@"Thumnail Move successful");
            else
                NSLog (@"Thumnail Move failed");
        }
        
        _smtag.dateTaken = newDate;
        
        NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
        NSString *soughtPid=[NSString stringWithString:_smtag.name];
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
            _smtag.name =[NSString stringWithFormat:@"%@",self.tournamentNameTxtField.text];
            _smtag.address=self.poolNameTxtField.text;
            _smtag.caption =self.poolNameTxtField.text;
            _smtag.copyright = self.opponentNameTxtField.text;
            [product setValue:_smtag.name forKey:@"name"];
            [product setValue:[NSNumber numberWithDouble:_smtag.type] forKey:@"type"];
            [product setValue:[NSNumber numberWithDouble:_smtag.coordinate.latitude] forKey:@"latitude"];
            [product setValue:[NSNumber numberWithDouble:_smtag.coordinate.longitude] forKey:@"longitude"];
            [product setValue:[NSNumber numberWithBool:_smtag.uploadStatus] forKey:@"uploadStatus"];
            [product setValue:_smtag.dateTaken forKey:@"dateTaken"];
            [product setValue:_smtag.address forKey:@"location"];
            [product setValue:_smtag.caption forKey:@"caption"];
            [product setValue:_smtag.copyright forKey:@"copyright"];
        }
        NSError *error;
        if (![context save:&error]) {
             NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        else{
            if (_smtag.type == 3) {
                // Save TIFF metadata in image's tiff dictionary
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:newURL]];
                [[SMSharedData sharedManager] getPhotoUrlWithMetadata:image withMetaData:_smtag withName:_smtag.name];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    }

    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    
    [self dismissViewControllerAnimated:YES completion:^{
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Saved Successfully" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
    }];

}

#pragma SAVE VIDEO INFO

/**
 *  Save video and create thumbnail image
 */
//-(void)saveVideo
//{
//    NSMutableArray * array = [[SMSharedData sharedManager] tags];
//    NSString * fileName = nil;
//    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",VideoTagType];
//    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
//    // Detect if any video is saved already
//    if(filteredArray && [filteredArray count] > 0)
//    {
//        // If yes, fetch top count of default video ID
//        NSInteger lastvideoID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultVideoID"];
//        NSURL *newURL;
//        if(!fileName)
//            do {
//                fileName = [NSString stringWithFormat:@"Match %d",(int)++lastvideoID];
//                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
//            } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
//        [[NSUserDefaults standardUserDefaults] setInteger:lastvideoID forKey:@"LastDefaultVideoID"];
//    }
//    else{
//        // Or give first default name i.e. Match 1
//        fileName =[NSString stringWithFormat:@"Match 1"];
//        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LastDefaultVideoID"];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    SMTag *videoTag = [[SMTag alloc] init];
//    NSURL *url = [Utility dataStoragePath];
//    url = [url URLByAppendingPathComponent:@"vid@@@###.mov"];
//    NSURL *videoURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
//    NSError *error = nil;
//    [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:videoURL.path error:&error];
//    [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
//    videoTag.name = fileName;
//    videoTag.type = 2;
//    // Create and save thumbnail image
//    UIImage *videothumbnailImage = [Utility imageWithImage:[Utility thumbnailFromVideo:videoURL atTime:0.2] scaledToSizeWithSameAspectRatio:CGSizeMake(90  , 90)];
//    NSData *pngData = UIImageJPEGRepresentation(videothumbnailImage, 1.0);
//    NSURL *videoThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", fileName, THUMBNAIL_VIDEO]];
//    [pngData writeToFile:videoThumbnailURL.path atomically:YES];
//    [[SMSharedData sharedManager] addDefaultStampsToTag:videoTag];
//    [[SMSharedData sharedManager] addNewTag:videoTag];
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
// 
//}



-(void) presentPoolVsDEPicker
{
    
    
    // Create the picker
    self.picker = [GKActionSheetPicker stringPickerWithItems:actionArray selectCallback:^(id selected) {
        // This code will be called when the user taps the "OK" button
        
        [_poolNameTxtField setText:(NSString *)selected];
        
    } cancelCallback:nil];
    
    // Present it
    [self.picker presentPickerOnView:self.view];
    
    
//    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, DEFAULT_RESPONDER_HEIGHT);
//    poolVsDEPicker = [[UIPickerView alloc] initWithFrame:frame];
//    
//    [poolVsDEPicker setDataSource: self];
//    [poolVsDEPicker setDelegate: self];
//    poolVsDEPicker.showsSelectionIndicator = YES;
//    
//    [self.view addSubview:poolVsDEPicker];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.3];
//    [poolVsDEPicker setBackgroundColor:[UIColor whiteColor]];
//    [poolVsDEPicker setCenter:CGPointMake(poolVsDEPicker.center.x, self.view.frame.size.height - poolVsDEPicker.frame.size.height/2)];
//    [UIView commitAnimations];
}



-(void)resignPoolVsDEPicker
{
//    if(poolVsDEPicker)
//    {
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationDuration:0.3];
//        [poolVsDEPicker setCenter:CGPointMake(poolVsDEPicker.center.x, self.view.frame.size.height + poolVsDEPicker.frame.size.height/2)];
//        [UIView commitAnimations];
//        poolVsDEPicker = nil;
//    }
}



/**
 *  Initialise and present date picker animating from bottom
 */
-(void) presentDatePicker
{
    
    self.picker = [GKActionSheetPicker datePickerWithMode:UIDatePickerModeDate from:[NSDate dateWithTimeIntervalSinceNow:-60*60*24*365] to:[NSDate new] interval:60*60*24 selectCallback:^(id selected) {
        
        self.dateTxtField.text = [NSString stringWithFormat:@"%@", [self getDateFromDatePickerInReadableFormatWithDatePicker:self.picker.datePicker]];
       
        newDate = self.picker.datePicker.date;

        
    } cancelCallback:^{
        //
    }];
    
    // Set the title
    self.picker.title = @"Date";
    
    // Present it
    [self.picker presentPickerOnView:self.view];
    
    // Set to the previously selected value
    [self.picker selectDate:self.smtag.dateTaken];

    
//    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, DEFAULT_RESPONDER_HEIGHT);
//    datePicker = [[UIDatePicker alloc] initWithFrame:frame];
//    datePicker.datePickerMode = UIDatePickerModeDate;
//
//    [self.view addSubview:datePicker];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.3];
//    [datePicker setBackgroundColor:[UIColor whiteColor]];
//    [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height - datePicker.frame.size.height/2)];
//    [datePicker addTarget:self action:@selector(datePickerDidRoll:) forControlEvents:UIControlEventValueChanged];
//    [UIView commitAnimations];
}

- (void) datePickerDidRoll:(UIDatePicker *)datePicker1{
    // Set date and enable save and cancel buttons
    [self.dateTxtField setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker1]];
    newDate = datePicker1.date;
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


/**
 *  Dismiss and animate date picker out
 */
-(void)resignDatePicker
{
    if(datePicker)
    {
        [self.dateTxtField setText:[self getDateFromDatePickerInReadableFormatWithDatePicker:datePicker]];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [datePicker setCenter:CGPointMake(datePicker.center.x, self.view.frame.size.height + datePicker.frame.size.height/2)];
        [UIView commitAnimations];
        datePicker = nil;
    }
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self resignDatePicker];
    
        [self resignPoolVsDEPicker];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    // [self.picker dismissPickerView];
    
    
    shouldShowPicker = YES;
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
   
//    if(datePicker)
//    {
//        [self.mainContainerScrollView hideDatePickerForTextField:self.dateTxtField andKeyboardRect:self.dateTxtField.frame];
//        [self resignDatePicker];
//    }
    
    
    activeTxtFiled = textField;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    if (shouldShowPicker) {
        
        shouldShowPicker = false;
        
        return NO;
    }
    
    self.mainContainerScrollView.currentTextView = (UITextView *)textField;
    if(textField == self.dateTxtField)
    {
        [self.tournamentNameTxtField resignFirstResponder];
        [self.poolNameTxtField resignFirstResponder];
        [self.opponentNameTxtField resignFirstResponder];
        //if(!datePicker)
            [self presentDatePicker];
       // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
        return NO;
    }
    
    if(textField == self.poolNameTxtField)
    {
        [self.tournamentNameTxtField resignFirstResponder];
        [self.dateTxtField resignFirstResponder];
        [self.opponentNameTxtField resignFirstResponder];
       // if(!poolVsDEPicker)
            [self presentPoolVsDEPicker];
       // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
        return NO;
    }
    
    
    
    return YES;
}


/*

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
