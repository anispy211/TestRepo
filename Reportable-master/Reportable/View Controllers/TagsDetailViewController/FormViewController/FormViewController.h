//
//  MainViewController.h
//  TNCheckBoxDemo
//
//  Created by Frederik Jacques on 02/04/14.
//  Copyright (c) 2016 Frederik Jacques. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNCheckBoxGroup.h"
#import "SMTag.h"
#import "MBProgressHUD.h"
#import "Utility.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "GKActionSheetPicker.h"
#import "GKActionSheetPickerItem.h"


@interface FormViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,GKActionSheetPickerDelegate,UITextFieldDelegate>
{
    UIPickerView * firstPicker;
    UIPickerView * secondPicker;

    
    NSArray * pointByArray;
    NSArray * actionArray;
    
    BOOL shouldShowPicker;
    
    
    
    //NONE Array
    NSArray * actionTypeArray;
    
    //ME Array
    NSArray * myActionExecutionArray;

    
    //Competitor Array
    NSArray * oponentActionArray;
    NSArray * myActionArray;



}




@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupOpp;
@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupMyAction;
@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupmyActionExecution;



@property (nonatomic, strong) TNCheckBoxGroup *sportsGroup;


// EPEE
@property (nonatomic, strong) IBOutlet UIView * noneViewEPEE;
@property (nonatomic, strong) IBOutlet UIView * meViewEPEE;
@property (nonatomic, strong) IBOutlet UIView * opponentViewEPEE;


@property (nonatomic, strong) IBOutlet UIView * meViewEPEESeprator1;


@property (nonatomic, strong) IBOutlet UIView * opponentViewEPEESeprator1;
@property (nonatomic, strong) IBOutlet UIView * opponentViewEPEESeprator2;



// FOIL
@property (nonatomic, strong) IBOutlet UIView * noneViewFoil;
@property (nonatomic, strong) IBOutlet UIView * meViewFoil;
@property (nonatomic, strong) IBOutlet UIView * opponentViewFoil;


// SABRE
@property (nonatomic, strong) IBOutlet UIView * noneViewSabre;
@property (nonatomic, strong) IBOutlet UIView * meViewSabre;
@property (nonatomic, strong) IBOutlet UIView * opponentViewSabre;





@property (nonatomic, strong) GKActionSheetPicker *picker;


@property (nonatomic, strong) IBOutlet UIButton * saveButton;



// UI
@property (nonatomic, strong) IBOutlet UINavigationItem * navItem;


@property (nonatomic, strong) IBOutlet UITextField * pointByTxtFiled;


// none
@property (nonatomic, strong) IBOutlet UITextField * onActionTxtField;
@property (nonatomic, strong) IBOutlet UITextView * executedActionByMeTextView;
@property (nonatomic, strong) IBOutlet UITextView * sugesstedActionByMeTextView;
@property (nonatomic, strong) IBOutlet UITextView * oponnentActionTextView;

// ME
@property (nonatomic, strong) IBOutlet UITextField * oponnentActionOtherTextView;
@property (nonatomic, strong) IBOutlet UITextField * actionExecutionTextField;
@property (nonatomic, strong) IBOutlet UITextView * otherCommentsTextView;



// Competitor
@property (nonatomic, strong) IBOutlet UITextField * oponnentActionOtherTextViewCompetitor;
@property (nonatomic, strong) IBOutlet UITextField * myActionOtherTextViewCompetitor;
@property (nonatomic, strong) IBOutlet UITextField * myActionsTextField;
@property (nonatomic, strong) IBOutlet UITextView * otherCommentsAbtMETextView;



//@property (nonatomic, strong) IBOutlet UITextView * aboutCompetitorTextView;



@property (nonatomic, assign) BOOL isUpdatingPoint;
@property (nonatomic, strong) NSString * selectedAction;
@property (nonatomic, strong) NSMutableDictionary * currentFormData;

/// SMTAG
@property (strong, nonatomic) SMTag *smtag;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;




@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView * scrollView;

@property (nonatomic, strong) IBOutlet UIView * containerView;


@property (nonatomic, strong) TNCheckBoxGroup *fruitGroup;
@property (nonatomic, strong) TNCheckBoxGroup *loveGroup;
@property (nonatomic, strong) TNCheckBoxGroup *noGroup;

@end
