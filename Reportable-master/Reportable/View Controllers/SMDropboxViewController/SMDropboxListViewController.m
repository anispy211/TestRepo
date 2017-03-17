//
//  SMDropboxListViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 26/03/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMDropboxListViewController.h"

@interface SMDropboxListViewController ()
{
    NSString *currentPath;
    NSInteger downloadCount;
    SMTag *currentTag;
    NSInteger mode;
    NSString *currentExt;
    NSString *currentDownloadingFile;
    SMDropboxProgressViewController *progressVC;
}
@end

@implementation SMDropboxListViewController
@synthesize tableView;
@synthesize navigationBar;
@synthesize delegate;
@synthesize cancelButton;

/**
 *  Custom initialisation method
 *
 *  @param nibNameOrNil   nibName
 *  @param nibBundleOrNil bundleName
 *  @param dir            dropbox directory
 *  @param mode1          import/Export mode
 *
 *  @return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDirectory:(NSString *)dir andMode:(NSInteger)mode1
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentPath =dir;
        mode = mode1;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initial Setup
    [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
    [[[SMDropboxComponent sharedComponent] restClient] loadMetadata:currentPath];
    filesArray= [[NSMutableArray alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (mode==1)
        [doneButton setTitle:@"EXPORT" forState:UIControlStateNormal];
    else
    {
        [doneButton setTitle:@"IMPORT" forState:UIControlStateNormal];
        [self.navigationBar.topItem.rightBarButtonItem setEnabled:NO];
    }
    [cancelButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 40, 0, 0)];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if (mode == 1 ) { // remove back button if presented as modal view controller
        if ([self.navigationController viewControllers].count==1) {
            UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
            [self.navigationBar.topItem setLeftBarButtonItem:cancelButtonItem];
        }
    }
    [selectedFilesArray removeAllObjects];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return filesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

/**
 *  Get when file was modified in easily readable format
 *
 *  @param date dateToConvert
 *
 *  @return converted string
 */
- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit |
    NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    if (components.year > 0) {
        if(components.year==1)
            return [NSString stringWithFormat:@"1 year ago"];
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        if(components.month==1)
            return [NSString stringWithFormat:@"1 month ago"];
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        if (components.weekOfYear==1) {
            return [NSString stringWithFormat:@"1 week ago"];
        }
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return  [NSString stringWithFormat:@"Yesterday at %@",[formatter stringFromDate:date]];
        }
    } else {
        return [NSString stringWithFormat:@"Today at %@",[formatter stringFromDate:date]];
    }
}

- (SMDropboxCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SMDropboxCustomCell";
    SMDropboxCustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SMDropboxCustomCell" owner:self options:nil] objectAtIndex:0];
    }
    //add a switch
    DBMetadata *file =  (DBMetadata *)[filesArray objectAtIndex:indexPath.row];
    [cell.filenameLabel setText:file.filename];
    if(file.isDirectory == NO){
        [cell.sizeLabel setText:[[file.humanReadableSize stringByAppendingString:@", Modified "] stringByAppendingString:[self relativeDateStringForDate:file.lastModifiedDate]]];
    }
    else
        [cell.sizeLabel setText:@""];
    if(file.isDirectory == NO){
        // Not folder. Detect file type by extension and set icon image accordingly
        NSString *ext =[[file.filename componentsSeparatedByString:@"."] lastObject];
        if(([ext caseInsensitiveCompare:@"jpg"] ==NSOrderedSame) ||([ext caseInsensitiveCompare:@"jpeg"] ==NSOrderedSame))
            [cell.iconImageView setImage:[UIImage imageNamed:@"photo_icon_for_dropbox"]];
        else if(([ext caseInsensitiveCompare:@"caf"] ==NSOrderedSame))
            [cell.iconImageView setImage:[UIImage imageNamed:@"audio_icon_for_dropbox"]];
        else if(([ext caseInsensitiveCompare:@"mov"] ==NSOrderedSame))
            [cell.iconImageView setImage:[UIImage imageNamed:@"video_icon_for_dropbox"]];
        else if(([ext caseInsensitiveCompare:@"txt"] ==NSOrderedSame))
            [cell.iconImageView setImage:[UIImage imageNamed:@"note_icon_for_drobox"]];
        else if(([ext caseInsensitiveCompare:@"pdf"] ==NSOrderedSame))
            [cell.iconImageView setImage:[UIImage imageNamed:@"pdf_icon_for_dropbox"]];
        if(mode==1)
            [cell.contentView setAlpha:0.5];
        else
            [cell.contentView setAlpha:1.0];
    }
    else
    {
        // Set folder icon
        [cell.iconImageView setImage:[UIImage imageNamed:@"folder_icon_for_dropbox"]];
        if ([selectedFilesArray count])
            [cell.contentView setAlpha:0.5];
        else
            [cell.contentView setAlpha:1.0];
    }
    NSNumber *ind =[NSNumber numberWithInteger:indexPath.row];
    if([selectedFilesArray containsObject:ind])
        [cell.checkMark setHidden:NO];
    else
        [cell.checkMark setHidden:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            // Traverse through files, take files supported by Reportbale, discard others.
            currentPath = metadata.path;
            NSString *ext =[[file.filename componentsSeparatedByString:@"."] lastObject];
            
            
            if( ([ext caseInsensitiveCompare:@"mov"] ==NSOrderedSame || file.isDirectory))
                [filesArray addObject:file];
            
//            if(((([ext caseInsensitiveCompare:@"jpeg"] ==NSOrderedSame) ||
//                 ([ext caseInsensitiveCompare:@"jpg"] ==NSOrderedSame) ||([ext caseInsensitiveCompare:@"caf"] ==NSOrderedSame) || ([ext caseInsensitiveCompare:@"mov"] ==NSOrderedSame) || ([ext caseInsensitiveCompare:@"txt"] ==NSOrderedSame)||([ext caseInsensitiveCompare:@"pdf"] ==NSOrderedSame) || file.isDirectory)))
//                [filesArray addObject:file];
        }
    }
    // Sort to show directories on top
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isDirectory" ascending:NO];
    [filesArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(filesArray.count == 0 && mode==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Folder" message:@"This folder does not contain FencingApp compatible files" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    // NSLog{@"Error loading metadata: %@", error);
}

-(void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DBMetadata *file =  (DBMetadata *)[filesArray objectAtIndex:indexPath.row];
    if (file.isDirectory) {
        if([selectedFilesArray count])
        {
            // Prompt user to cancel selection or import first in order to change directory
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To import files from subfolders, import or cancel current selection" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            // Load sub-directory
            SMDropboxListViewController *dropboxListVC = [[SMDropboxListViewController alloc] initWithNibName:@"SMDropboxListViewController" bundle:nil andDirectory:file.path andMode:mode];
            dropboxListVC.delegate = self.delegate;
            [self.navigationController pushViewController:dropboxListVC animated:YES];
        }
        return;
    }
    if (mode==1) {
        // Don't allow files to be selected if it is export mode
        return;
    }
    // Show selection
    SMDropboxCustomCell *cell = (SMDropboxCustomCell *)[tableView1  cellForRowAtIndexPath:indexPath];
    if(!selectedFilesArray)
        selectedFilesArray = [[NSMutableArray alloc] init];
    NSNumber *ind =[NSNumber numberWithInteger:indexPath.row];
    if([selectedFilesArray containsObject:ind])
    {
        [selectedFilesArray removeObject:ind];
        [cell.checkMark setHidden:YES];
    }
    else{
        
        if (selectedFilesArray.count > 0)
        {
            [selectedFilesArray removeAllObjects];
        }
        
        
        [selectedFilesArray addObject:ind];
        [cell.checkMark setHidden:NO];
    }
    if (mode==0){
        if([selectedFilesArray count]){
            [self.navigationBar.topItem.rightBarButtonItem setEnabled:YES];
            UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
            [self.navigationBar.topItem setLeftBarButtonItem:cancelButtonItem];
        }
        else{
            [self.navigationBar.topItem.rightBarButtonItem setEnabled:NO];
            UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
            [self.navigationBar.topItem setLeftBarButtonItem:backButtonItem];
        }
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Download next file in queue
 */
-(void)downloadNextFile{
    [progressVC.dropboxProgressView setProgress:0.0f];
    [progressVC.dropboxProgressLabel setText:[NSString stringWithFormat:@"Importing %d of %d",(int)downloadCount+1,(int)[selectedFilesArray count]]];
    NSInteger ind = [[selectedFilesArray objectAtIndex:downloadCount] integerValue];
    DBMetadata *file=(DBMetadata *)[filesArray objectAtIndex:ind];
    [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
    NSString *filename = [NSString stringWithFormat:@"%@",file.path];
    currentDownloadingFile = [NSString stringWithFormat:@"%@/%@",[Utility dataStoragePath].path,file.filename];
    if ([[currentDownloadingFile substringFromIndex:[currentDownloadingFile rangeOfString:@"." options:NSBackwardsSearch].location+1] isEqualToString:@"jpg"]) {
        currentDownloadingFile  = [NSString stringWithFormat:@"%@.jpeg",[currentDownloadingFile substringToIndex:[currentDownloadingFile rangeOfString:@"." options:NSBackwardsSearch].location]];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:currentDownloadingFile isDirectory:NO])
    {
        int x = 1;
        NSString *filename = @"";
        do{
            NSString *nameStr =[file.filename substringToIndex:[file.filename rangeOfString:@"." options:NSBackwardsSearch].location];
            int length = (x ==0) ? 1 : (int)log10(x) + 1 +3; // formula (x ==0) ? 1 : (int)Math.log10(x) + 1 finds number of digits of int
            if (nameStr.length>=MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-length) {
                nameStr = [nameStr substringToIndex:(MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME-length)];
            }
            filename = [NSString stringWithFormat:@"%@ (%d).%@",nameStr,x,[file.filename substringFromIndex:[file.filename rangeOfString:@"." options:NSBackwardsSearch].location+1]];
            currentDownloadingFile = [NSString stringWithFormat:@"%@/%@",[Utility dataStoragePath].path,filename];
            x++;
        }while ([[NSFileManager defaultManager] fileExistsAtPath:currentDownloadingFile isDirectory:NO]);
        
    }
    currentExt = [[file.filename componentsSeparatedByString:@"."] lastObject];
    [[[SMDropboxComponent sharedComponent] restClient] loadFile:filename intoPath:currentDownloadingFile];
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath
{
    NSString *ext = [[destPath  componentsSeparatedByString:@"."] lastObject];
    if([ext isEqualToString:@"json"])   // Downloaded metadata file
    {
        // Create file with metadata information
        NSURL *url = [NSURL fileURLWithPath:destPath];
        NSData * jsonData = [NSData dataWithContentsOfFile:url.path];
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:jsonData
                              options:kNilOptions
                              error:&error];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:[SMSharedData sharedManager].dateFormat];
        [df setTimeStyle:NSDateFormatterShortStyle];
        NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", currentTag.name,[currentDownloadingFile substringFromIndex:[currentDownloadingFile rangeOfString:@"." options:NSBackwardsSearch].location+1]]];
        NSString *mainFileExt = [currentDownloadingFile substringFromIndex:[currentDownloadingFile rangeOfString:@"." options:NSBackwardsSearch].location+1];
        NSURL *newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",currentTag.name,mainFileExt]];
        NSError *err;
        [[NSFileManager defaultManager] moveItemAtURL:imageURL toURL:newURL error:&err];
        currentTag.dateTaken = [df dateFromString:[json valueForKey:@"Date"]]?[df dateFromString:[json valueForKey:@"Date"]]:[NSDate date];
        currentTag.caption = [json valueForKey:@"Caption"];
        currentTag.copyright = [json valueForKey:@"Copyright"];
        currentTag.pointType = currentWeponType;
        currentTag.address = [json valueForKey:@"Location"];
        [[SMSharedData sharedManager] addNewTag:currentTag];
        if(downloadCount<[selectedFilesArray count])
        {
            // Download next file in queue
            [self downloadNextFile];
        }
        else
        {
            // Notify user that importing has finished
            [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
            [progressVC.dropboxProgressActivityIndicatorView setHidden:YES];
            [progressVC.dropboxSuccessImageView setHidden:NO];
            [progressVC.dropboxProgressLabel setText:@"Imported"];
            [progressVC.dropboxCancelButton setEnabled:NO];
            [progressVC.dropboxDoneButton setEnabled:YES];
        }
    }
    else{
        // Create file with initial information loaded
        currentTag = [[SMTag alloc] init];
        NSString *str=[[[[destPath componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0];
        currentTag.name =  [NSString stringWithFormat:@"%@",str];
        if(([ext caseInsensitiveCompare:@"caf"] ==NSOrderedSame))
            currentTag.type=1;
        if(([ext caseInsensitiveCompare:@"mov"] ==NSOrderedSame))
            currentTag.type=2;
        if(([ext caseInsensitiveCompare:@"jpg"] ==NSOrderedSame)||([ext caseInsensitiveCompare:@"jpeg"] ==NSOrderedSame))
            currentTag.type=3;
        if(([ext caseInsensitiveCompare:@"txt"] ==NSOrderedSame))
            currentTag.type=4;
        if(([ext caseInsensitiveCompare:@"pdf"] ==NSOrderedSame))
            currentTag.type=5;
        NSInteger ind = [[selectedFilesArray objectAtIndex:downloadCount] integerValue];
        downloadCount++;
        DBMetadata *file=(DBMetadata *)[filesArray objectAtIndex:ind];
        [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
        int tempIndex = (int)([file.path rangeOfString:@"." options:NSBackwardsSearch].location);
        NSString *fileName = [NSString stringWithFormat:@"%@_md.%@.json",[file.path substringToIndex:tempIndex],ext];
        NSString *path = [NSString stringWithFormat:@"%@/%@_md.%@.json",[Utility dataStoragePath].path,[file.filename substringToIndex:file.filename.length-ext.length-1],ext];
        currentExt = @"json";
        // Download JSON metadata file
        [[[SMDropboxComponent sharedComponent] restClient] loadFile:fileName intoPath:path];
    }
}

- (void) addDefaultStampsToTag : (SMTag *)tag{
    if( !tag )
        return;
    [tag setDateTaken:[NSDate date]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoFillOn"]) {
        NSString * copyrightText = [[NSUserDefaults standardUserDefaults] stringForKey:@"CopyrightName"];
        if(![copyrightText isEqualToString:@"(null)"] && ![tag.copyright isEqualToString:@""])
            tag.copyright = copyrightText;
    }
    [tag setCoordinate:[SMLocationTracker sharedManager].currentLocation.coordinate];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([currentExt isEqualToString:@"json"])
    {
        // Downloading JSON Failed. Add default metadata information to file
        [[SMSharedData sharedManager] addDefaultStampsToTag:currentTag];
        if (currentTag.type == 3)
        {
            // Embedd metadata in TIFF dictionary of image
            NSData * data = [NSData dataWithContentsOfFile:currentDownloadingFile];
            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
            CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
            CFDictionaryRef tiff = (CFDictionaryRef)CFDictionaryGetValue(imageMetaData, kCGImagePropertyTIFFDictionary);
            NSDictionary *dict = (__bridge NSDictionary*)tiff;
            if (dict!= nil) {
                if ([dict valueForKey:@"DateTime"]) {
                    NSDateFormatter * formater = [[NSDateFormatter alloc] init];
                    [formater setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                    NSString *str = [NSString stringWithFormat:@"%@",[dict valueForKey:@"DateTime"] ];
                    NSDate * date = [formater dateFromString:str];
                    currentTag.dateTaken = date;
                } else {
                    currentTag.dateTaken = [NSDate date];
                }
                NSString * str = [NSString stringWithFormat:@"%@",[dict valueForKey:@"Copyright"]];
                if (![str  isEqualToString:@"(null)"]) {
                    currentTag.copyright = [dict valueForKey:@"Copyright"];
                } else {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoFillOn"]) {
                        NSString * copyrightText = [[NSUserDefaults standardUserDefaults] stringForKey:@"CopyrightName"];
                        if(![copyrightText isEqualToString:@"(null)"] && ![currentTag.copyright isEqualToString:@""])
                            currentTag.copyright = copyrightText;
                    }
                    else{
                        currentTag.copyright = @"";
                    }
                }
                if (![[dict valueForKey:@"ImageDescription"] isEqualToString:@"(null)"] ) {
                    currentTag.caption = [dict valueForKey:@"ImageDescription"];
                } else {
                    currentTag.caption = @"";
                }
                currentTag.type = 3;
            }
            else
            {
                currentTag.type = 3;
                [[SMSharedData sharedManager] addDefaultStampsToTag:currentTag];
            }
            [[SMSharedData sharedManager] addNewTag:currentTag];
            [[SMSharedData sharedManager] getPhotoUrlWithMetadata:[UIImage imageWithData:data] withMetaData:currentTag withName:currentTag.name];
            if(downloadCount<[selectedFilesArray count])
                [self downloadNextFile];
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self dismissViewControllerAnimated:YES
                                         completion:nil];
            }
            return;
        }
        currentTag.pointType = currentWeponType;
        [[SMSharedData sharedManager] addNewTag:currentTag];
    }
    if(downloadCount<[selectedFilesArray count]) // Files in queue are still to be downloaded
        [self downloadNextFile];
    else
    {
        // Notify user that importing has finished
        [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
        [progressVC.dropboxProgressActivityIndicatorView setHidden:YES];
        [progressVC.dropboxSuccessImageView setHidden:NO];
        [progressVC.dropboxProgressLabel setText:@"Imported"];
        [progressVC.dropboxCancelButton setEnabled:NO];
        [progressVC.dropboxDoneButton setEnabled:YES];
    }
}

-(void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath{
    [progressVC.dropboxProgressView setProgress:progress];
}

- (IBAction)doneButtonAction:(id)sender {
    if([Utility connectedToInternet]==FALSE){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(mode == 1){
        // Export action
        [self.delegate delegatedDropboxExportActionWithDirectoryPath:currentPath];
    }
    else
    {
        // Import Action
        if ([selectedFilesArray count]){
           
            
            
            
            
            UIAlertController * alert=[UIAlertController
                                       
                                       alertControllerWithTitle:@"Select Weapon Type" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* sabreBtn = [UIAlertAction
                                       actionWithTitle:@"Sabre"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           currentWeponType = POINT_SABRE;

                                           [self startImportActionForWeaponType:@"sabre"];

                                           NSLog(@"you pressed Sabre, Sabre button");
                                           // call method whatever u need
                                       }];
            UIAlertAction* foilButton = [UIAlertAction
                                         actionWithTitle:@"Foil"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             currentWeponType = POINT_FOIL;

                                             [self startImportActionForWeaponType:@"Foil"];

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
                                             [self startImportActionForWeaponType:@"EPEE"];
                                             currentWeponType = POINT_EPEE;
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
        else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)startImportActionForWeaponType:(NSString *)weaponType
{
    [self downloadNextFile];
    progressVC = [[SMDropboxProgressViewController alloc] initWithNibName:@"SMDropboxProgressViewController" bundle:nil];
    [progressVC setDelegate:self];
    [self.view addSubview:progressVC.view];
    [progressVC.dropboxProgressActivityIndicatorView startAnimating];
    [progressVC.dropboxProgressView setProgress:0.0f];
    [progressVC.dropboxProgressLabel setText:[NSString stringWithFormat:@"Importing %d of %d",(int)downloadCount+1,(int)[selectedFilesArray count]]];

}

-(void)delegatedCancelButtonAction{
    [self.navigationBar.topItem.rightBarButtonItem setEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonAction:(id)sender {
    if ([selectedFilesArray count]) {
        [selectedFilesArray removeAllObjects];
        [self.navigationBar.topItem.rightBarButtonItem setEnabled:NO];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        [self.navigationBar.topItem setLeftBarButtonItem:backButtonItem];
        [self.tableView reloadData];
    }
    else
        [self dismissViewControllerAnimated:YES completion:NO];
}
@end
