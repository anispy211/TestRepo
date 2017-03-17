//
//  SMNoteViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 19/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SMNavigationBar.h"
#import "TPKeyboardAvoidingScrollView.h"
@class SMTag;
@interface SMNoteViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
{

    IBOutlet UIBarButtonItem * saveButton;
    IBOutlet UIBarButtonItem * cancelButton;
}
@property (weak, nonatomic) IBOutlet SMNavigationBar *noteNavigationBar;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainContainerScrollView;
@property (strong, nonatomic) IBOutlet UIView *containerDetailsView;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsName;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsLocation;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsDate;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsCopyright;
@property (strong, nonatomic) IBOutlet UITextView *tagDetailsCaption;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharactersLabel;
@property (strong,nonatomic) NSString *fileName;
@property (strong, nonatomic) SMTag *tag;
@property (strong, nonatomic) IBOutlet UITextView *noteNameTextView;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
@property (strong, nonatomic) SMTag *tagBeingEdited;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharacterCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxCharactersLabel;
@end
