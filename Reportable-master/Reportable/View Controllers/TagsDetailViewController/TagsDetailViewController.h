//
//  TagsDetailViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/19/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTag.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SMNoteViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "THCircularProgressView.h"
#import "SMDropboxActivity.h"
#import "UICircularSlider.h"
#import "SMDropboxProgressViewController.h"
#import "SMDropboxListViewController.h"
#import "SMDropboxComponent.h"
#import "ACEViewController.h"
#import "FormViewController.h"
#import "PointsDetailViewController.h"
#import "SSPopup.h"



@class SMTag;

typedef enum {
    kAudioView = 1,
    kVideoView,
    kPhotoView,
    kNoteView
} DefaultView;

@interface TagsDetailViewController : UIViewController <UINavigationControllerDelegate,UIScrollViewDelegate
,UIGestureRecognizerDelegate,UITextFieldDelegate,AVAudioPlayerDelegate,UITextViewDelegate,UICircularSliderDelegate,UIAlertViewDelegate,SMDropboxActivityDelegate,DBRestClientDelegate,SMDropboxActivityDelegate,SMDropboxViewControllerDelegate,SSPopupDelegate>

{
    BOOL isloaded;
    
    NSMutableArray *tags;
    UIImage * selectedTagImage;
    IBOutlet UINavigationBar * navigationBar;
    IBOutlet UINavigationItem * navItem;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *stopButton;
    IBOutlet UITextView *noteTextView;
    IBOutlet UIBarButtonItem *saveBarButton;
    IBOutlet UIImageView *dividerImageView;
    IBOutlet UILabel *totalAudioDurationLabel;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *cancelButton;
    UIDatePicker *datePicker;
    CGRect oldFrame;
    NSDate *newDate;
    BOOL startedEditing;
    BOOL shouldDismiss;
    BOOL isDetailViewOpen;
@private
    DefaultView defaultView;
    MPMoviePlayerController *moviePlayer;
    AVAudioPlayer *audioPlayer;
    CGFloat countmin,countsec;
    UIAlertView *editAlert;
    BOOL isRepaating;
    
    IBOutlet UIToolbar *tagToolBar;

}
@property (strong, nonatomic) FormViewController *mainVC;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *examples;
@property (nonatomic) CGFloat percentage;
@property (strong, nonatomic) SMTag *tag;
@property (nonatomic, strong) DBRestClient *restClient;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainContainerScrollView;
@property (strong, nonatomic) IBOutlet UIView *audioContainerView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITextField *tagDetailsLocation;
@property (weak, nonatomic) IBOutlet UITextField *tagDetailsDate;
@property (weak, nonatomic) IBOutlet UITextView *tagDetailsCaption;
@property (unsafe_unretained, nonatomic) IBOutlet UICircularSlider *circularSlider;
@property (weak, nonatomic) IBOutlet UIView *containerDetailsView;
@property (nonatomic, strong)  IBOutlet UIView *statusBarView;
@property (nonatomic,assign) IBOutlet UIImageView * detailImageView;
@property (nonatomic, strong) IBOutlet UITextField *tagDetailsName;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsCopyright;
@property (strong, nonatomic) IBOutlet UIButton *moviePlayPauseButton;
@property (strong, nonatomic) IBOutlet UISlider *movieSlider;
@property (weak, nonatomic) IBOutlet UIView *progressViewBGView;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharactersLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxCharactersLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharacterCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTimeElapsedLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoTimeRemainingLabel;
@property (strong, nonatomic) IBOutlet UIView *videoControlsView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *recordBarButton;


@property (strong, nonatomic) ACEViewController *viewController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withDefaultView:(DefaultView)view;
- (IBAction)deleteButtonAction:(id)sender;
- (IBAction)moviePlayPauseButtonAction:(id)sender;
- (IBAction)saveEditedButtonAction:(id)sender;
- (IBAction)seekVideoAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)moviePlayerFullScreenButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;



#pragma mark - Toolbar Button Action

- (IBAction)addPointButtonAction:(id)sender;
- (IBAction)grabPhotoButtonAction:(id)sender;
- (IBAction)recordedPointButtonAction:(id)sender;

@end
