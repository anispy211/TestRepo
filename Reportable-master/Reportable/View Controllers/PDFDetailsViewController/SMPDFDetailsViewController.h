
//  SMPDFDetailsViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "SMPDFViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SMTag.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SMPDFDetailsViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate>
{
    NSString *reportName,*fileName;
    NSString *username;
    NSString *password;
    NSMutableArray *selectedTagsArray;
    UINavigationController *navigationController;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UITextField *reportNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *passwordProtectionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextField;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharactersLabel;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property id pdfDelegate;

- (IBAction)passwordProtectionToggled:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil andSelectedTags:(NSArray *)tagsArray bundle:(NSBundle *)nibBundleOrNil;

@end
