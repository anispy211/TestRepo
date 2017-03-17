//
//  SMAudioRecorderViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/1/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import "SMTag.h"
#import "Utility.h"
#import "THCircularProgressView.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface SMAudioRecorderViewController : UIViewController <AVAudioRecorderDelegate,UIAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    AVAudioRecorder *audioRecorder;
    NSURL *tempAudioURL;
    NSTimer * recordingTimer;
    CGFloat countsec,countmin,totaltime, counter;
    BOOL isInPlayMode;
    BOOL isInPauseMode;
    NSDate *startDate;
    NSDate *resumeDate;
    CGFloat pauseTimeValue;
    
    IBOutlet UILabel *maxAudioDurationLabel;
}
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIView *circularProgressBackgroundView;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainContainerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *recorderButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecordingButton;
@property (strong, nonatomic) IBOutlet UIView *containerDetailsView;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsName;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsLocation;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsDate;
@property (strong, nonatomic) IBOutlet UITextField *tagDetailsCopyright;
@property (strong, nonatomic) IBOutlet UITextView *tagDetailsCaption;
@property (strong, nonatomic) IBOutlet UILabel *remainingCharactersLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *examples;
@property (nonatomic) CGFloat percentage;

- (IBAction)recordAction:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)saveButtonAction:(id)sender;

@end
