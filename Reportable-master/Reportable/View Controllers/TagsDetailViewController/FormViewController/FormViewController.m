//
//  MainViewController.m
//  TNCheckBoxDemo
//
//  Created by Frederik Jacques on 02/04/14.
//  Copyright (c) 2016 Frederik Jacques. All rights reserved.
//

#import "FormViewController.h"
#import "Utility.h"
#import "Points+CoreDataClass.h"
#import "Tags+CoreDataProperties.h"
#import "Tags+CoreDataClass.h"
#import "Sabre+CoreDataClass.h"
#import "Foil+CoreDataClass.h"

@interface FormViewController ()

@end

@implementation FormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - CORE DATA - SAVE POINT INFO

- (void)saveCurrentPoint
{
    
    NSManagedObjectContext *context = [APP_DELEGATE managedObjectContext];
    NSString *soughtPid=[NSString stringWithString:_smtag.name];
    NSEntityDescription *productEntity=[NSEntityDescription entityForName:@"Tags" inManagedObjectContext:context];
    
    
    
    NSFetchRequest *fetch=[[NSFetchRequest alloc] init];
    [fetch setEntity:productEntity];
    NSPredicate *p=[NSPredicate predicateWithFormat:@"name == %@", soughtPid];
    [fetch setPredicate:p];
    //... add sorts if you want them
    NSError *fetchError;
    NSArray *fetchedProducts=[context executeFetchRequest:fetch error:&fetchError];
    // handle error
    
    for (Tags *product in fetchedProducts) {
        
        if (_isUpdatingPoint)
        {
           
            if (self.smtag.pointType == POINT_EPEE || self.smtag.pointType == POINT_SABRE || self.smtag.pointType == POINT_FOIL)
            {
                NSSet * pt = product.points;
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"que1 == %@", [_currentFormData valueForKey:@"que1"]];
                NSSet *result =  [pt filteredSetUsingPredicate:predicate];
                
                NSManagedObject * point = [[result allObjects] lastObject];
                
                [point setValue:[_currentFormData valueForKey:@"que1"] forKey:@"que1"];
                [point setValue:[_currentFormData valueForKey:@"que2"] forKey:@"que2"];
                [point setValue:[_currentFormData valueForKey:@"que3"]forKey:@"que3"];
                [point setValue:[_currentFormData valueForKey:@"que4"] forKey:@"que4"];
                [point setValue:[_currentFormData valueForKey:@"que5"] forKey:@"que5"];
                [point setValue:[_currentFormData valueForKey:@"que6"] forKey:@"que6"];
                [point setValue:[_currentFormData valueForKey:@"que7"] forKey:@"que7"];
                [point setValue:[_currentFormData valueForKey:@"que8"] forKey:@"que8"];
                [point setValue:[_currentFormData valueForKey:@"que9"] forKey:@"que9"];
                [point setValue:[_currentFormData valueForKey:@"que10"]forKey:@"que10"];
                [point setValue:[_currentFormData valueForKey:@"que11"] forKey:@"que11"];
                [point setValue:[_currentFormData valueForKey:@"que12"] forKey:@"que12"];
                [point setValue:[_currentFormData valueForKey:@"que13"] forKey:@"que13"];
                [point setValue:[_currentFormData valueForKey:@"que14"] forKey:@"que14"];
                [point setValue:[_currentFormData valueForKey:@"que15"] forKey:@"que15"];
                [point setValue:[_currentFormData valueForKey:@"que16"] forKey:@"que16"];
            }
//            else if (self.smtag.pointType == POINT_SABRE)
//            {
//                NSSet * pt = product.sabre;
//                
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"que1 == %@", [_currentFormData valueForKey:@"que1"]];
//                NSSet *result =  [pt filteredSetUsingPredicate:predicate];
//                
//                NSManagedObject * point = [[result allObjects] lastObject];
//                
//                [point setValue:[_currentFormData valueForKey:@"que1"] forKey:@"que1"];
//                [point setValue:[_currentFormData valueForKey:@"que2"] forKey:@"que2"];
//                [point setValue:[_currentFormData valueForKey:@"que3"]forKey:@"que3"];
//                [point setValue:[_currentFormData valueForKey:@"que4"] forKey:@"que4"];
//                [point setValue:[_currentFormData valueForKey:@"que5"] forKey:@"que5"];
//                [point setValue:[_currentFormData valueForKey:@"que6"] forKey:@"que6"];
//                [point setValue:[_currentFormData valueForKey:@"que7"] forKey:@"que7"];
//            }
//            else if (self.smtag.pointType == POINT_FOIL)
//            {
//                NSSet * pt = product.foil;
//                
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"que1 == %@", [_currentFormData valueForKey:@"que1"]];
//                NSSet *result =  [pt filteredSetUsingPredicate:predicate];
//                
//                NSManagedObject * point = [[result allObjects] lastObject];
//                
//                [point setValue:[_currentFormData valueForKey:@"que1"] forKey:@"que1"];
//                [point setValue:[_currentFormData valueForKey:@"que2"] forKey:@"que2"];
//                [point setValue:[_currentFormData valueForKey:@"que3"]forKey:@"que3"];
//                [point setValue:[_currentFormData valueForKey:@"que4"] forKey:@"que4"];
//                [point setValue:[_currentFormData valueForKey:@"que5"] forKey:@"que5"];
//                [point setValue:[_currentFormData valueForKey:@"que6"] forKey:@"que6"];
//                [point setValue:[_currentFormData valueForKey:@"que7"] forKey:@"que7"];
//            }
         
        }
        else
        {
            
            if (self.smtag.pointType == POINT_EPEE || self.smtag.pointType == POINT_SABRE || self.smtag.pointType == POINT_FOIL)
            {
                Points * poi = [NSEntityDescription insertNewObjectForEntityForName:@"Points" inManagedObjectContext:context];
                
                poi.que1 = [_currentFormData valueForKey:@"que1"];
                poi.que2 = [_currentFormData valueForKey:@"que2"];
                poi.que3 = [_currentFormData valueForKey:@"que3"];
                poi.que4 = [_currentFormData valueForKey:@"que4"];
                poi.que5 = [_currentFormData valueForKey:@"que5"];
                poi.que6 = [_currentFormData valueForKey:@"que6"];
                poi.que7 = [_currentFormData valueForKey:@"que7"];
                poi.que8 = [_currentFormData valueForKey:@"que8"];
                poi.que9 = [_currentFormData valueForKey:@"que9"];
                poi.que10 = [_currentFormData valueForKey:@"que10"];
                poi.que11 = [_currentFormData valueForKey:@"que11"];
                poi.que12 = [_currentFormData valueForKey:@"que12"];
                poi.que13 = [_currentFormData valueForKey:@"que13"];
                poi.que14 = [_currentFormData valueForKey:@"que14"];
                poi.que15 = [_currentFormData valueForKey:@"que15"];
                poi.que7 = [_currentFormData valueForKey:@"que16"];
                
                [product addPointsObject:poi];
            }
//            else if (self.smtag.pointType == POINT_SABRE)
//            {
//                Sabre * poi = [NSEntityDescription insertNewObjectForEntityForName:@"Sabre" inManagedObjectContext:context];
//                
//                poi.que1 = [_currentFormData valueForKey:@"que1"];
//                poi.que2 = [_currentFormData valueForKey:@"que2"];
//                poi.que3 = [_currentFormData valueForKey:@"que3"];
//                poi.que4 = [_currentFormData valueForKey:@"que4"];
//                poi.que5 = [_currentFormData valueForKey:@"que5"];
//                poi.que6 = [_currentFormData valueForKey:@"que6"];
//                poi.que7 = [_currentFormData valueForKey:@"que7"];
//                
//                [product addSabreObject:poi];
//            }
//            else if (self.smtag.pointType == POINT_FOIL)
//            {
//                Foil * poi = [NSEntityDescription insertNewObjectForEntityForName:@"Foil" inManagedObjectContext:context];
//                
//                poi.que1 = [_currentFormData valueForKey:@"que1"];
//                poi.que2 = [_currentFormData valueForKey:@"que2"];
//                poi.que3 = [_currentFormData valueForKey:@"que3"];
//                poi.que4 = [_currentFormData valueForKey:@"que4"];
//                poi.que5 = [_currentFormData valueForKey:@"que5"];
//                poi.que6 = [_currentFormData valueForKey:@"que6"];
//                poi.que7 = [_currentFormData valueForKey:@"que7"];
//                
//                [product addFoilObject:poi];
//            }
        }
        
 
    }
    
    
    NSError *error;
    if (![context save:&error]) {
         NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    if (_isUpdatingPoint)
    {
        
        if (self.smtag.pointType == POINT_EPEE || self.smtag.pointType == POINT_SABRE || self.smtag.pointType == POINT_FOIL)
        {
            NSArray * pointsArray = [[NSArray alloc] initWithArray:_smtag.points copyItems:YES] ;
            
            for (NSDictionary * point in pointsArray) {
                
                NSString * val = [point valueForKey:@"que1"];
                
                if ([val isEqualToString:[_currentFormData valueForKey:@"que1"]])
                {
                    [_smtag.points removeObject:point];
                    [_smtag.points addObject:_currentFormData];
                }
                
            }
        }
//        else if (self.smtag.pointType == POINT_SABRE)
//        {
//            NSArray * sabreArray = [[NSArray alloc] initWithArray:_smtag.sabrepoints copyItems:YES] ;
//            
//            for (NSDictionary * point in sabreArray) {
//                
//                NSString * val = [point valueForKey:@"que1"];
//                
//                if ([val isEqualToString:[_currentFormData valueForKey:@"que1"]])
//                {
//                    [_smtag.sabrepoints removeObject:point];
//                    [_smtag.sabrepoints addObject:_currentFormData];
//                }
//                
//            }
//            
//        }
//        else if (self.smtag.pointType == POINT_FOIL)
//        {
//            NSArray * foilArray = [[NSArray alloc] initWithArray:_smtag.foilpoints copyItems:YES] ;
//            
//            for (NSDictionary * point in foilArray) {
//                
//                NSString * val = [point valueForKey:@"que1"];
//                
//                if ([val isEqualToString:[_currentFormData valueForKey:@"que1"]])
//                {
//                    [_smtag.foilpoints removeObject:point];
//                    [_smtag.foilpoints addObject:_currentFormData];
//                }
//                
//            }
//        }
        
        
    }else
    {
        if (self.smtag.pointType == POINT_EPEE || self.smtag.pointType == POINT_FOIL || self.smtag.pointType == POINT_SABRE)
        {
            if (_smtag.points) {
                [_smtag.points addObject:_currentFormData];
            }
            else{
                _smtag.points = [[NSMutableArray alloc] init];
                [_smtag.points addObject:_currentFormData];
            }
        }
//        else if (self.smtag.pointType == POINT_SABRE)
//        {
//            if (_smtag.sabrepoints) {
//                [_smtag.sabrepoints addObject:_currentFormData];
//            }
//            else{
//                _smtag.sabrepoints = [[NSMutableArray alloc] init];
//                [_smtag.sabrepoints addObject:_currentFormData];
//            }
//        }
//        else if (self.smtag.pointType == POINT_FOIL)
//        {
//            if (_smtag.foilpoints) {
//                [_smtag.foilpoints addObject:_currentFormData];
//            }
//            else{
//                _smtag.foilpoints = [[NSMutableArray alloc] init];
//                [_smtag.foilpoints addObject:_currentFormData];
//            }
//        }
        
    }
 
}


- (BOOL)validatePointForm
{
    [self.pointByTxtFiled resignFirstResponder];
    
    // NONE
    [self.onActionTxtField resignFirstResponder];
    [self.executedActionByMeTextView resignFirstResponder];
    [self.sugesstedActionByMeTextView resignFirstResponder];
    [self.oponnentActionTextView resignFirstResponder];
    
    // ME
    [self.oponnentActionOtherTextView resignFirstResponder];
    [self.actionExecutionTextField resignFirstResponder];
    [self.otherCommentsTextView resignFirstResponder];
    
    // Competitor
    [self.oponnentActionOtherTextViewCompetitor resignFirstResponder];
    [self.myActionOtherTextViewCompetitor resignFirstResponder];
    [self.myActionsTextField resignFirstResponder];
    [self.otherCommentsAbtMETextView resignFirstResponder];
    

    
    if ([self.pointByTxtFiled.text isEqualToString:@""])
    {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Point by value can not be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return YES;
    }
    
   
    
    return NO;
    
    
}

- (void)collectData
{
    [_currentFormData setValue:self.navItem.title forKey:@"que1"];
    [_currentFormData setValue:self.pointByTxtFiled.text forKey:@"que2"];
    
    if ([self.pointByTxtFiled.text isEqualToString:@"Me"])
    {
        // My Action : Multiple choice
        NSString * str = nil;
        if (self.sportsGroupmyActionExecution.checkedCheckBoxes.count > 0)
        {
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            for (TNRectangularCheckBoxData * data in self.sportsGroupmyActionExecution.checkedCheckBoxes)
            {
                [tempArray addObject:[NSString stringWithFormat:@"%@",data.identifier]];
            }
            
            str = [tempArray componentsJoinedByString:@","];
            
        }
        else{
            str = @"";
        }
        [_currentFormData setValue:str forKey:@"que3"];
        
        // My Action : Other Comment
        [_currentFormData setValue:self.oponnentActionOtherTextView.text forKey:@"que4"];
        
        // My Action Execution: Single selection
        [_currentFormData setValue:self.actionExecutionTextField.text forKey:@"que5"];

        // Other Comment: Free Text
        [_currentFormData setValue:self.otherCommentsTextView.text forKey:@"que6"];
        
        
    }
    else if ([self.pointByTxtFiled.text isEqualToString:@"Competitor"])
    {
        
        // Opponent Action  : Multiple choice
        NSString * str = nil;
        if (self.sportsGroupOpp.checkedCheckBoxes.count > 0)
        {
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            for (TNRectangularCheckBoxData * data in self.sportsGroupOpp.checkedCheckBoxes)
            {
                [tempArray addObject:[NSString stringWithFormat:@"%@",data.identifier]];
            }
            
            str = [tempArray componentsJoinedByString:@","];
            
        }
        else{
            str = @"";
        }
        [_currentFormData setValue:str forKey:@"que7"];
        
        // Opponent Action : Other Comment
        [_currentFormData setValue:self.oponnentActionOtherTextViewCompetitor.text forKey:@"que8"];
        

        // MY Action  : Multiple choice
        str = @"";
        if (self.sportsGroupMyAction.checkedCheckBoxes.count > 0)
        {
            NSMutableArray * tempArray = [[NSMutableArray alloc] init];
            for (TNRectangularCheckBoxData * data in self.sportsGroupMyAction.checkedCheckBoxes)
            {
                [tempArray addObject:[NSString stringWithFormat:@"%@",data.identifier]];
            }
            
            str = [tempArray componentsJoinedByString:@","];
            
        }
        else{
            str = @"";
        }
        [_currentFormData setValue:str forKey:@"que9"];
        
        // My Action : Other Comment
        [_currentFormData setValue:self.myActionOtherTextViewCompetitor.text forKey:@"que10"];
        
        
        // My Action Execution: Single selection
        [_currentFormData setValue:self.myActionsTextField.text forKey:@"que11"];
        
        // Other Comment: Free Text
        [_currentFormData setValue:self.otherCommentsAbtMETextView.text forKey:@"que12"];
        
        
    }
    else if ([self.pointByTxtFiled.text isEqualToString:@"None"])
    {
        
        // On What Action   : Single selection
        [_currentFormData setValue:self.onActionTxtField.text forKey:@"que13"];
        
        
        // Executed Action By me (Free Text)
        [_currentFormData setValue:self.executedActionByMeTextView.text forKey:@"que14"];
        
        // Suggested Action for me (Free Text)
        [_currentFormData setValue:self.sugesstedActionByMeTextView.text forKey:@"que15"];
        
        // Other Acion (Free Text)
        [_currentFormData setValue:self.oponnentActionTextView.text forKey:@"que16"];
        
    }


}


- (void)saveFormValue
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    [self collectData];
    
    [self saveCurrentPoint];
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSString * msg = @"Point Saved Successfully";
        
        if (_isUpdatingPoint) {
            msg = @"Point Updated Successfully";
        }
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];

        
    }];

}

#pragma mark - MainViewDelegate

- (IBAction)doneButtonAction
{
   
    BOOL shouldReturn =  [self validatePointForm];
    
    if (shouldReturn) {
        return;
    }
    
    if (_isUpdatingPoint) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"You want to update point info" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
            [self saveFormValue];
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Other action
            NSLog(@"Updating canceled");
        }];
        [alert addAction:otherAction];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        [self saveFormValue];
    }
 
    
}

- (IBAction)cancelButtonAction
{
    [self dissmissVC];
}

- (void)dissmissVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadView {
 //   CGRect bounds = [UIScreen mainScreen].bounds;
    
  //  self.view = [[MainView alloc] initWithFrame:bounds];
   // self.view.delegate = self;
    [super loadView];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addActionName];
}

- (void)addActionName
{
    
    if (_isUpdatingPoint) {
        self.navItem.title = [NSString stringWithFormat:@"%@",_selectedAction];
        return;
    }
    
    
    if(_smtag.points.count > 0 || _smtag.sabrepoints.count > 0 || _smtag.foilpoints.count > 0)
    {
        
        NSMutableArray * tmpOBJ = [[NSMutableArray alloc] init];
        
        
        if (_smtag.pointType == POINT_SABRE || _smtag.pointType == POINT_FOIL || _smtag.pointType == POINT_EPEE) {
            for (NSDictionary * dict in _smtag.points)
            {
                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
            }
        }
//        else if (_smtag.pointType == POINT_FOIL)
//        {
//            for (NSDictionary * dict in _smtag.foilpoints)
//            {
//                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
//            }
//        }
//        else if (_smtag.pointType == POINT_EPEE)
//        {
//            for (NSDictionary * dict in _smtag.points)
//            {
//                [tmpOBJ addObject:[dict valueForKey:@"que1"]];
//            }
//        }
        
       
        NSString * name = [tmpOBJ lastObject];
        NSArray * components = [name componentsSeparatedByString:@" "];
        
        NSString * finString = [components lastObject];
        
        NSInteger myInt = [finString intValue];
        
        self.navItem.title = [NSString stringWithFormat:@"Action %lu",(unsigned long)myInt+1];
    }
    else{
        self.navItem.title = @"Action 1";
    }

}


- (void)setIsUpdatingPointDataOnUI
{
    
    if (_currentFormData && _isUpdatingPoint)
    {
        self.navItem.title = [_currentFormData valueForKey:@"que1"];
        self.pointByTxtFiled.text = [_currentFormData valueForKey:@"que2"];
//        self.onActionTxtField.text = [_currentFormData valueForKey:@"que3"];
//        self.aboutMeTextView.text = [_currentFormData valueForKey:@"que6"];
//        self.aboutCompetitorTextView.text = [_currentFormData valueForKey:@"que7"];
        
        
        [self.opponentViewEPEE setHidden:YES];
        [self.meViewEPEE setHidden:YES];
        [self.noneViewEPEE setHidden:YES];
        
        [self.noneViewFoil setHidden:YES];
        [self.meViewFoil setHidden:YES];
        [self.opponentViewFoil setHidden:YES];
        
        [self.opponentViewSabre setHidden:YES];
        [self.meViewSabre setHidden:YES];
        [self.noneViewSabre setHidden:YES];
        
        
        
        if (_smtag.pointType == POINT_EPEE)
        {
            if ([self.pointByTxtFiled.text isEqualToString:@"Competitor"])
            {
                [self.opponentViewEPEE setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"None"])
            {
                [self.noneViewEPEE setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"Me"])
            {
                [self.meViewEPEE setHidden:NO];
            }
            
            
        }
        else if (_smtag.pointType == POINT_FOIL)
        {
            if ([self.pointByTxtFiled.text isEqualToString:@"Competitor"])
            {
                [self.opponentViewFoil setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"None"])
            {
                [self.noneViewFoil setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"Me"])
            {
                [self.meViewFoil setHidden:NO];
            }
            
        }
        else if (_smtag.pointType == POINT_SABRE)
        {
            if ([self.pointByTxtFiled.text isEqualToString:@"Competitor"])
            {
                [self.opponentViewSabre setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"None"])
            {
                [self.noneViewSabre setHidden:NO];
                
            }
            else if ([self.pointByTxtFiled.text isEqualToString:@"Me"])
            {
                [self.meViewSabre setHidden:NO];
            }
            
        }

        

    }
}

- (void)initEPEEData
{
    
    // Competitor  // to be used for competitor and ME & MYAction FOR ME
    oponentActionArray = [[NSArray alloc] initWithObjects:@"Parry Reposte",@"Counter Attack",@"Compound Attack",@"Straight Attack",@"Fient Attack",@"Beat Attack",@"Distance parry",@"Simple Attack",@"Fleche",@"Disengage/Engage", nil];
    
    // Choices: Oponent
    myActionArray = [[NSArray alloc] initWithObjects:@"Correct",@"InCorrect", nil];
    
    // MY Action Execution :  ME
    myActionExecutionArray = [[NSArray alloc] initWithObjects:@"Good",@"Poor", nil];
    
    
    // Action Type :  NO
    actionTypeArray = [[NSArray alloc] initWithObjects:@"Simultaneous",@"Off Target", nil];
    
}



- (void)addRadioButtonForEPEECompetitor
{
   
    //sportsGroupOpp
    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator1 toView:_opponentViewEPEE withTag:111];
    //sportsGroupMyAction
    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator2 toView:_opponentViewEPEE withTag:222];
    
    //sportsGroupmyActionExecution
    [self createAttacByMeGroupForArrayFoView:_meViewEPEESeprator1 toView:_meViewEPEE withTag:333];

    
}

//@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupOpp;
//@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupMyAction;
//@property (nonatomic, strong) TNCheckBoxGroup *sportsGroupmyActionExecution;

- (void)createAttacByMeGroupForArrayFoView:(UIView *)view toView:(UIView *)containerView withTag:(NSInteger)tag {
    
    
    NSArray * nameArr = [[NSArray alloc] initWithArray:oponentActionArray];
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < nameArr.count; i++) {
        
        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
        [tennisData setLabelColor:[UIColor whiteColor]];
        tennisData.identifier = [nameArr objectAtIndex:i];
        tennisData.labelText = [nameArr objectAtIndex:i];
        tennisData.borderColor = [UIColor whiteColor];
        tennisData.rectangleColor = [UIColor whiteColor];
        tennisData.borderWidth = tennisData.borderHeight = 17;
        tennisData.rectangleWidth = tennisData.rectangleHeight = 12;
        
        [arr addObject:tennisData];
    }
    
    if (tag == 111)
    {
        self.sportsGroupOpp = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
        
        if (IS_IPAD) {
            self.sportsGroupOpp.rowItemCount = 3;
            
        }
        else
        {
            self.sportsGroupOpp.rowItemCount = 2;
        }
        
        self.sportsGroupOpp.tag = tag;
        
        [self.sportsGroupOpp create];
        
        
        CGRect frame = view.frame;
        self.sportsGroupOpp.position = CGPointMake(frame.origin.x, frame.origin.y);
        [containerView addSubview:self.sportsGroupOpp];
        [containerView sendSubviewToBack:self.sportsGroupOpp];

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupOpp];

    }
    
    if (tag == 222)
    {
        self.sportsGroupMyAction = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
        
        if (IS_IPAD) {
            self.sportsGroupMyAction.rowItemCount = 3;
            
        }
        else
        {
            self.sportsGroupMyAction.rowItemCount = 2;
        }
        
        self.sportsGroupMyAction.tag = tag;
        
        [self.sportsGroupMyAction create];
        
        
        CGRect frame = view.frame;
        self.sportsGroupMyAction.position = CGPointMake(frame.origin.x, frame.origin.y);
        [containerView addSubview:self.sportsGroupMyAction];
        
        [containerView sendSubviewToBack:self.sportsGroupMyAction];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupMyAction];

    }

    
    if (tag == 333)
    {
        self.sportsGroupmyActionExecution = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
        
        if (IS_IPAD) {
            self.sportsGroupmyActionExecution.rowItemCount = 3;
            
        }
        else
        {
            self.sportsGroupmyActionExecution.rowItemCount = 2;
        }
        
        self.sportsGroupmyActionExecution.tag = tag;
        
        [self.sportsGroupmyActionExecution create];
        
        
        CGRect frame = view.frame;
        self.sportsGroupmyActionExecution.position = CGPointMake(frame.origin.x, frame.origin.y);
        [containerView addSubview:self.sportsGroupmyActionExecution];
        
        [containerView sendSubviewToBack:self.sportsGroupmyActionExecution];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupmyActionExecution];
  
    }

    
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_currentFormData == nil) {
        _currentFormData = [[NSMutableDictionary alloc] init];
    }
    
    
    [self addActionName];
    
    
    pointByArray = [[NSArray alloc] initWithObjects:@"Me",@"Competitor",@"None", nil];
    
    actionArray = [[NSArray alloc] initWithObjects:@"Parry Reposte",@"Counter Attack",@"Straight Attack",@"Fient Attack",@"Beat Attack",@"Distance parry",@"Attack in prep", nil];
    
    
    
    CGRect bounds = [UIScreen mainScreen].bounds;

    if (IS_IPAD) {
        self.statusBarHeightConstraint.constant = 0;
    }
    
    
    float width = bounds.size.width;
   
    if (IS_IPAD) {
        width = 540;
    }
    else
    {
//        CGRect Frame = self.sel2View.frame;
//        Frame.origin.y +=15;
//        self.sel2View.frame = Frame;
    }
    
    
    if (_isUpdatingPoint)
    {
        [self.saveButton setTitle:@"UPDATE" forState:UIControlStateNormal];
        
        self.navItem.title = [_currentFormData valueForKey:@"que1"];
        self.pointByTxtFiled.text = [_currentFormData valueForKey:@"que2"];
        
        if ([self.pointByTxtFiled.text isEqualToString:@"Competitor"])
        {
            [self.opponentViewEPEE setHidden:NO];
            
        }
        else if ([self.pointByTxtFiled.text isEqualToString:@"None"])
        {
            [self.noneViewEPEE setHidden:NO];
            
        }
        else if ([self.pointByTxtFiled.text isEqualToString:@"Me"])
        {
            [self.meViewEPEE setHidden:NO];
        }

        [self initEPEEData];

        
        [self createMEFormGroup];
        [self createOpponentFormGroup1];
        [self createOpponentFormGroup2];
        [self populateNoneFields];

        
      //  [self setIsUpdatingPointDataOnUI];
//        [self createSportsGroupUpdating];
//        [self createNoGroupUpdating];
    }
    else
    {
        
        // EPEE DATA INTIALIZE
//        if (_smtag.pointType == POINT_EPEE)
//        {
            [self initEPEEData];
            
            // Competitor
            [self addRadioButtonForEPEECompetitor];
//        }
        
        // FOIL DATA INTIALIZE
        
        // SABRE DATA INTIALIZE
        
        // [self createFruitsGroup];
//        [self createSportsGroup];
//        [self createNoGroup];
        
    }
  

}



-(void) presentPointsByPicker
{
    
    // Create the picker
    self.picker = [GKActionSheetPicker stringPickerWithItems:pointByArray selectCallback:^(id selected) {
        // This code will be called when the user taps the "OK" button
        
        [self.opponentViewEPEE setHidden:YES];
        [self.meViewEPEE setHidden:YES];
        [self.noneViewEPEE setHidden:YES];
        
        [self.noneViewFoil setHidden:YES];
        [self.meViewFoil setHidden:YES];
        [self.opponentViewFoil setHidden:YES];
        
        [self.opponentViewSabre setHidden:YES];
        [self.meViewSabre setHidden:YES];
        [self.noneViewSabre setHidden:YES];

        
        [_pointByTxtFiled setText:(NSString *)selected];
        
        if (_smtag.pointType == POINT_EPEE || _smtag.pointType == POINT_FOIL || _smtag.pointType == POINT_SABRE)
        {
            if ([selected isEqualToString:@"Competitor"])
            {
                [self.opponentViewEPEE setHidden:NO];
                self.containerViewHeightConstraint.constant = 813;
                
            }
            else if ([selected isEqualToString:@"None"])
            {
                [self.noneViewEPEE setHidden:NO];
                self.containerViewHeightConstraint.constant = 637;

                
            }
            else if ([selected isEqualToString:@"Me"])
            {
                [self.meViewEPEE setHidden:NO];
                self.containerViewHeightConstraint.constant = 637+30;

            }

            
        }
//        else if (_smtag.pointType == POINT_FOIL)
//        {
//            if ([selected isEqualToString:@"Competitor"])
//            {
//                [self.opponentViewFoil setHidden:NO];
//                
//            }
//            else if ([selected isEqualToString:@"None"])
//            {
//                [self.noneViewFoil setHidden:NO];
//                
//            }
//            else if ([selected isEqualToString:@"Me"])
//            {
//                [self.meViewFoil setHidden:NO];
//            }
//
//        }
//        else if (_smtag.pointType == POINT_SABRE)
//        {
//            if ([selected isEqualToString:@"Competitor"])
//            {
//                [self.opponentViewSabre setHidden:NO];
//                
//            }
//            else if ([selected isEqualToString:@"None"])
//            {
//                [self.noneViewSabre setHidden:NO];
//                
//            }
//            else if ([selected isEqualToString:@"Me"])
//            {
//                [self.meViewSabre setHidden:NO];
//            }
//            
//        }
        
    } cancelCallback:^{
    }];
    
    
    // Present it
    [self.picker presentPickerOnView:self.view];

}


-(void) presentActionsByPicker
{
    
    // Create the picker
    self.picker = [GKActionSheetPicker stringPickerWithItems:actionTypeArray selectCallback:^(id selected) {
        // This code will be called when the user taps the "OK" button
        [_onActionTxtField setText:(NSString *)selected];
        
    } cancelCallback:^{
    }];
    

    
    // Present it
    [self.picker presentPickerOnView:self.view];
    
}

#pragma mark - UITextFiledDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    [textField resignFirstResponder];

    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField{
    [textField resignFirstResponder];
    
    // [self.picker dismissPickerView];
    
    
    shouldShowPicker = YES;
    
    return YES;
}


//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//    if (shouldShowPicker) {
//        
//        shouldShowPicker = false;
//        
//    }
//    
//    
//
//    
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (shouldShowPicker) {
        
        shouldShowPicker = false;
        
        return NO;
    }
    
    [self.pointByTxtFiled resignFirstResponder];
    
    // NONE
    [self.onActionTxtField resignFirstResponder];
    [self.executedActionByMeTextView resignFirstResponder];
    [self.sugesstedActionByMeTextView resignFirstResponder];
    [self.oponnentActionTextView resignFirstResponder];
    
    // ME
    //[self.oponnentActionOtherTextView resignFirstResponder];
    if(textField == self.oponnentActionOtherTextView)
    {
        return YES;
    }
    
    [self.actionExecutionTextField resignFirstResponder];
    [self.otherCommentsTextView resignFirstResponder];
    
    // Competitor
    
    if(textField == self.oponnentActionOtherTextViewCompetitor || textField == self.myActionOtherTextViewCompetitor)
    {
        return YES;
    }
//    [self.oponnentActionOtherTextViewCompetitor resignFirstResponder];
//    [self.myActionOtherTextViewCompetitor resignFirstResponder];
    [self.myActionsTextField resignFirstResponder];
    [self.otherCommentsAbtMETextView resignFirstResponder];
    
    if(textField == self.pointByTxtFiled)
    {
       

        
        //if(!datePicker)
        [self presentPointsByPicker];
        // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
    }
    
    if(textField == self.onActionTxtField)
    {

        
        [self presentActionsByPicker];
        // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
    }
    
    // ME
    

    if(textField == self.actionExecutionTextField)
    {
        
        
        [self presentActionsByPickerForTextFiled:self.actionExecutionTextField withArray:myActionExecutionArray];
        // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
    }
    
    // Opponent

    
    if(textField == self.myActionsTextField)
    {
        
        [self presentActionsByPickerForTextFiled:self.myActionsTextField withArray:myActionArray];
        // [self.mainContainerScrollView showDatePickerForTextField:textField andKeyboardRect:datePicker.frame];
    }


    
    
    return NO;
}

-(void) presentActionsByPickerForTextFiled:(UITextField *)txtFiled withArray:(NSArray *)arr
{
    
    // Create the picker
    self.picker = [GKActionSheetPicker stringPickerWithItems:arr selectCallback:^(id selected) {
        // This code will be called when the user taps the "OK" button
        [txtFiled setText:(NSString *)selected];
        
    } cancelCallback:^{
    }];
    
    
    
    // Present it
    [self.picker presentPickerOnView:self.view];
    
}





#pragma mark - UITextViewDelegate




- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"textView : Text Length: %lu",(unsigned long)textView.text.length);
    return textView.text.length + (text.length - range.length) <= 120;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    CGRect frame = self.containerView.frame;
//    frame.size.height += 900;
//    self.containerView.frame = frame;
    
    self.containerViewHeightConstraint.constant +=100;
    [self.containerView setNeedsUpdateConstraints];
    
    
    self.scrollView.contentSize = CGSizeMake(self.containerView.frame.size.width, self.containerView.frame.size.height + 150);

}




#pragma mark - Editing Point
//self.sportsGroupOpp
//self.sportsGroupMyAction
//sportsGroupmyActionExecution

- (void)createMEFormGroup
{
//    //sportsGroupOpp
//    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator1 toView:_opponentViewEPEE withTag:111];
//    //sportsGroupMyAction
//    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator2 toView:_opponentViewEPEE withTag:222];
//    
//    //sportsGroupmyActionExecution
//    [self createAttacByMeGroupForArrayFoView:_meViewEPEESeprator1 toView:_meViewEPEE withTag:333];

    
    NSString * myAttack = [_currentFormData valueForKey:@"que3"];
    
    NSArray * components = nil;
    if (![myAttack isEqualToString:@""])
    {
        components = [myAttack componentsSeparatedByString:@","];
    }
    else
    {
        components = [[NSArray alloc] init];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];

    
    for (int i = 0; i < oponentActionArray.count; i++)
    {
        
        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
        [tennisData setLabelColor:[UIColor whiteColor]];
        
        switch (i) {
            case 0:
                
                if ([components containsObject:@"Parry Reposte"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 1:
                if ([components containsObject:@"Counter Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 2:
                if ([components containsObject:@"Compound Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 3:
                if ([components containsObject:@"Straight Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
            
            case 4:
                if ([components containsObject:@"Fient Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 5:
                if ([components containsObject:@"Beat Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 6:
                if ([components containsObject:@"Distance Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 7:
                if ([components containsObject:@"Simple Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 8:
                if ([components containsObject:@"Fleche"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 9:
                if ([components containsObject:@"Disengage/Engage"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 10:
                if ([components containsObject:@"Defense"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            default:
                break;
        }
        
        tennisData.identifier = [oponentActionArray objectAtIndex:i];
        tennisData.labelText = [oponentActionArray objectAtIndex:i];
        tennisData.borderColor = [UIColor whiteColor];
        tennisData.rectangleColor = [UIColor whiteColor];
        tennisData.borderWidth = tennisData.borderHeight = 17;
        tennisData.rectangleWidth = tennisData.rectangleHeight = 12;
        
        
        [arr addObject:tennisData];
    }

  
    self.sportsGroupmyActionExecution = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];


        if (IS_IPAD) {
            self.sportsGroupmyActionExecution.rowItemCount = 3;
            
        }
        else
        {
            self.sportsGroupmyActionExecution.rowItemCount = 2;
        }
        
    
        [self.sportsGroupmyActionExecution create];
        
        
        CGRect frame = _meViewEPEESeprator1.frame;
        self.sportsGroupmyActionExecution.position = CGPointMake(frame.origin.x, frame.origin.y);
    
    CGRect rectnew =   self.sportsGroupmyActionExecution.frame;
    rectnew.size.height -= self.oponnentActionOtherTextView.frame.size.height;
    
        [_meViewEPEE addSubview:self.sportsGroupmyActionExecution];
    [_meViewEPEE sendSubviewToBack:self.sportsGroupmyActionExecution];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupmyActionExecution];
    
    // My Action : Other Comment
    NSString * otherVal = [_currentFormData valueForKey:@"que4"];

    
    if ([otherVal isEqualToString:@""])
    {
        [self.oponnentActionOtherTextView setText:@""];
//        [_meViewEPEE bringSubviewToFront:_oponnentActionOtherTextView];
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_oponnentActionOtherTextView];

    }
    else
    {
        [self.oponnentActionOtherTextView setText:otherVal];
    }
    
    
            self.actionExecutionTextField.text = [_currentFormData valueForKey:@"que5"];
            self.otherCommentsTextView.text = [_currentFormData valueForKey:@"que6"];
    

}


- (void)createOpponentFormGroup1
{
    //    //sportsGroupOpp
    //    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator1 toView:_opponentViewEPEE withTag:111];
    //    //sportsGroupMyAction
    //    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator2 toView:_opponentViewEPEE withTag:222];
    //
    //    //sportsGroupmyActionExecution
    //    [self createAttacByMeGroupForArrayFoView:_meViewEPEESeprator1 toView:_meViewEPEE withTag:333];
    
    NSString * myAttack = [_currentFormData valueForKey:@"que7"];
    
    NSArray * components = nil;
    if (![myAttack isEqualToString:@""])
    {
        components = [myAttack componentsSeparatedByString:@","];
    }
    else
    {
        components = [[NSArray alloc] init];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < oponentActionArray.count; i++)
    {
        
        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
        [tennisData setLabelColor:[UIColor whiteColor]];
        
        switch (i) {
            case 0:
                
                if ([components containsObject:@"Parry Reposte"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 1:
                if ([components containsObject:@"Counter Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 2:
                if ([components containsObject:@"Compound Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 3:
                if ([components containsObject:@"Straight Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 4:
                if ([components containsObject:@"Fient Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 5:
                if ([components containsObject:@"Beat Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 6:
                if ([components containsObject:@"Distance Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 7:
                if ([components containsObject:@"Simple Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 8:
                if ([components containsObject:@"Fleche"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 9:
                if ([components containsObject:@"Disengage/Engage"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 10:
                if ([components containsObject:@"Defense"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            default:
                break;
        }
        
        tennisData.identifier = [oponentActionArray objectAtIndex:i];
        tennisData.labelText = [oponentActionArray objectAtIndex:i];
        tennisData.borderColor = [UIColor whiteColor];
        tennisData.rectangleColor = [UIColor whiteColor];
        tennisData.borderWidth = tennisData.borderHeight = 20;
        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
        
        
        [arr addObject:tennisData];
    }
    
    
    self.sportsGroupOpp = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
    
    
    if (IS_IPAD) {
        self.sportsGroupOpp.rowItemCount = 3;
        
    }
    else
    {
        self.sportsGroupOpp.rowItemCount = 2;
    }
    
    
    [self.sportsGroupOpp create];
    
    
    CGRect frame = _opponentViewEPEESeprator1.frame;
    self.sportsGroupOpp.position = CGPointMake(frame.origin.x, frame.origin.y);
    [_opponentViewEPEE addSubview:self.sportsGroupOpp];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupOpp];
    
    // My Action : Other Comment
    NSString * otherVal = [_currentFormData valueForKey:@"que8"];
    
    if ([otherVal isEqualToString:@""])
    {
        [self.oponnentActionOtherTextViewCompetitor setText:@""];
    }
    else
    {
        [self.oponnentActionOtherTextViewCompetitor setText:otherVal];
    }
    
    
}

- (void)createOpponentFormGroup2
{
    //    //sportsGroupOpp
    //    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator1 toView:_opponentViewEPEE withTag:111];
    //    //sportsGroupMyAction
    //    [self createAttacByMeGroupForArrayFoView:_opponentViewEPEESeprator2 toView:_opponentViewEPEE withTag:222];
    //
    //    //sportsGroupmyActionExecution
    //    [self createAttacByMeGroupForArrayFoView:_meViewEPEESeprator1 toView:_meViewEPEE withTag:333];
    
    NSString * myAttack = [_currentFormData valueForKey:@"que9"];
    
    NSArray * components = nil;
    if (![myAttack isEqualToString:@""])
    {
        components = [myAttack componentsSeparatedByString:@","];
    }
    else
    {
        components = [[NSArray alloc] init];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < oponentActionArray.count; i++)
    {
        
        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
        [tennisData setLabelColor:[UIColor whiteColor]];
        
        switch (i) {
            case 0:
                
                if ([components containsObject:@"Parry Reposte"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 1:
                if ([components containsObject:@"Counter Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 2:
                if ([components containsObject:@"Compound Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 3:
                if ([components containsObject:@"Straight Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 4:
                if ([components containsObject:@"Fient Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 5:
                if ([components containsObject:@"Beat Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 6:
                if ([components containsObject:@"Distance Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 7:
                if ([components containsObject:@"Simple Attack"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 8:
                if ([components containsObject:@"Fleche"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 9:
                if ([components containsObject:@"Disengage/Engage"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            case 10:
                if ([components containsObject:@"Defense"]) {
                    [tennisData setChecked:YES];
                }
                
                break;
                
            default:
                break;
        }
        
        tennisData.identifier = [oponentActionArray objectAtIndex:i];
        tennisData.labelText = [oponentActionArray objectAtIndex:i];
        tennisData.borderColor = [UIColor whiteColor];
        tennisData.rectangleColor = [UIColor whiteColor];
        tennisData.borderWidth = tennisData.borderHeight = 20;
        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
        
        
        [arr addObject:tennisData];
    }
    
    
    self.sportsGroupMyAction = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
    
    
    if (IS_IPAD) {
        self.sportsGroupMyAction.rowItemCount = 3;
        
    }
    else
    {
        self.sportsGroupMyAction.rowItemCount = 2;
    }
    
    
    [self.sportsGroupMyAction create];
    
    
    CGRect frame = _opponentViewEPEESeprator2.frame;
    self.sportsGroupMyAction.position = CGPointMake(frame.origin.x, frame.origin.y);
    [_opponentViewEPEE addSubview:self.sportsGroupMyAction];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroupMyAction];
    
    // My Action : Other Comment
    NSString * otherVal = [_currentFormData valueForKey:@"que10"];
    
    if ([otherVal isEqualToString:@""])
    {
        [self.myActionOtherTextViewCompetitor setText:@""];
    }
    else
    {
        [self.myActionOtherTextViewCompetitor setText:otherVal];
    }
    
    
    self.myActionsTextField.text = [_currentFormData valueForKey:@"que11"];
    self.otherCommentsAbtMETextView.text = [_currentFormData valueForKey:@"que12"];
    
}

- (void)populateNoneFields
{
    self.onActionTxtField.text = [_currentFormData valueForKey:@"que13"];
    self.executedActionByMeTextView.text = [_currentFormData valueForKey:@"que14"];
    self.sugesstedActionByMeTextView.text = [_currentFormData valueForKey:@"que15"];
    self.oponnentActionTextView.text = [_currentFormData valueForKey:@"que16"];
}



#pragma mark - POINT UPDATING

- (void)createSportsGroupUpdating {
    
    
//    NSArray * nameArr = [[NSArray alloc] initWithObjects:@"Long attack   ",@"Short attack",@"Fast attack    ",@"Slow attack", nil];
//    
//    NSString * myAttack = [_currentFormData valueForKey:@"que4"];
//    
//    NSArray * components = nil;
//    if (![myAttack isEqualToString:@""])
//    {
//        components = [myAttack componentsSeparatedByString:@","];
//    }
//    else
//    {
//        components = [[NSArray alloc] init];
//    }
//
//    NSMutableArray * arr = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < nameArr.count; i++)
//    {
//        
//        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
//        [tennisData setLabelColor:[UIColor whiteColor]];
//        
//        switch (i) {
//            case 0:
//                
//                if ([components containsObject:@"Longattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 1:
//                if ([components containsObject:@"Shortattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 2:
//                if ([components containsObject:@"Fastattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 3:
//                if ([components containsObject:@"Slowattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            default:
//                break;
//        }
//        
//        
//        tennisData.identifier = [nameArr objectAtIndex:i];
//        tennisData.labelText = [nameArr objectAtIndex:i];
//        tennisData.borderColor = [UIColor whiteColor];
//        tennisData.rectangleColor = [UIColor whiteColor];
//        tennisData.borderWidth = tennisData.borderHeight = 20;
//        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
//        
//        
//        [arr addObject:tennisData];
//    }
//    
//    
//    self.sportsGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
//    self.sportsGroup.rowItemCount = 2;
//    self.sportsGroup.tag = 2;
//    
//    [self.sportsGroup create];
//    
//    
//    CGRect frame = self.sel2View.frame;
//    self.sportsGroup.position = CGPointMake(frame.origin.x, frame.origin.y);
//    [self.containerView addSubview:self.sportsGroup];
//    
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroup];
//    
}

- (void)createNoGroupUpdating {
    
//    NSArray * nameArr = [[NSArray alloc] initWithObjects:@"Long attack   ",@"Short attack",@"Fast attack    ",@"Slow attack", nil];
//    
//    NSString * myAttack = [_currentFormData valueForKey:@"que5"];
//    
//    NSArray * components = nil;
//    if (![myAttack isEqualToString:@""])
//    {
//        components = [myAttack componentsSeparatedByString:@","];
//    }
//    else
//    {
//        components = [[NSArray alloc] init];
//    }
//    
//    
//    NSMutableArray * arr = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < nameArr.count; i++) {
//        
//        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
//        [tennisData setLabelColor:[UIColor whiteColor]];
//        
//        switch (i) {
//            case 0:
//                
//                if ([components containsObject:@"Longattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 1:
//                if ([components containsObject:@"Shortattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 2:
//                if ([components containsObject:@"Fastattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            case 3:
//                if ([components containsObject:@"Slowattack"]) {
//                    [tennisData setChecked:YES];
//                }
//                
//                break;
//                
//            default:
//                break;
//        }
//        
//        
//        tennisData.identifier = [nameArr objectAtIndex:i];
//        tennisData.labelText = [nameArr objectAtIndex:i];
//        tennisData.borderColor = [UIColor whiteColor];
//        tennisData.rectangleColor = [UIColor whiteColor];
//        tennisData.borderWidth = tennisData.borderHeight = 20;
//        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
//        
//        [arr addObject:tennisData];
//    }
//    
//    
//    self.noGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
//    self.noGroup.rowItemCount = 2;
//    self.noGroup.tag = 2;
//    
//    self.noGroup.identifier = @"No Group";
//    [self.noGroup create];
//    CGRect frame = self.sel3View.frame;
//    self.noGroup.position = CGPointMake(frame.origin.x, frame.origin.y);
//    
//    [self.containerView addSubview:self.noGroup];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noGroupChanged:) name:GROUP_CHANGED object:self.noGroup];
}




#pragma mark -- RADIO AND CHECK BOX

- (void)createFruitsGroup {
//    TNCircularCheckBoxData *bananaData = [[TNCircularCheckBoxData alloc] init];
//    [bananaData setLabelColor:[UIColor whiteColor]];
//    bananaData.identifier = @"Me";
//    bananaData.labelText = @"Me";
//    bananaData.borderColor = [UIColor whiteColor];
//    bananaData.circleColor = [UIColor whiteColor];
//    bananaData.borderRadius = 20;
//    bananaData.circleRadius = 15;
//    
//    TNCircularCheckBoxData *strawberryData = [[TNCircularCheckBoxData alloc] init];
//    [strawberryData setLabelColor:[UIColor whiteColor]];
//    strawberryData.identifier = @"Competitor";
//    strawberryData.labelText = @"Competitor";
//    strawberryData.borderColor = [UIColor whiteColor];
//    strawberryData.circleColor = [UIColor whiteColor];
//    strawberryData.borderRadius = 20;
//    strawberryData.circleRadius = 15;
//    
//    TNCircularCheckBoxData *cherryData = [[TNCircularCheckBoxData alloc] init];
//    [cherryData setLabelColor:[UIColor whiteColor]];
//    cherryData.identifier = @"None";
//    cherryData.labelText = @"None";
//    cherryData.borderColor = [UIColor whiteColor];
//    cherryData.circleColor = [UIColor whiteColor];
//    cherryData.borderRadius = 20;
//    cherryData.circleRadius = 15;
//    
//    
//    self.fruitGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:@[bananaData, strawberryData, cherryData] style:TNCheckBoxLayoutHorizontal];
//    
//    self.fruitGroup.rowItemCount = 3;
//    [self.fruitGroup create];
//    
//    
//    
//    CGRect frame = self.sel1View.frame;
//    
//    
//    self.fruitGroup.position = CGPointMake(frame.origin.x, frame.origin.y);
//    
//    [self.containerView addSubview:self.fruitGroup];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fruitGroupChanged:) name:GROUP_CHANGED object:self.fruitGroup];
}

- (void)createSportsGroup {
    
//    
//    NSArray * nameArr = [[NSArray alloc] initWithObjects:@"Long attack   ",@"Short attack",@"Fast attack    ",@"Slow attack", nil];
//
//    NSMutableArray * arr = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < nameArr.count; i++) {
//    
//        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
//        [tennisData setLabelColor:[UIColor whiteColor]];
//        tennisData.identifier = [nameArr objectAtIndex:i];
//        tennisData.labelText = [nameArr objectAtIndex:i];
//        tennisData.borderColor = [UIColor whiteColor];
//        tennisData.rectangleColor = [UIColor whiteColor];
//        tennisData.borderWidth = tennisData.borderHeight = 20;
//        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
//        
//        
//        [arr addObject:tennisData];
//    }
//    
//    
//    self.sportsGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
//    self.sportsGroup.rowItemCount = 2;
//    self.sportsGroup.tag = 2;
//
//    [self.sportsGroup create];
//    
//    
//    CGRect frame = self.sel2View.frame;
//    self.sportsGroup.position = CGPointMake(frame.origin.x, frame.origin.y);
//    [self.containerView addSubview:self.sportsGroup];
//
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sportsGroupChanged:) name:GROUP_CHANGED object:self.sportsGroup];
    
}

- (void)createLoveGroup {
    
    TNImageCheckBoxData *manData = [[TNImageCheckBoxData alloc] init];
    manData.identifier = @"man";
    manData.labelText = @"Man";
    manData.checkedImage = [UIImage imageNamed:@"checked"];
    manData.uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    TNImageCheckBoxData *womanData = [[TNImageCheckBoxData alloc] init];
    womanData.identifier = @"woman";
    womanData.labelText = @"Woman";
    womanData.checked = YES;
    womanData.checkedImage = [UIImage imageNamed:@"checked"];
    womanData.uncheckedImage = [UIImage imageNamed:@"unchecked"];
    
    self.loveGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:@[manData, womanData] style:TNCheckBoxLayoutVertical];
    [self.loveGroup create];
    self.loveGroup.position = CGPointMake(25, 410);
    
    [self.view addSubview:self.loveGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loveGroupChanged:) name:GROUP_CHANGED object:self.loveGroup];
}

- (void)createNoGroup {
    
//    NSArray * nameArr = [[NSArray alloc] initWithObjects:@"Long attack   ",@"Short attack",@"Fast attack    ",@"Slow attack", nil];
//    
//    NSMutableArray * arr = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < nameArr.count; i++) {
//        
//        TNRectangularCheckBoxData *tennisData = [[TNRectangularCheckBoxData alloc] init];
//        [tennisData setLabelColor:[UIColor whiteColor]];
//        tennisData.identifier = [nameArr objectAtIndex:i];
//        tennisData.labelText = [nameArr objectAtIndex:i];
//        tennisData.borderColor = [UIColor whiteColor];
//        tennisData.rectangleColor = [UIColor whiteColor];
//        tennisData.borderWidth = tennisData.borderHeight = 20;
//        tennisData.rectangleWidth = tennisData.rectangleHeight = 15;
//        
//        [arr addObject:tennisData];
//    }
//    
//    
//    self.noGroup = [[TNCheckBoxGroup alloc] initWithCheckBoxData:arr style:TNCheckBoxLayoutHorizontal];
//    self.noGroup.rowItemCount = 2;
//    self.noGroup.tag = 2;
//
//    self.noGroup.identifier = @"No Group";
//    [self.noGroup create];
//    CGRect frame = self.sel3View.frame;
//    self.noGroup.position = CGPointMake(frame.origin.x, frame.origin.y);
//
//    [self.containerView addSubview:self.noGroup];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noGroupChanged:) name:GROUP_CHANGED object:self.noGroup];
}

- (void)fruitGroupChanged:(NSNotification *)notification {
    
    NSLog(@"Checked checkboxes %@", self.fruitGroup.checkedCheckBoxes);
    NSLog(@"Unchecked checkboxes %@", self.fruitGroup.uncheckedCheckBoxes);
    
    TNCircularCheckBoxData * box =  (TNCircularCheckBoxData *)[self.fruitGroup.checkBoxData objectAtIndex:0];
       TNCircularCheckBoxData * box1 =  (TNCircularCheckBoxData *)[self.fruitGroup.checkBoxData objectAtIndex:1];
        TNCircularCheckBoxData * box2 =  (TNCircularCheckBoxData *)[self.fruitGroup.checkBoxData objectAtIndex:2];

    
    
    
    
    TNCircularCheckBox * boxU =  (TNCircularCheckBox *)[self.fruitGroup.checkBoxData objectAtIndex:0];
    TNCircularCheckBox * boxU1 =  (TNCircularCheckBox *)[self.fruitGroup.checkBoxData objectAtIndex:1];
    TNCircularCheckBox * boxU2 =  (TNCircularCheckBox *)[self.fruitGroup.checkBoxData objectAtIndex:2];
    
    
    if (self.fruitGroup.checkedCheckBoxes.count > 0)
    {
        TNCircularCheckBoxData * tempBox =  (TNCircularCheckBoxData *)[self.fruitGroup.checkedCheckBoxes objectAtIndex:0];
        NSInteger tag  = tempBox.tag;
        
        switch (tag) {
            case 0:
                [box1 setChecked:NO];
                [boxU1 checkWithAnimation:YES];
                [box2 setChecked:NO];
                [boxU2 checkWithAnimation:YES];
                break;
                
            case 1:
                [box setChecked:NO];
                [boxU checkWithAnimation:YES];
                [box2 setChecked:NO];
                [boxU2 checkWithAnimation:YES];

                break;
                
            case 2:
                [box1 setChecked:NO];
                [boxU1 checkWithAnimation:YES];
                [box setChecked:NO];
                [boxU checkWithAnimation:YES];

                break;
                
            default:
                break;
        }
        
    }
    



    
}

- (void)sportsGroupChanged:(NSNotification *)notification {
    
    NSLog(@"Checked checkboxes %@", self.sportsGroup.checkedCheckBoxes);
    NSLog(@"Unchecked checkboxes %@", self.sportsGroup.uncheckedCheckBoxes);
    
}

- (void)loveGroupChanged:(NSNotification *)notification {
    
    NSLog(@"Checked checkboxes %@", self.loveGroup.checkedCheckBoxes);
    NSLog(@"Unchecked checkboxes %@", self.loveGroup.uncheckedCheckBoxes);
    
}

- (void)noGroupChanged:(NSNotification *)notification {
    
    NSLog(@"Checked checkboxes %@", self.noGroup.checkedCheckBoxes);
    NSLog(@"Unchecked checkboxes %@", self.noGroup.uncheckedCheckBoxes);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
