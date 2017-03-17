//
//  AdditionalInfoViewController.h
//  FencingApp
//
//  Created by Aniruddha Kadam on 08/11/16.
//  Copyright © 2016 Krushnai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "SMTag.h"
#import "MBProgressHUD.h"
#import "Utility.h"


@interface AdditionalInfoViewController : UIViewController <UITextFieldDelegate>
{
    UIDatePicker *datePicker;
    NSDate *newDate;
    
    UIPickerView * poolVsDEPicker;

    
    UITextField * activeTxtFiled;
    
    BOOL shouldShowPicker;

}

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainContainerScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeightConstraint;

/// SMTAG
@property (strong, nonatomic) SMTag *smtag;


@property (nonatomic,weak) IBOutlet UITextField * tournamentNameTxtField;
@property (nonatomic,weak) IBOutlet UITextField * poolNameTxtField;
@property (nonatomic,weak) IBOutlet UITextField * opponentNameTxtField;
@property (nonatomic,weak) IBOutlet UITextField * weponType;

@property (nonatomic,weak) IBOutlet UITextField * dateTxtField;


@end
