//
//  SMCopyrightViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 04/04/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMCopyrightViewController.h"

@interface SMCopyrightViewController (){
    BOOL isAutoFillOn;
    UITextView *copyrightTextField;
}
@end

@implementation SMCopyrightViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    if (isAutoFillOn) {
        [self performSelector:@selector(becomeFirstResponderOfCopyright) withObject:nil afterDelay:0.01];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initial Setup
    isAutoFillOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoFillOn"];
    UIImage *separator = [UIImage imageNamed:@"separator.png"];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setSeparatorColor:[UIColor colorWithPatternImage:separator]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(isAutoFillOn)
        return 2;
    else
        return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        return 120;
    }
    else return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_CELL]];
    [cell.textLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [cell setBackgroundColor:[UIColor clearColor]];
    switch (indexPath.row) {
        case 0:
        {
            // Copyright On/Off
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchview;
            [switchview setOn:isAutoFillOn];
            [switchview addTarget:self action:@selector(autoFillStateToggled:) forControlEvents:UIControlEventValueChanged];
            [switchview setOnTintColor:[UIColor orangeColor]];
            cell.textLabel.text = [NSString stringWithFormat:@"Autofill Copyright"];
            break;
        }
        case 1:
        {
            // Setting in on, present text field
            if(copyrightTextField==nil)
            {
                copyrightTextField = [[UITextView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.origin.y, 290, (cell.contentView.frame.size.height-8)*3)];
                [copyrightTextField setText:@""];
                [copyrightTextField setDelegate:self];
            }
            NSString * copyrightText = [[NSUserDefaults standardUserDefaults] stringForKey:@"CopyrightName"];
            if(!copyrightText||[copyrightText isEqualToString:@"(null)"]||[copyrightText isEqualToString:@""]||[copyrightText isEqualToString:@"©"]){
                copyrightText = @"©";
                [copyrightTextField setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
            }
            else
                [copyrightTextField setTextColor:[UIColor darkGrayColor]];
            [copyrightTextField setText:copyrightText];
            [copyrightTextField setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
            copyrightTextField.layer.borderWidth=1;
            copyrightTextField.layer.borderColor = [[UIColor grayColor] CGColor];
            copyrightTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
            [cell addSubview:copyrightTextField];
        }
            break;
    }
    return cell;
}

-(void)textViewDidChange:(UITextView *)textView{
    [copyrightTextField setTextColor:[UIColor darkGrayColor]];
}

/**
 *  Toggle auto fill copyright
 *
 *  @param sender autoFillCopyrightSwitch
 */
- (void)autoFillStateToggled:(UISwitch *)sender{
    isAutoFillOn = [sender isOn];
    if (isAutoFillOn==NO){
        [self saveSettings];
        [copyrightTextField resignFirstResponder];
    }
    else
        [self performSelector:@selector(becomeFirstResponderOfCopyright) withObject:nil afterDelay:0.1];
    [self.tableView reloadData];
}

-(void)becomeFirstResponderOfCopyright{
    [copyrightTextField becomeFirstResponder];
}

/**
 *  Save auto fill copyright settings
 */
-(void)saveSettings{
    NSString * str = [NSString stringWithFormat:@"%@",copyrightTextField.text];
    [[NSUserDefaults standardUserDefaults] setBool:isAutoFillOn forKey:@"isAutoFillOn"];
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"CopyrightName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)backButtonAction:(id)sender {
    [self saveSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
