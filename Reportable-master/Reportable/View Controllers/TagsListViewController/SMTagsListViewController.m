//
//  SMTagsListViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/5/12.did
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMTagsListViewController.h"
#import "SMTag.h"
#import "SMSharedData.h"
#import "SMTagCell.h"
#import "SMNoteViewController.h"
#import "Utility.h"
#import "SMLocationTracker.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraOverLayViewController.h"

#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1

@interface SMTagsListViewController () <QBImagePickerControllerDelegate>
{
    NSInteger uploadCount,downloadLinkCount;
    NSMutableArray *publicLinksArray;
    CameraOverLayViewController * camOverlayVC;
    UIImagePickerController *imagePicker;
    NSString *pathToExport;
    SMPDFViewController *reportViewController;
    SMDropboxProgressViewController *progressVC;
    BOOL isDropboxMode;
}
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end

@implementation SMTagsListViewController

@synthesize managedObjectContext;
@synthesize collectionView;
@synthesize tabBarController;
@synthesize titleBar;
@synthesize editButton;
@synthesize settingsButton;
@synthesize editCustomButton;
@synthesize shareButton;
@synthesize selectedTags;
@synthesize settingsCustomButton;


/**
 *  Custom initialisation method
 *
 *  @param nibNameOrNil   nibName
 *  @param nibBundleOrNil Bundle
 *  @param mode           mode 1: Initialised from Dropbox->Export , mode 0 : initialised from elsewhere. Default is 0.
 *
 *  @return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isDropboxModeOn:(BOOL)mode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    isDropboxMode = mode;
    if (self)
    {
        self.title = NSLocalizedString(@"Tags", @"Tags");
        self.titleBar.topItem.title =@"Reportable";
        self.tabBarItem.image = [UIImage imageNamed:@"tags"];
        tags = [[NSMutableArray alloc] initWithArray:[SMSharedData sharedManager].tags];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateList:) name:UPDATE_LIST  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneEditingButtonAction:) name:FILE_SHARED_SUCCESSFULLY  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTagCreated) name:@"tagCreated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdate) name:NOTIFICATION_LOCATION_UPDATED  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidFail) name:NOTIFICATION_LOCATION_FAILED  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDatabase) name:@"REFRESH_ALL_DATABASE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsDoneAction) name:@"SETTINGS_DONE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableEditMode) name:@"ENABLE_EDIT_MODE" object:nil];
    }
    return self;
}

-(void)enableEditMode{
    [self editButtonAction:self.editButton];
}

/**
 *  Called when new file is created. Scrolls file view to show latest file and starts updating location.
 */
- (void) newTagCreated{
   // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SMLocationTracker sharedManager] startUpdatingLocation];
    [self scrollCollectionViewToTop];
}


-(void)settingsDoneAction
{
    [self doneEditingButtonAction:nil];
}

-(void)locationDidFail{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/**
 *  Called when location gets updates, fill location information in file created
 */
-(void) locationDidUpdate
{
    if ([[SMSharedData sharedManager] tags].count==0)
        return;
    SMTag *lastTag = (SMTag *)[[[SMSharedData sharedManager] tags] objectAtIndex:0];
    if([SMLocationTracker sharedManager].address)
        lastTag.address = [SMLocationTracker sharedManager].address;
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSString *soughtPid=[NSString stringWithString:lastTag.name];
    NSEntityDescription *productEntity=[NSEntityDescription entityForName:@"Tags" inManagedObjectContext:context];
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:productEntity];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"name == %@", soughtPid];
    [fetch setPredicate:p];
    NSError *fetchError;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    
    for (NSManagedObject *product in fetchedProducts) {
        [product setValue:lastTag.address forKey:@"location"];
    }NSError *error;
    if (![context save:&error]) {
        // NSLog{@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [[SMSharedData sharedManager] setDeviceLocation:[SMLocationTracker sharedManager].address];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (IBAction)shareButtonAction:(id)sender {
    
    NSMutableArray *mainArr = [[NSMutableArray alloc] init];
    for (NSNumber * index in self.selectedTags){
        SMTag *tag = [tags objectAtIndex:index.intValue];
        NSURL *finalURL;
        NSString *ext;
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
            case 5:
                ext = @"pdf";
                break;
        }
        finalURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", tag.name,ext]];
        
        if (tag.type!=5) {NSString *descriptionString = [NSString stringWithFormat:@"%@%@%@%@%@\n",
                                                         //1
                                                         tag.name?[NSString stringWithFormat:@"Filename : %@",tag.name]:@""
                                                         ,
                                                         //2
                                                         (tag.caption && ![tag.caption isEqualToString:@""])?[NSString stringWithFormat:@"\nCaption : %@",tag.caption]:@""
                                                         ,
                                                         //3
                                                         (tag.address && ![tag.address isEqualToString:@""])?[NSString stringWithFormat:@"\nLocation : %@",tag.address]:@""
                                                         ,
                                                         //4
                                                         tag.dateTaken?[NSString stringWithFormat:@"\nDate Created : %@",[self getDateInReadableFormatWithDate:tag.dateTaken]]:@""
                                                         ,
                                                         //5
                                                         (tag.copyright && ![tag.copyright isEqualToString:@""])?[NSString stringWithFormat:@"\nCredit : %@",tag.copyright]:@""];
            
            [mainArr addObject:descriptionString];
        }
        [mainArr addObject:finalURL];
    }
    NSNumber *index = [self.selectedTags objectAtIndex:0];
    SMTag *i=(SMTag *)[tags objectAtIndex:index.intValue];
    NSString *subjectLine = (self.selectedTags.count == 1)?i.name:nil;
    [Utility presentShareActivitySheetForViewController:self andObjects:mainArr andTagType:nil andSubjectLine:subjectLine];
}

/**
 *  Get string from the date specified in the format selected by user in settings.
 *
 *  @param date date to be converted
 *
 *  @return string converted by date
 */
- (NSString *)getDateInReadableFormatWithDate:(NSDate *)date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}


/**
 *  Called when Dropbox is selected from Activity View Controller
 */
-(void)delegatedDropboxActivitySelected{
    if([Utility connectedToInternet]==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];[alert show];
        return;
    }
    if([[DBSession sharedSession] isLinked] == NO){
        [self dismissViewControllerAnimated:YES completion:^{
            [[DBSession sharedSession] linkFromController:self];
        }];
        return;
    }
    SMDropboxListViewController *dropboxListVC;
    dropboxListVC = [[SMDropboxListViewController alloc] initWithNibName:@"SMDropboxListViewController" bundle:nil andDirectory:@"" andMode:1];
    [dropboxListVC setDelegate:self];
    if (isDropboxMode)
        [self.navigationController pushViewController:dropboxListVC animated:YES];
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:dropboxListVC];
            [navigationVC setNavigationBarHidden:YES];
            [self presentViewController:navigationVC animated:YES completion:^{
            }];
        }];
    }
}


/**
 *  Delegate method when directory is selected to export files to
 *
 *  @param path path of the directory
 */
-(void)delegatedDropboxExportActionWithDirectoryPath:(NSString *)path{
    if (isDropboxMode)
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:NO];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    pathToExport = path;
    [self uploadSelectedFileToDropbox];
}

-(BOOL)shouldAutorotate{
    return NO;
}

/**
 *  Called recursively to upload selected files to Dropbox
 */
-(void)uploadSelectedFileToDropbox{
    if(uploadCount>=[self.selectedTags count])
    {
        uploadCount=0;
        [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
        [progressVC.dropboxProgressActivityIndicatorView setHidden:YES];
        [progressVC.dropboxSuccessImageView setHidden:NO];
        [progressVC.dropboxProgressLabel setText:@"Exported"];
        [progressVC.dropboxCancelButton setEnabled:NO];
        [progressVC.dropboxDoneButton setEnabled:YES];
        return;
    }if(uploadCount==0)
    {
        progressVC = [[SMDropboxProgressViewController alloc] initWithNibName:@"SMDropboxProgressViewController" bundle:nil];
        [progressVC setDelegate:self];
        [self addChildViewController:progressVC];
        [progressVC willMoveToParentViewController:self];
        [self.view addSubview:progressVC.view];
        
        [progressVC.dropboxProgressActivityIndicatorView startAnimating];
    }
    [progressVC.dropboxProgressView setProgress:0.0f];
    [progressVC.dropboxProgressLabel setText:[NSString stringWithFormat:@"Exporting %d of %d",(int)uploadCount+1,(int)[self.selectedTags count]]];
    NSInteger index = [[self.selectedTags objectAtIndex:uploadCount] integerValue];
    SMTag *selectedTag = [[[SMSharedData sharedManager] tags] objectAtIndex:index];
    NSString *extension;
    switch ((int)selectedTag.type) {
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
    NSString *fileName= [NSString stringWithFormat:@"%@.%@", selectedTag.name,extension];
    NSURL *fileURL = [[Utility dataStoragePath] URLByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
    {
        // NSLog{@"Exists");
        NSString *destDir = pathToExport;
        [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
        [[SMDropboxComponent sharedComponent].restClient uploadFile:fileName toPath:destDir withParentRev:nil fromPath:fileURL.path];
    }
    else
    {
        // NSLog{@"File not found at path : %@",fileURL.path);
        uploadCount++;
        [self uploadSelectedFileToDropbox];
    }
}

/**
 *  Called when Dropbox Import/Export progress is cancelled
 */
-(void)delegatedCancelButtonAction{
    if(isDropboxMode)
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:NO];
    else{
        [self doneEditingButtonAction:nil];
        [progressVC.view removeFromSuperview];
    }
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    [progressVC.dropboxProgressView setProgress:progress];
    // NSLog{@"%.2f",progress); //Correct way to visualice the float
}

/**
 *  Present login window of Dropbox if not logged in already
 */
-(void)dropboxButtonAction{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}


#pragma mark - Dropbox Delegate Methods

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    // NSLog{@"File uploaded successfully to path: %@", metadata.path);
    NSString *ext =[[[[destPath pathComponents] lastObject] componentsSeparatedByString:@"."] lastObject];
    if(![ext isEqualToString:@"json"])
    {
        // Upload corresponding JSON file with file's metadata embedded in it
        NSInteger index = [[self.selectedTags objectAtIndex:uploadCount] integerValue];
        SMTag *selectedTag = [[[SMSharedData sharedManager] tags] objectAtIndex:index];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:[SMSharedData sharedManager].dateFormat];
        [df setTimeStyle:NSDateFormatterShortStyle];
        NSArray *objArray = [NSArray arrayWithObjects:selectedTag.name,selectedTag.caption?selectedTag.caption:@"",[df stringFromDate:selectedTag.dateTaken]?[df stringFromDate:selectedTag.dateTaken]:@"",selectedTag.address?selectedTag.address:@"",selectedTag.copyright?selectedTag.copyright:@"", nil];
        NSArray *keysArray = [NSArray arrayWithObjects:@"Filename",@"Caption",@"Date",@"Location",@"Copyright",nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objArray forKeys:keysArray];
        NSError *err;
        int tempIndex = (int)([srcPath rangeOfString:@"." options:NSBackwardsSearch].location);
        NSString *jsonPath = [NSString stringWithFormat:@"%@_md.%@.json",[srcPath substringToIndex:tempIndex],ext];
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
        [jsonData writeToFile:jsonPath options:NSDataWritingAtomic error:&err];
        NSString *destDir = pathToExport;
        NSString *uploadedFileName=jsonPath;
        [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
        [[SMDropboxComponent sharedComponent].restClient uploadFile:uploadedFileName toPath:destDir withParentRev:nil fromPath:jsonPath];
    }
    else
    {
        // upload next file in queue
        uploadCount++;
        [self uploadSelectedFileToDropbox];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    // NSLog{@"File upload failed with error: %@", error);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //upload next file in queue
    uploadCount++;
    [self uploadSelectedFileToDropbox];
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path
{
    // NSLog{@"PUBLIC LINK %@",link); //this is the sharable link
    // NSLog{@"File Path %@ ",path); // this is the path of the file
    downloadLinkCount++;
    NSString *directLink = [NSString stringWithFormat:@"%@",link];
    if(!publicLinksArray)
        publicLinksArray = [[NSMutableArray alloc] init];
    [publicLinksArray addObject:directLink];
    if(downloadLinkCount == [self.selectedTags count])
    {
        downloadLinkCount=0;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error
{
    // NSLog{@"Error %@",error);
}

- (void)viewDidLoad
{
    isMessageViewPresent = NO;
    [self.collectionView registerClass:[SMTagCell class] forCellWithReuseIdentifier:@"SMTag"];
    isEditModeOn = NO;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(93, 93)];
    flowLayout.minimumInteritemSpacing = 2.0f;
    flowLayout.minimumLineSpacing = 5.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 5, 15, 5);
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self updateList:nil];
    self.selectedTags = [[NSMutableArray alloc] init];
    UIImage *image = [UIImage imageNamed:@"toolBar.png"];
    [mediaToolBar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [toolBarView setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    //Set default date and time format if app is launched for first time
    if(!APP_DELEGATE.hasLaunchedOnce)
    {
        [[SMSharedData sharedManager] setDateFormat:NSDateFormatterLongStyle];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"CustomDateFormat"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self fetchSavedCustomDateFormat];
    [self.noTagsLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [self.noTagsLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [self.editCustomButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [doneCustomButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    

    self.settingsButton.customView.hidden = FALSE;
    
}

-(void)fetchSavedCustomDateFormat{
    NSInteger dateFormatSelcted = [[NSUserDefaults standardUserDefaults] integerForKey:@"CustomDateFormat"];
    switch (dateFormatSelcted) {
        case 0:
            [[SMSharedData sharedManager] setDateFormat:NSDateFormatterFullStyle];
            break;
        case 1:
            [[SMSharedData sharedManager] setDateFormat:NSDateFormatterLongStyle];
            break;
        case 2:
            [[SMSharedData sharedManager] setDateFormat:NSDateFormatterMediumStyle];
            break;
        case 3:
            [[SMSharedData sharedManager] setDateFormat:NSDateFormatterShortStyle];
            break;
        default:
            break;
    }
}

- (IBAction)settingsButtonAction:(id)sender {
//    SMSettingsViewController *settingsViewController =[[SMSettingsViewController alloc] initWithNibName:@"SMSettingsViewController" bundle:nil];
//    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
//    [navigationController1 setNavigationBarHidden:YES];
//    [self presentViewController:navigationController1 animated:YES completion:nil];
    

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([Utility connectedToInternet]){
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        SMDropboxViewController *dropboxVC = [[SMDropboxViewController alloc] initWithNibName:@"SMDropboxViewController" bundle:nil];
        
        UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:dropboxVC];
        [navigationController1 setNavigationBarHidden:YES];
        [self presentViewController:navigationController1 animated:YES completion:nil];
        
        
    }
    else
    {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

    
}

-(IBAction)showNoteEditor
{
//    [self showLibraryForVideo:YES];
//
//    return;
    
 
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    
    
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;

    
    [self presentViewController:picker animated:YES completion:NULL];


    
    
//    SMNoteViewController *noteViewController =[[SMNoteViewController alloc] initWithNibName:@"SMNoteViewController" bundle:nil];
//    [self presentViewController:noteViewController animated:YES completion:nil];
}

-(IBAction)startAudioRecording
{
    
#ifndef __IPHONE_7_0
    typedef void (^PermissionBlock)(BOOL granted);
#endif
    PermissionBlock permissionBlock = ^(BOOL granted) {
        if (granted)
        {
            [self showAudioRecorderViewController];
        }
        else
        {
            // Warn no access to microphone
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"Reportable does not have access to use microphone. Please go to Settings->Privacy->Microphone and allow access." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    };
    
    // iOS7+
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                              withObject:permissionBlock];
    }
    else
    {
        [self showAudioRecorderViewController];
    }
}

-(void)showAudioRecorderViewController{
    SMAudioRecorderViewController *audioRecorderViewController =[[SMAudioRecorderViewController alloc] initWithNibName:@"SMAudioRecorderViewController" bundle:nil];
    [self presentViewController:audioRecorderViewController animated:YES completion:nil];
}

- (IBAction)videoButtonAction:(id)sender
{
  
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;

        [self presentViewController:imagePicker animated:YES completion:NULL];

//        imagePicker = [[UIImagePickerController alloc] init];
//        camOverlayVC= [[CameraOverLayViewController alloc] initWithNibName:@"CameraOverLayViewController" bundle:nil];
//        [camOverlayVC setDelegate:self];
//        [camOverlayVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, [[UIScreen mainScreen] bounds].size.height)];
//        imagePicker.navigationBarHidden = YES;
//        imagePicker.toolbarHidden = YES;
//        imagePicker.delegate = self;
//        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
//        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
//        imagePicker.showsCameraControls = NO;
//        imagePicker.cameraViewTransform =
//        CGAffineTransformScale(imagePicker.cameraViewTransform, 1.2, 1.2);
//        imagePicker.allowsEditing = YES;
//        [self presentViewController:imagePicker animated:YES completion:nil];
//        imagePicker.cameraOverlayView = camOverlayVC.view;
    }
    else
    {
        /*
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@".mov"];
        
        NSURL *url = [Utility dataStoragePath];
        url = [url URLByAppendingPathComponent:@"vid@@@###.mov"];
        NSError *error = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:url.path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
        }[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:url.path error:&error];
        [self saveVideo];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                            object:self];
         */
                
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Camera not available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
          [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveCompleted{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CameraOverlayDelegate

- (void) flashButtonClicked:(BOOL)isFlashOff
{
    if (isFlashOff == YES) {
        [imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
    }
    else{
        [imagePicker setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
    }
}

- (void) cameraFlipButtonAction
{
    if (imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
    }
    else{
        [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
    }
}

/**
 *  Called when user switches camera mode from photo to video or vice versa
 *
 *  @param isCamera set if it is photo
 */
- (void) didChangeMode:(BOOL)isCamera
{
    if (isCamera == YES){
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    }
    else{
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    }
}

/**
 *  Present grid view of videos or photos to pick one
 *
 *  @param isVideo set if it is video
 */
- (void) showLibraryForVideo:(BOOL)isVideo;
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 1;
    
    // Set Filter Type
    if (isVideo == YES)
        imagePickerController.filterType = QBImagePickerControllerFilterTypeVideos;
    else
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    [imagePickerController setTitle:@"GALLERY"];
    [self.navigationController pushViewController:imagePickerController animated:YES];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    
    UIImage *image = [UIImage imageNamed:@"navigationBar.png"];
    [navVC.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [navVC setTitle:@"GALLERY"];
    [Utility applyReportableNavigationBarPropertiesToNavigationBar:navVC.navigationBar];
    [self presentViewController:navVC animated:YES completion:NULL];
}

- (void) startVideo
{
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [imagePicker startVideoCapture];
}

- (void) stopVideo
{
    [imagePicker stopVideoCapture];
}

- (void) takePhoto
{
    [imagePicker takePicture];
}

- (void) didCancelPicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - QBImagePickerController  Delegate

- (  NSDictionary *)getTiffDatainfoFor:(ALAsset *)asset
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    // create a buffer to hold image data
    uint8_t *buffer = (Byte*)malloc(rep.size);
    NSUInteger length = [rep getBytes:buffer fromOffset: 0.0  length:rep.size error:nil];if (length == 0)  {
        
        return nil;
    }    // buffer -> NSData object; free buffer afterwards
    NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:rep.size freeWhenDone:YES];
    
    // identify image type (jpeg, png, RAW file, ...) using UTI hint
    NSDictionary* sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[rep UTI] ,kCGImageSourceTypeIdentifierHint,nil];
    
    // create CGImageSource with NSData
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) adata,  (__bridge CFDictionaryRef) sourceOptionsDict);
    
    // get imagePropertiesDictionary
    CFDictionaryRef imagePropertiesDictionary;
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef,0, NULL);
    
    // get exif data
    CFDictionaryRef tiff = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyTIFFDictionary);
    
    NSDictionary *tiff_dict = (__bridge NSDictionary*)tiff;
    
    return tiff_dict;
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    [imagePickerController dismissViewControllerAnimated:NO completion:^{
        [imagePicker dismissViewControllerAnimated:NO completion:nil];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if ([assets count]>0)
    {ALAsset *assetOrignal = [assets objectAtIndex:0];
        ALAssetRepresentation *rep = [assetOrignal defaultRepresentation];
        CGImageRef iref = [rep fullScreenImage];
        if (!iref) {
            return ;
        }if ( [[assetOrignal valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"])
        {
            for (int i = 0; i < [assets count]; i++) {
                ALAsset *assetOrignal1 = [assets objectAtIndex:i];
                ALAssetRepresentation *rep1 = [assetOrignal1 defaultRepresentation];
                CGImageRef iref1 = [rep1 fullScreenImage];
                if (!iref1) {
                    continue ;
                }
                UIImage *largeimage = [UIImage imageWithCGImage:iref1];
                NSDictionary * tiffDict = [self getTiffDatainfoFor:[assets objectAtIndex:i]];
                [self continueSavingImage:largeimage withMetaData:tiffDict];
            }
        }
        if ( [[assetOrignal valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypeVideo"])
        {
            BOOL isSkippinVideo=NO;
            for (int i = 0; i < [assets count]; i++)
            {
                ALAssetRepresentation *rep = [(ALAsset*)[assets objectAtIndex:i] defaultRepresentation];
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[(ALAsset*)[assets objectAtIndex:i] defaultRepresentation].url];
                
                CMTime duration = playerItem.asset.duration;
                Float64 seconds = CMTimeGetSeconds(duration);
                
                if (seconds > 60.0) {
                    isSkippinVideo = YES;
                    continue;
                }
                playerItem = nil;
                
                // NSLog{@"duration: %.2f", seconds);
                
                Byte *buffer = (Byte*)malloc(rep.size);
                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                
                NSURL *url = [Utility dataStoragePath];
                url = [url URLByAppendingPathComponent:@"vid@@@###.mov"];
                NSError *error = nil;
                if([[NSFileManager defaultManager] fileExistsAtPath:url.path])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
                }
                
                [data writeToFile:url.path atomically:YES];
                [self saveVideoForPointType:POINT_SABRE];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                                    object:self];
            }
            
            //Check video duration. If more than 1 minute, discard that video with an alert
            if (isSkippinVideo == YES) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Selected video file duration was more than 1 minute" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    }
}

- (void)imagePickerControllerDidCancelQB:(QBImagePickerController *)imagePickerController
{
    UIViewController *vc =  [self presentedViewController];
    [vc dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)videoButtonTapped:(id)sender {
    [self performSelector:@selector(videoButtonAction:) withObject:self afterDelay:0.1];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
//    NSMutableArray * tmpOBJ = [[NSMutableArray alloc] initWithObjects:@"Sabre",@"Foil",@"EPEE",@"CANCEL", nil];

    
    
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Select Weapon Type" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* sabreBtn = [UIAlertAction
                                actionWithTitle:@"Sabre"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    currentWepon = @"Sabre";
                                    [self saveFileForimagePickerController:picker didFinishPickingMediaWithInfo:info forPointType:POINT_SABRE];
                                    NSLog(@"you pressed Sabre, Sabre button");
                                    // call method whatever u need
                                }];
    UIAlertAction* foilButton = [UIAlertAction
                               actionWithTitle:@"Foil"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   currentWepon = @"Foil";
                                   [self saveFileForimagePickerController:picker didFinishPickingMediaWithInfo:info forPointType:POINT_FOIL];
                                   NSLog(@"you pressed Foil, Foil button");
                                   // call method whatever u need
                                   
                               }];
    
    [alert addAction:sabreBtn];
    [alert addAction:foilButton];
    
    
    
    UIAlertAction* epeeButton = [UIAlertAction
                                actionWithTitle:@"EPEE"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    currentWepon = @"EPEE";
                                    [self saveFileForimagePickerController:picker didFinishPickingMediaWithInfo:info forPointType:POINT_EPEE];
                                    NSLog(@"you pressed EPEE, EPEE button");
                                    // call method whatever u need
                                }];
    UIAlertAction* cancelBtn = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   
                                   NSLog(@"you pressed No, thanks button");
                                   // call method whatever u need
                                   
                               }];
    
    [alert addAction:epeeButton];
    [alert addAction:cancelBtn];

    
    [self presentViewController:alert animated:YES completion:nil];
    
}



- (void)saveFileForimagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info forPointType:(NSInteger)pointType
{

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"])
    {
        [self continueToSaveVideoWithInfo:info forPointType:pointType];
    }
    else
    {UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self continueSavingImage:aImage withMetaData:nil];
        self.hidesBottomBarWhenPushed=NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
    }
}

-(void)continueSavingImage:(UIImage *)selectedImage withMetaData:(NSDictionary *)metaDataInfo
{
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",3];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
    NSString *fileName;
    if(filteredArray && [filteredArray count] > 0)
    {
        NSInteger lastphotoID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultPhotoID"];
        NSURL *newURL;do {
            fileName =[NSString stringWithFormat:@"Photo %d",(int)++lastphotoID];
            newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
        } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
        [[NSUserDefaults standardUserDefaults] setInteger:lastphotoID forKey:@"LastDefaultPhotoID"];
    }
    else{
        fileName = [NSString stringWithFormat:@"Photo 1"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LastDefaultPhotoID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    SMTag *photoTag = [[SMTag alloc] init];
    NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
    NSData *pngData = UIImageJPEGRepresentation(selectedImage, 1.0);
    [pngData writeToFile:imageURL.path atomically:YES];
    NSURL *thumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", fileName, THUMBNAIL_IMAGE]];
 
    // Create thumbnail image and save it
    UIImage *image = [Utility imageWithImage:selectedImage scaledToSizeWithSameAspectRatio:CGSizeMake(100, 100)];
    pngData = UIImageJPEGRepresentation(image, 1.0);
    [pngData writeToFile:thumbnailURL.path atomically:YES];
    
    photoTag.name = fileName;
    
    // Fill file's metadata
    if (metaDataInfo!= nil) {if ([metaDataInfo valueForKey:@"DateTime"]) {
        NSDateFormatter * formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        //  [formater setDateStyle:[[SMSharedData sharedManager] dateFormat]];
        //  [formater setTimeStyle:NSDateFormatterShortStyle];
        NSString *str = [NSString stringWithFormat:@"%@",[metaDataInfo valueForKey:@"DateTime"] ];
        NSDate * date = [formater dateFromString:str];
        photoTag.dateTaken = date;
    } else {
        photoTag.dateTaken = [NSDate date];
    }NSString * copyright = [metaDataInfo valueForKey:@"Copyright"];if (!(copyright == nil)) {
        photoTag.copyright = [metaDataInfo valueForKey:@"Copyright"];
    } else
        {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoFillOn"]) {
            NSString * copyrightText = [[NSUserDefaults standardUserDefaults] stringForKey:@"CopyrightName"];
            if(![copyrightText isEqualToString:@"(null)"] && ![photoTag.copyright isEqualToString:@""])
                photoTag.copyright = copyrightText;
        }
        else
        {
            photoTag.copyright = @"";
        }
    }
        NSString * imgDesc = [metaDataInfo valueForKey:@"ImageDescription"];
        if (!(imgDesc == nil) ) {
            photoTag.caption = [metaDataInfo valueForKey:@"ImageDescription"];
        } else {
            photoTag.caption = @"";
        }
        photoTag.type = 3;
    }
    else
    {
        photoTag.type = 3;
        [[SMSharedData sharedManager] addDefaultStampsToTag:photoTag];
    }
    [[SMSharedData sharedManager] addNewTag:photoTag];
    [self scrollCollectionViewToTop];
    [[SMSharedData sharedManager] getPhotoUrlWithMetadata:selectedImage withMetaData:photoTag withName:fileName];
}

-(void) continueToSaveVideoWithInfo:(NSDictionary *)info forPointType:(NSInteger)pointType
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSString *moviePath = nil;
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo)
    {
        moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        NSURL *url = [Utility dataStoragePath];
        url = [url URLByAppendingPathComponent:@"vid@@@###.mov"];
        NSError *error = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:url.path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
        }[[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:url.path error:&error];
        [self saveVideoForPointType:pointType];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                            object:self];
    }
}


/**
 *  Save video and create thumbnail image
 */
-(void)saveVideoForPointType:(NSInteger)pointType
{
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    NSString * fileName = nil;
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",VideoTagType];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
    // Detect if any video is saved already
    if(filteredArray && [filteredArray count] > 0)
    {
        // If yes, fetch top count of default video ID
        NSInteger lastvideoID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultVideoID"];
        NSURL *newURL;
        if(!fileName)
            do {
                fileName = [NSString stringWithFormat:@"Match %d",(int)++lastvideoID];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
            } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
        [[NSUserDefaults standardUserDefaults] setInteger:lastvideoID forKey:@"LastDefaultVideoID"];
    }
    else{
        // Or give first default name i.e. Match 1
        fileName =[NSString stringWithFormat:@"Match 1"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LastDefaultVideoID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    SMTag *videoTag = [[SMTag alloc] init];
    NSURL *url = [Utility dataStoragePath];
    url = [url URLByAppendingPathComponent:@"vid@@@###.mov"];
    NSURL *videoURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", fileName]];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:videoURL.path error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:url.path error:&error];
    videoTag.name = fileName;
    videoTag.type = 2;
    videoTag.pointType = pointType;
    // Create and save thumbnail image
    UIImage *videothumbnailImage = [Utility imageWithImage:[Utility thumbnailFromVideo:videoURL atTime:0.2] scaledToSizeWithSameAspectRatio:CGSizeMake(90  , 90)];
    NSData *pngData = UIImageJPEGRepresentation(videothumbnailImage, 1.0);
    NSURL *videoThumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", fileName, THUMBNAIL_VIDEO]];
    [pngData writeToFile:videoThumbnailURL.path atomically:YES];
    [[SMSharedData sharedManager] addDefaultStampsToTag:videoTag];
    [[SMSharedData sharedManager] addNewTag:videoTag];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    if([tags count] > 0)
    {
        [self.collectionView setHidden:NO];
        [self.noTagsLabel setHidden:YES];
    }
    [self.collectionView reloadData];
    
}

# pragma mark - Notification Methods

-(void)switchToTagsView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Scroll To top which means to the latest created file
- (void)scroll{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if(tags.count>0)
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)scrollCollectionViewToTop
{
    [self performSelector:@selector(scroll) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isDropboxMode) {
        // Presented via Dropbox->Export Files. Change button titles, states and frame of collection view
        [self enableEditMode];
        [toolBarView setHidden:YES];
        [mediaToolBar setHidden:YES];
        CGRect collectionViewFrame = self.collectionView.frame;
        collectionViewFrame.size.height = collectionViewFrame.size.height+44;
        [self.collectionView setFrame:collectionViewFrame];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBackgroundImage:[UIImage imageNamed:@"Btn_02.png"] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"Btn_02_Highlighted"] forState:UIControlStateHighlighted];
        [backButton setTitle:@"BACK" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [backButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
        [backButton setFrame:CGRectMake(0, 0, 60, 30)];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        UIButton *exportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [exportButton setTitleColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
        [exportButton setBackgroundImage:[UIImage imageNamed:@"Btn_01.png"] forState:UIControlStateNormal];
        [exportButton setBackgroundImage:[UIImage imageNamed:@"Btn_01_Highlighted"] forState:UIControlStateHighlighted];
        [exportButton setTitle:@"NEXT" forState:UIControlStateNormal];
        [exportButton addTarget:self action:@selector(delegatedDropboxActivitySelected) forControlEvents:UIControlEventTouchUpInside];
        [exportButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
        [exportButton setFrame:CGRectMake(0, 0, 60, 30)];
        [exportButton setTitleEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        UIBarButtonItem *exportButtonItem = [[UIBarButtonItem alloc] initWithCustomView:exportButton]; [exportButtonItem setEnabled:NO];
        [titleBar.topItem setLeftBarButtonItem:backButtonItem];
        [titleBar.topItem setRightBarButtonItem:exportButtonItem];
    }
    if([tags count] > 0)
    {
        [self.collectionView setHidden:NO];
        [self.noTagsLabel setHidden:YES];
    }
    else{
        [self.collectionView setHidden:YES];
        [self.noTagsLabel setText:[NSString stringWithFormat:@"Choose icon below to load an existing video or take a new video"]];
        [self.noTagsLabel setHidden:NO];
    }
    [self.collectionView reloadData];
    if ([selectedTags count]) {
        [self.titleBar.topItem.rightBarButtonItem setEnabled:YES];
    }
}

-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  Activate edit mode
 *
 *  @param sender editButton
 */
- (IBAction)editButtonAction:(id)sender {
    // Change button states and layout of view accordingly
    selectAllFlag= FALSE;
    [self.titleBar.topItem setTitle:@"Select Items"];
    [self.titleBar.topItem setRightBarButtonItem:nil];
    isEditModeOn = YES;
    [self showToolBar];
    self.settingsButton.customView.hidden = FALSE;
    [self.settingsButton setCustomView:doneCustomButton];
    [self checkIfMessageViewShouldAppear];
    if(isDropboxMode==NO)
        [self clearAllSelection];
    [self.collectionView reloadData];
}

- (void) checkIfMessageViewShouldAppear{
    // Enable or disable trash, share and PDF buttons according to the selection
    if([self.selectedTags count]>0)
        removeButton.enabled = self.createReportButton.enabled = self.shareButton.enabled = YES;
    else
        removeButton.enabled = self.createReportButton.enabled = self.shareButton.enabled = NO;
}

/**
 *  Deactivate edit mode
 *
 *  @param sender doneButton
 */
- (IBAction)doneEditingButtonAction:(id)sender {
    // Update button states, titles and layout of view accordingly
    [self.editButton setCustomView:self.editCustomButton];
    [self.titleBar.topItem setTitle:@"Fencing App"];
    [self.settingsButton setCustomView:self.settingsCustomButton];
    self.settingsButton.customView.hidden = FALSE;

    
//    [self.settingsButton.customView setHidden:YES];
    
    [self.titleBar.topItem setRightBarButtonItem:self.editButton];
    if(isMessageViewPresent)
        [timer invalidate];
    if(isEditModeOn)
        [self hideToolBar];
    isEditModeOn = NO;
    [self clearAllSelection];
    [self.collectionView reloadData];
    if([tags count] > 0){
        [self.collectionView setHidden:NO];
        [self.noTagsLabel setHidden:YES];
    }
    else{
        //show no files message
        [self.collectionView setHidden:YES];
        [self.noTagsLabel setText:[NSString stringWithFormat:@"Create your first file by tapping on one of the icons below"]];
        [self.noTagsLabel setHidden:NO];
    }
    if([tags count] > 0)
        [self.noTagsLabel setHidden:YES];
    else
        [self.noTagsLabel setHidden:NO];
}
/**
 *  Animate tool bar to hide
 */
- (void) hideToolBar
{
    
    [UIView beginAnimations:@"toolbarhide" context:nil];
    [UIView setAnimationDuration:0.55];
    [toolBarView setFrame:CGRectMake(toolBarView.frame.origin.x, toolBarView.frame.origin.y +toolBarView.frame.size.height, toolBarView.frame.size.width , toolBarView.frame.size.height)];
    [UIView commitAnimations];
}

/**
 *  Animate tool bar to show
 */
- (void) showToolBar
{
    [UIView beginAnimations:@"toolbarshow" context:nil];
    [UIView setAnimationDuration:0.55];
    [toolBarView setFrame:CGRectMake(toolBarView.frame.origin.x, toolBarView.frame.origin.y - toolBarView.frame.size.height, toolBarView.frame.size.width , toolBarView.frame.size.height)];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) updateList:(NSNotification *)notification
{
    // Refresh files array, fetch from shared data again
    tags = nil;
    tags = [[SMSharedData sharedManager] tags];
    if([tags count]){
        [self.collectionView setHidden:NO];
        [self.noTagsLabel setHidden:YES];
    }
    else{
        [self.collectionView setHidden:YES];
        [self.noTagsLabel setHidden:NO];
    }
    [self.collectionView reloadData];
    if(![tags count])
        [self.editButton setEnabled:NO];
    else
        [self.editButton setEnabled:YES];
    
    
    [APP_DELEGATE hideHUD];

}


#pragma -mark Collection View
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tags.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row>tags.count) {
        return nil;
    }
    SMTag *tag = [tags objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"SMTag";
    SMTagCell *cell = (SMTagCell *)[collectionView1 dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImage * image = nil;
    
    // Load and show icon images in collection view according to file type
    switch ((int)tag.type)
    {
        case 3:
        {
            NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[tag.name stringByAppendingFormat:@"%@.jpeg", THUMBNAIL_IMAGE]];
            image = [UIImage imageWithContentsOfFile:url.path];
        }
            break;
        case 1:
            image = [UIImage imageNamed:@"audio_icon_for_listView.png"];
            break;
        case 2:
        {
           NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[tag.name stringByAppendingFormat:@"%@.jpeg", THUMBNAIL_VIDEO]];
            image = [UIImage imageWithContentsOfFile:url.path];
            image = [Utility addImage:image secondImage:[UIImage imageNamed:@"video_icon_for_listView.png"]];
        }
            break;
        case 4:
            image = [UIImage imageNamed:@"note_icon_for_listView.png"];
            break;
        case 5:
            image = [UIImage imageNamed:@"report_icon_for_listView.png"];
            break;
        default:
            break;
    }
    [cell.titleLabel setText:tag.name];
    [cell.thumbView setImage:image];
    NSNumber * index = [NSNumber numberWithInteger:indexPath.row];
    // Get image view to show selection icon
    UIImageView * imageView = (UIImageView*)[cell viewWithTag:1001];
    if(isEditModeOn && [self.selectedTags containsObject:index])
    {
        if(!imageView){
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 93, 93)];
        }
        [imageView setTag:1001];
        [imageView setImage:[UIImage imageNamed:@"selectedTag.png"]];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView.layer setCornerRadius:2.0f];
        [imageView.layer setMasksToBounds:YES];
        [cell addSubview:imageView];
    }
    else{
        [imageView setHidden:YES];
        [imageView removeFromSuperview];
    }
    cell.thumbView.layer.borderWidth = 0.0; //prev was 1.0
    cell.thumbView.layer.cornerRadius = 2;  //prev was 10.6
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView1 didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([[SMSharedData sharedManager] isFileBeingOpened])
        return;
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView1 cellForItemAtIndexPath:indexPath];
    CGRect cellFrame = cell.frame;
    cellFrame.origin.y =  cellFrame.origin.y -self.collectionView.contentOffset.y;
    
    [[SMSharedData sharedManager] setCurrentTagsFrame:cellFrame];
    if(isEditModeOn)    // If user is in edit mode, file's index will be added to selectedTags
    {
        // If user is in edit mode, file's index will be added to selectedTags
        NSNumber * index = [NSNumber numberWithInteger:indexPath.row];
        if([self.selectedTags containsObject:index])
        {
            [self.selectedTags removeObject:index];
        }
        else{
            [self.selectedTags addObject:index];
        }
        if([self.selectedTags count])
        {
            if (isDropboxMode)
                [self.titleBar.topItem.rightBarButtonItem setEnabled:YES];
            else
                removeButton.enabled =  self.createReportButton.enabled = self.shareButton.enabled =  YES;
        }
        else
        {
            if (isDropboxMode)
                [self.titleBar.topItem.rightBarButtonItem setEnabled:NO];
            else
                removeButton.enabled =  self.createReportButton.enabled =self.shareButton.enabled =  NO;
        }
        [self.collectionView reloadData];
        
    }
    else    // Open File Details view with selected file's information loaded
    {
        // Open File Details view with selected file's information loaded
        viewController = nil;
        SMTag *tag = [tags objectAtIndex:indexPath.row];//// NSLog{@"tag type : %f",tag.type);
        switch ((int)tag.type)
        {
            case 1:
            {
                viewController = [[TagsDetailViewController alloc] initWithNibName:@"TagsDetailViewController" bundle:nil withDefaultView:kAudioView];
                viewController.tag = tag;
                break;
            }
            case 2:
            {
                viewController = [[TagsDetailViewController alloc] initWithNibName:@"TagsDetailViewController" bundle:nil withDefaultView:kVideoView];
                viewController.tag = tag;
                break;
            }
            case 3:
            {
                viewController = [[TagsDetailViewController alloc] initWithNibName:@"TagsDetailViewController" bundle:nil withDefaultView:kPhotoView];
                viewController.tag = tag;
                break;
            }
            case 4:
            {
                viewController = [[TagsDetailViewController alloc] initWithNibName:@"TagsDetailViewController" bundle:nil withDefaultView:kNoteView];
                viewController.tag = tag;
                break;
            }
            case 5:
            {
                reportViewController = [[SMPDFViewController alloc] initWithNibName:@"SMPDFViewController" bundle:nil withReportName:tag.name andTag:(SMTag *)tag];
                NSURL *pdfURL =[[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",tag.name]];
                [reportViewController setPdfFilePath:pdfURL];
                [[SMSharedData sharedManager] setIsFileBeingOpened:YES];
                [self.view addSubview:reportViewController.view];
                [[SMSharedData sharedManager] setIsFileBeingOpened:YES];
                [reportViewController setDelegate:self];
                return;
            }
            default:
                break;
        }if( viewController )
        {
        
            [self.view addSubview:viewController.view];
            [viewController.view setFrame:self.view.frame];
            [[SMSharedData sharedManager] setIsFileBeingOpened:YES];
        }
    }
}


#pragma mark - Actions / Selectors
/**
 *  Proceed to create PDF report with selected file's metadata
 *
 *  @param sender createReportButton
 */
- (IBAction)createReportAction:(id)sender
{
    // NSLog{@"selected tags : %@",self.selectedTags);
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (NSNumber * index in self.self.selectedTags){   // Filter selection to detect if any report has been selected
        SMTag *currentTag = [tags objectAtIndex:index.intValue];
        if(currentTag.type == 5)
        {
            [filteredArray addObject:index];
        }
    }
    if([filteredArray count]){
        // Alert user if reports are selected
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"PDF files cannot be included in reports. Please deselect PDF files to continue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // Present PDF details view controller with selected tags passed ahead
    SMPDFDetailsViewController * pdfDetailsViewController = [[SMPDFDetailsViewController alloc] initWithNibName:@"SMPDFDetailsViewController" andSelectedTags:self.selectedTags bundle:nil];
    [pdfDetailsViewController setPdfDelegate:self];
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:pdfDetailsViewController];
    [navigationController1 setNavigationBarHidden:YES];
    [self presentViewController:navigationController1 animated:YES completion:^{
        [self doneEditingButtonAction:nil];
    }];
}


#pragma mark - SMPDFViewControler Delegate

-(void)cancelPDFWithMode
{
    [toolBarView setHidden:NO];
}

#pragma mark - Remove Button Action

/**
 *  Delete files button action
 *
 *  @param sender deleteButton
 */
- (IBAction)removeAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    NSString *message = nil;
    if([self.selectedTags count] ==1)
        message = @"Do you really want to delete this file?";
    else
        message = @"Do you really want to delete these files?";
	[alert setTitle:@"Confirm Delete"];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"No"];
	[alert addButtonWithTitle:@"Yes"];
	[alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex){
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        if([self.selectedTags count] > 0)
        {
            // Sort selected files to be deleted in descending order one by one
            NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
            [self.selectedTags sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
            while ([self.selectedTags count])
            {
                int max = [[self.selectedTags lastObject] intValue];
                SMTag *tag = [[SMSharedData.sharedManager tags] objectAtIndex:max];
                [objects addObject:tag];
                [self.selectedTags removeLastObject];
            }
            NSSet *objectsSet = [NSSet setWithArray:objects];
            [[SMSharedData sharedManager] removeTags:objectsSet];
            tags = [[NSMutableArray alloc] initWithArray:[SMSharedData sharedManager].tags];
            [self.collectionView reloadData];
        }
        // Finish editing
        [self doneEditingButtonAction:nil];
    }
}

#pragma mark - clearAllSelection

- (void)clearAllSelection
{
    [self.selectedTags removeAllObjects];
}

/**
 *  Refresh Database from core date storage and send a notification to give update
 */
-(void) refreshDatabase
{
    [[SMSharedData sharedManager] setupApplicationDataFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
}

- (void)viewDidUnload {
    [[SMDropboxComponent sharedComponent].restClient cancelAllRequests];
    [super viewDidUnload];
}
@end
