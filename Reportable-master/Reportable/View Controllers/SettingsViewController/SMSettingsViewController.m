//
//  SMSettingsViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 2/19/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMSettingsViewController.h"
#import "SMDropboxViewController.h"


@implementation SMSettingsViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
    }
    return self;
}

/**
 *  Open mail composer for support
 *
 *  @param sender supportButton
 */
- (IBAction)mailToSupportButtonAction:(id)sender {
    MFMailComposeViewController *picker;
    picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setToRecipients:[NSArray arrayWithObject:@"support@reportable.org"]];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Apply text attributes to labels
    [footerButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SETTINGS_CELL]];
    [footerLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SETTINGS_CELL]];
    [footerButton.titleLabel setTextColor:REPORTABLE_ORANGE_COLOR];
    [footerLabel setTextColor:REPORTABLE_CREAM_COLOR];
    UIImage *separator = [UIImage imageNamed:@"separator.png"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:separator]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *containerView = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 290,30)];
    [label setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SECTION_HEADER]];
    [label setTextColor:REPORTABLE_CREAM_COLOR];
    if(section == 0)
        [label setText:@"SETTINGS"];
    else
        [label setText:@"TRANSFER"];
    
    [containerView addSubview:label];
    return containerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //[header.textLabel setTextColor:[UIColor whiteColor]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return 3;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow.png"]];
            [imageView setFrame:CGRectMake(0, 0, 9, 16.5)];
            [cell setAccessoryView:imageView];
        }
        if(indexPath.section == 0){
            switch ((int)indexPath.row) {
                case 0:
                {
                    // Date & Time
                    cell.textLabel.text = [NSString stringWithFormat:@"Date Format"];
                    [cell.imageView setImage:[UIImage imageNamed:@"clock.png"]];
                    break;
                }
                case 1:
                {
                    // CopyRight
                    [cell.textLabel setText:@"Copyright information"];
                    [cell.imageView setImage:[UIImage imageNamed:@"copyright_icon"]];
                    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
                    break;
                }
                case 2:
                    // Help
                    cell.textLabel.text = [NSString stringWithFormat:@"Help"];
                    [cell.imageView setImage:[UIImage imageNamed:@"help.png"]];
                    break;
            }
        }
        else
        {
            switch ((int)indexPath.row) {
                case 0:
                {
                    // Dropbox
                    cell.textLabel.text = [NSString stringWithFormat:@"Dropbox"];
                    [cell.imageView setImage:[UIImage imageNamed:@"dropbox_icon.png"]];
                    [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
                    break;
                }

            }
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SETTINGS_CELL]];
    [cell.textLabel setTextColor:REPORTABLE_CREAM_COLOR];
    return cell;
}


#pragma mark - Orientation methods

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                SMDateFormatterViewController *viewController2 = [[SMDateFormatterViewController alloc] initWithNibName:@"SMDateFormatterViewController" bundle:nil];
                [self.navigationController pushViewController:viewController2 animated:YES];
            }
                break;
            case 1:
            {
                SMCopyrightViewController *copyrightVC = [[SMCopyrightViewController alloc] initWithNibName:@"SMCopyrightViewController" bundle:nil];
                [self.navigationController pushViewController:copyrightVC animated:YES];
            }
                break;
            case 2:{
                SMWelcomeViewController *viewController2 = [[SMWelcomeViewController alloc] initWithNibName:@"SMWelcomeViewController" bundle:nil andIsEnteringFromSettings:YES];
                [self.navigationController pushViewController:viewController2 animated:YES];
            }
                break;
            default:
                break;
        }
    }
    else{
        switch (indexPath.row) {
            case 0:{
                
                if([Utility connectedToInternet]){
                SMDropboxViewController *dropboxVC = [[SMDropboxViewController alloc] initWithNibName:@"SMDropboxViewController" bundle:nil];
                [self.navigationController pushViewController:dropboxVC animated:YES];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
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


#pragma mark - UITextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Button Action

/**
 *  Save settings and dissmiss settings view controller
 *
 *  @param sender saveButton
 */
-(IBAction)saveButtonAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SETTINGS_DONE"
                                                        object:self];
}


@end
