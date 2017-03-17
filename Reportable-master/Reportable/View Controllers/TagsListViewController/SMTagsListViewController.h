//
//  SMTagsListViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/5/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TagsDetailViewController.h"
#import "SMSettingsViewController.h"
#import "SMPDFDetailsViewController.h"
#import "MBProgressHUD.h"
#import "SMPDFViewController.h"
#import "SMAudioRecorderViewController.h"
#import "SMNavigationBar.h"
#import <DropboxSDK/DropboxSDK.h>
#import "SMDropboxComponent.h"
#import <ImageIO/ImageIO.h>
#import "SMDropboxListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "SMDropboxProgressViewController.h"
#import <CoreMedia/CoreMedia.h>
#import "QBImagePickerController.h"
#import "SSPopup.h"
#import "SMDropboxViewController.h"



@interface SMTagsListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate,SMPDFViewControlerDelegate,UIAlertViewDelegate,UITextFieldDelegate,DBRestClientDelegate,SMDropboxActivityDelegate,SMDropboxViewControllerDelegate,MFMailComposeViewControllerDelegate,SMDropboxProgressDelegate,SSPopupDelegate>
{
    NSMutableArray *tags;
    IBOutlet UIToolbar * toolBarView;
    TagsDetailViewController *viewController;
    IBOutlet UIBarButtonItem * removeButton;
    BOOL isEditModeOn;
    UINavigationController * navigationController;
    NSTimer * timer;
    BOOL isMessageViewPresent;
    int countsec,countmin,totaltime, counter;
    NSTimer * recordingTimer;
    BOOL isInPlayMode;
    IBOutlet UIButton *doneCustomButton;
    BOOL selectAllFlag;
    IBOutlet UIToolbar *mediaToolBar;
    NSURL * asset1;
    
    NSString * currentWepon;
}

@property (nonatomic, strong) NSMutableArray * selectedTags;
@property (nonatomic, strong) DBRestClient *restClient;
@property (weak, nonatomic) IBOutlet SMNavigationBar *titleBar;
@property (strong, nonatomic) IBOutlet UIButton *editCustomButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsCustomButton;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, strong)IBOutlet UIBarButtonItem * createReportButton;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) IBOutlet UILabel *noTagsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isDropboxModeOn:(BOOL)mode;
- (IBAction)createReportAction:(id)sender;
- (IBAction)removeAction:(id)sender;
- (void)clearAllSelection;
@end
