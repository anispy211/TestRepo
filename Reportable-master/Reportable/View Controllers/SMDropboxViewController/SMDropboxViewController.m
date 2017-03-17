//
//  SMDropboxViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 26/03/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMDropboxViewController.h"
#import "SMTagsListViewController.h"

@interface SMDropboxViewController ()

@end

@implementation SMDropboxViewController
{
    NSMutableDictionary *accountInfo;
}
@synthesize tableView;
@synthesize currentUsageStaticLabel;
@synthesize signOutButton;

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
    // Initial Setup
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
    if ([[DBSession sharedSession] isLinked]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[[SMDropboxComponent sharedComponent] restClient] loadAccountInfo];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinkingSuccessfulAction:) name:DROPBOX_LINKING_DONE object:nil];
    [_quotaRemainingLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    [self.signOutButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [self.currentUsageStaticLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    UIImage *separator = [UIImage imageNamed:@"separator.png"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:separator]];
    // Do any additional setup after loading the view from its nib.
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section ==2) {
        // Sign out button
        UIView * signOutButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        [signOutButtonContainer setBackgroundColor:[UIColor clearColor]];
        [self.signOutButton setFrame:CGRectMake(0,16,self.signOutButton.frame.size.width,self.signOutButton.frame.size.height)];
        [signOutButtonContainer addSubview:self.signOutButton];
        return  signOutButtonContainer;
    }
    return nil;
}
        

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==2) {
        return 80;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //[header.textLabel setTextColor:[UIColor whiteColor]];
}
        
-(void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info{
    // Called when Dropbox account information is loaded
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    accountInfo = [[NSMutableDictionary alloc] init];
    [accountInfo setValue:info.displayName forKey:@"name"];
    [accountInfo setValue:[NSNumber numberWithLongLong:info.quota.totalBytes/(1024*1024)] forKey:@"totalSpace"];
    [accountInfo setValue:[NSNumber numberWithLongLong:info.quota.normalConsumedBytes/(1024*1024)] forKey:@"usedSpace"];
    [accountInfo setValue:[[info valueForKey:@"original"] valueForKey:@"email"] forKey:@"email"];
    [self.tableView reloadData];
}

/**
 *  Toggle Drobox - Login/Logout
 *
 *  @param sender dropboxSwitch
 */
- (IBAction)dropboxStateToggled:(UISwitch *)sender{
    if([[DBSession sharedSession] isLinked]){
        [[DBSession sharedSession] unlinkAll];
        [self.tableView reloadData];
    }
    else{
        [[DBSession sharedSession] setDelegate:APP_DELEGATE];
        [[DBSession sharedSession] linkFromController:self];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(![[DBSession sharedSession] isLinked])
        return 1;   // Not logged in
    else
        return 3;   // Logged in to Dropbox
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 2)
        return 50;
    if(indexPath.section == 2 && indexPath.row == 2)
        return 55;
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section !=0)
        return 50;
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *containerView = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 280,30)];
    [label setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SECTION_HEADER]];
    [label setTextColor:[UIColor darkTextColor]];
    switch (section) {
        case 0:
            [label setText:@""];
            break;
        case 1:
            [label setText:@"ACCOUNT INFO"];
            break;
        case 2:
            [label setText:@"EXPORT / IMPORT"];
            break;
    }
    [containerView addSubview:label];
    return containerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
    }
    return 2;
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (IBAction)backButtonAction:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SETTINGS_DONE"
                                                        object:self];
    
}

/**
 *  Converts size in MB to easily readable size
 *
 *  @param size size string in MB
 *
 *  @return readable size string
 */
-(NSString *)findReadableSizeForSize:(NSNumber *)size{
    NSInteger val = [size integerValue];
    if(val/1024 >= 1.0)
        return [NSString stringWithFormat:@"%d GB",(int)val/1024];
    else
        return [NSString stringWithFormat:@"%d MB",(int)val];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                {
                    // Link/Unlink
                    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                    cell.accessoryView = switchview;
                    [switchview setOn:[[DBSession sharedSession] isLinked]];
                    [switchview addTarget:self action:@selector(dropboxStateToggled:) forControlEvents:UIControlEventValueChanged];
                    [switchview setOnTintColor:[UIColor blueColor]];
                    cell.textLabel.text = [NSString stringWithFormat:@"Dropbox"];

                    break;
                }
            }
            break;
        }
        case 1:
        {
            switch ((int)indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"Account : %@",[accountInfo valueForKey:@"name"]?[accountInfo valueForKey:@"name"]:@""];
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"Email ID : %@",[accountInfo valueForKey:@"email"]?[accountInfo valueForKey:@"email"]:@""];
                    break;
                }
                case 2:
                {
                    [_quotaProgressView setProgress:[[accountInfo valueForKey:@"usedSpace"] doubleValue]/[[accountInfo valueForKey:@"totalSpace"] doubleValue]];
                    [_quotaRemainingLabel setText:[NSString stringWithFormat:@"%@ / %@ ",[self findReadableSizeForSize:[accountInfo valueForKey:@"usedSpace"]],[self findReadableSizeForSize:[accountInfo valueForKey:@"totalSpace"]]]];
                    [cell addSubview:_quotaContainerView];
                    break;
                }
            }
            break;
        }
        case 2:{
            switch ((int)indexPath.row) {
                case 0:
                {
                    // Import
                    cell.textLabel.text = [NSString stringWithFormat:@"Export Files"];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]];
                    [imageView setFrame:CGRectMake(0, 0, 9, 16.5)];
                    [cell setAccessoryView:imageView];
                    break;
                }
                case 1:
                {
                    // Export
                    cell.textLabel.text = [NSString stringWithFormat:@"Import Files"];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]];
                    [imageView setFrame:CGRectMake(0, 0, 9, 16.5)];
                    [cell setAccessoryView:imageView];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SETTINGS_CELL]];
    [cell.textLabel setTextColor:[UIColor darkTextColor]];
    
    return cell;
}

/**
 *  Called when received notification that user has been logged in
 *
 *  @param notification loginNotification
 */
-(void)dropboxLinkingSuccessfulAction:(NSNotification *)notification{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
    [[[SMDropboxComponent sharedComponent] restClient] loadAccountInfo];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2){
        if([Utility connectedToInternet]==FALSE){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            return;
        }
        switch (indexPath.row) {
            case 0:{
                if ([[SMSharedData sharedManager].tags count] == 0)
                {
                    // Validate if there are files present
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please create files and then export to dropbox" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else{
                    // Export mode selected
                    SMTagsListViewController *viewController1 = [[SMTagsListViewController alloc] initWithNibName:@"SMTagsListViewController" bundle:nil isDropboxModeOn:YES];
                    [self.navigationController pushViewController:viewController1 animated:YES];
                }
                break;
            }
            case 1:{
                // Import mode selected
                SMDropboxListViewController *dropboxListVC = [[SMDropboxListViewController alloc] initWithNibName:@"SMDropboxListViewController" bundle:nil andDirectory:@"" andMode:0];
                [self.navigationController pushViewController:dropboxListVC animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
