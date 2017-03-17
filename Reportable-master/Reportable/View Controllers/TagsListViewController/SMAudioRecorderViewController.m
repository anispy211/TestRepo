//
//  SMAudioRecorderViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 12/27/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMAudioRecorderViewController.h"
#import "SMTag.h"
#import "SMSharedData.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Utility.h"

@interface SMAudioRecorderViewController ()

@end

@implementation SMAudioRecorderViewController
@synthesize audioButton = _audioButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Audio", @"Audio");
        self.tabBarItem.image = [UIImage imageNamed:@"audio"];
        
        NSString *tempName = @"@@@@@#####";
        tempAudioURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", tempName]];
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.audioButton setExclusiveTouch:YES];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
        
        //Reset the flag
        if(isInPlayMode == YES)
        {
            isInPlayMode = NO;
        }
        
        //Stop timer
        [recordingTimer invalidate];
        recordingTimer = nil;
        
        //Change the image to stop image
        [self.audioButton setImage:[UIImage imageNamed:@"recording@2x.png"] forState:UIControlStateNormal];
    
    }
}

- (IBAction)audioButtonAction:(id)sender
{
    if (!audioRecorder.recording )
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:tempAudioURL.path] )
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:tempAudioURL.path error:&error];
        }
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
        
        [self createAudioSession];
        
        NSError *error = nil;
        audioRecorder = [[AVAudioRecorder alloc] initWithURL:tempAudioURL settings:recordSetting error:&error];

        audioRecorder.delegate = self;
        
        audioRecorder.meteringEnabled = YES;
        if (error)
            NSLog(@"error: %@", [error localizedDescription]);
        else
            [audioRecorder prepareToRecord];
        
        
        
        [audioRecorder record];
        
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    else
        [self stop:nil];
}


- (void)saveCompleted{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma Audio capture handlers

-(void)startTimer
{
	countsec++;
    
	if(countsec == 60)
	{
		countsec=0;
		countmin++;
	}
//    //NSLog(@"countsec : %d",countsec);

}

-(void) createAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
  //      //NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    err = nil;
    [audioSession setActive:YES error:&err];
    if(err){
         return;
    }
}



- (NSString *) timeInFormat:(int)value
{
    int sliderValue = value;
    int min = 00;
    int sec = 00;
    
    if(sliderValue >= 60)
    {
        min = (sliderValue / 60);
        sliderValue = sliderValue - (60 * min);
    }
    if(sliderValue<60)
    {
        sec = sliderValue;
    }
    NSString * time = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    return time;
}

-(void)StopRecording:(id)sender
{
    [self clearTimers];
    [self saveAudio];
}

- (void)clearTimers
{
    countsec = 0;
    countmin = 0;
}

- (void)stop:(id)sender
{
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    }
    
    if(isInPlayMode == YES)
    {
        isInPlayMode = NO;
    }
    
    [recordingTimer invalidate];
	recordingTimer = nil;
	[self performSelector:@selector(StopRecording:) withObject:nil afterDelay:0.3];
}

- (void)saveAudio
{
    NSString * fileName = nil;
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",AudioTagType];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
    if(filteredArray && [filteredArray count] > 0)
    {
        NSInteger lastaudioID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultAudioID"];
        fileName = [NSString stringWithFormat:@"%@_Audio%d",[[NSUserDefaults standardUserDefaults] valueForKey:@"UniqueDeviceID"],lastaudioID+ 1];
        [[NSUserDefaults standardUserDefaults] setInteger:lastaudioID+1 forKey:@"LastDefaultAudioID"];
        
    }
    else{
        fileName = [NSString stringWithFormat:@"%@_Audio1",[[NSUserDefaults standardUserDefaults] valueForKey:@"UniqueDeviceID"]];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LastDefaultAudioID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SMTag *audioTag = [[SMTag alloc] init];
    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", fileName]];
    
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:tempAudioURL.path toPath:url.path error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:tempAudioURL.path error:&error];
    
    audioTag.name = fileName;
    audioTag.type = 1;
    [[SMSharedData sharedManager] addDefaultStampsToTag:audioTag];
    [[SMSharedData sharedManager] addNewTag:audioTag];
    [self clearTimers];
    [[self.navigationItem rightBarButtonItem] setEnabled:NO];
    [self saveCompleted];
}

# pragma mark - Notification Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(isInPlayMode == YES)
    {
        isInPlayMode = NO;
    }
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
  //  //NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
 //   //NSLog(@"Encode Error occurred");
}
@end
