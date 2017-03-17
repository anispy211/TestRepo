//
//  SMAudioRecorderViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 12/27/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>

@interface SMAudioRecorderViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    int countsec,countmin,totaltime, counter;
    NSTimer * recordingTimer;
    BOOL isInPlayMode;
    NSURL *tempAudioURL;
    AVAudioRecorder *audioRecorder;
    IBOutlet UILabel *maxDurationLabel;
}

@property (nonatomic, strong) IBOutlet UIButton *audioButton;
- (IBAction)audioButtonAction:(id)sender;
@end
