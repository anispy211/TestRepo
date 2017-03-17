//
//  SMDateFormatterViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 13/06/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMDateFormatterViewController.h"

@implementation SMDateFormatterViewController
@synthesize tableView;

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
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    lastSelectedCell =   [[NSUserDefaults standardUserDefaults] integerForKey:@"CustomDateFormat"];
    UIImage *separator = [UIImage imageNamed:@"separator.png"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:separator]];
    // Do any additional setup after loading the view from its nib.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        switch ((int)indexPath.row) {
            case 0:
                cell.textLabel.text = [NSString stringWithFormat:@"Full (Tuesday, April 12, 1952)"];
                break;
            case 1:
                cell.textLabel.text = [NSString stringWithFormat:@"Long (April 12, 1952)"];
                break;
            case 2:
                cell.textLabel.text = [NSString stringWithFormat:@"Medium (Apr 12, 1952)"];
                break;
            case 3:
                cell.textLabel.text = [NSString stringWithFormat:@"Short (04/12/52)"];
                break;
            default:
                break;
        }
    }
    [cell.textLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_CELL]];
    [cell.textLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Show current selected date format
    if(indexPath.row == lastSelectedCell)    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_dropbox_success.png"]];
        [imageView setFrame:CGRectMake(0, 0, 16, 13)];
        [cell setAccessoryView:imageView];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *myIndexPath =[NSIndexPath indexPathForRow:lastSelectedCell  inSection:indexPath.section];
    UITableViewCell *cellToDeselect = [tableView1 cellForRowAtIndexPath:myIndexPath];
    [cellToDeselect setAccessoryView:nil];
    UITableViewCell *cell = [tableView1 cellForRowAtIndexPath:indexPath];
    lastSelectedCell =indexPath.row;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_dropbox_success.png"]];
    [imageView setFrame:CGRectMake(0, 0, 16, 13)];
    [cell setAccessoryView:imageView];
    
    switch (indexPath.row) {
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

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

/**
 *  Save date format and exit
 *
 *  @param sender doneButton
 */
- (IBAction)doneButtonAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:lastSelectedCell forKey:@"CustomDateFormat"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}
@end
