//
//  ViewController.m
//  PoCCamVidSwipe
//
//  Created by Amin Siddiqui on 01/04/14.
//  Copyright (c) 2016 Krushnai. All rights reserved.
//

#import "CameraOverLayViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraOverLayViewController ()
{
    IBOutlet UIButton * flipButton;
    IBOutlet UIButton * flashButton;
    IBOutlet UILabel * timeLable;
}

- (IBAction)camerabuttonAction:(id)sender;
- (IBAction)camerFlipButton:(id)sender;
- (IBAction)flashButtonAction:(id)sender;

@end

@implementation CameraOverLayViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[btnVideo titleLabel] setFont:[FONT_REGULAR size:12.32]];
    [[btnCamera  titleLabel]setFont:[FONT_REGULAR size:12.32]];
    [[btnlastImage titleLabel] setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    [[mainCameraBtn titleLabel] setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    [[btnCancel titleLabel] setFont:[FONT_REGULAR size:12.5]];
    [[flipButton titleLabel] setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    [[flashButton titleLabel] setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
    [timeLable setFont:[FONT_REGULAR size:23]];
    [svCameraMode setContentSize:CGSizeMake(350, 36)];
    [self setUplastPhoto];
    mode = isCamera;
    [[btnVideo titleLabel] setTextColor:[UIColor whiteColor]];
    // Handle the cases. Detect if iPhone 5 or above and set bottom bar accordingly.
    if (IS_IPHONE5) {
        [bgsemitranperentView1 setAlpha:1.0f];
        [bgsemitranperentView1 setBackgroundColor:[UIColor blackColor]];
    }
    for (UIButton *b in allButtonsArray) {
        [b setExclusiveTouch:YES];  // Don't allow multiple buttons to be tapped simultaneously.
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if (mode==isCamera)
        [self scrollButtonToCenter:btnCamera.center.x];
    else
        [self scrollButtonToCenter:btnVideo.center.x];
}

- (void)setUplastPhoto
{
    //  Set last picture to icon
    assets = [[NSMutableArray alloc] init];
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [assets addObject:result];
        } else {
            ALAsset *lastPicture = (ALAsset *)[assets lastObject];
            [btnlastImage setImage:[UIImage imageWithCGImage:[lastPicture thumbnail]] forState:UIControlStateNormal];
        }
    };
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator
                         failureBlock: ^(NSError *error) {
                             if (error) {
                                 [btnlastImage setHidden:YES];
                                 [self setModeToCamera];
                             }
                             else{
                                 [btnlastImage setHidden:NO];
                                 [self setModeToCamera];
                             }
                         }];
}

#pragma mark - My Methods

/**
 *  Update button states and color according to current mode
 */
- (void)setUIlayout
{
    [btnVideo setSelected:NO];
    [btnCamera setSelected:NO];
    if (mode == isCamera)
    {
        if (IS_IPHONE5) {
            [bgsemitranperentView1 setAlpha:1.0f];
            [bgsemitranperentView1 setBackgroundColor:[UIColor blackColor]];
        }
        [flipButton setHidden:NO];
        [timeLable setHidden:YES];
        [[btnVideo titleLabel] setTextColor:[UIColor whiteColor]];
        [[btnCamera  titleLabel]setTextColor:indicatorLbl.textColor];
    }
    else
    {
        [bgsemitranperentView1 setAlpha:0.35];
        [bgsemitranperentView2 setAlpha:0.35];
        [bgsemitranperentView1 setBackgroundColor:[UIColor darkGrayColor]];
        [bgsemitranperentView2 setBackgroundColor:[UIColor darkGrayColor]];
        [flipButton setHidden:NO];
        [timeLable setHidden:NO];
        [[btnCamera  titleLabel]setTextColor:[UIColor whiteColor]];
        [[btnVideo titleLabel] setTextColor:indicatorLbl.textColor];
    }
    if (btnlastImage.imageView.image == nil)
    {
        [btnlastImage setHidden:YES];
    }
    else
    {
        [btnlastImage setHidden:NO];
    }
}

/**
 *  Switch to photo capture mode
 */
-(IBAction)setModeToCamera
{
    if (mode != isCamera && mainCameraBtn.isSelected==NO) {
        mode = isCamera;
        [btnlastImage setHidden:NO];
        [flashButton setSelected:NO];
        [delegate flashButtonClicked:NO];
        if ([delegate respondsToSelector:@selector(didChangeMode:)]) {
            [delegate didChangeMode:YES];
        }
        [mainCameraBtn setBackgroundImage:[UIImage imageNamed:@"photoTakeBtn.png"] forState:UIControlStateNormal];
        [mainCameraBtn setBackgroundImage:[UIImage imageNamed:@"photoTakeBtn.png"] forState:UIControlStateSelected];
        [self setUIlayout];
        [self scrollButtonToCenter:btnCamera.center.x];
    }
}

/**
 *  Switch to video record mode
 */
-(IBAction)setModeToVideo
{
    if (mode != isVideo) {
        mode = isVideo;
        [flashButton setSelected:NO];
        [delegate flashButtonClicked:NO];
        if ([delegate respondsToSelector:@selector(didChangeMode:)]) {
            [delegate didChangeMode:NO];
        }
        [mainCameraBtn setBackgroundImage:[UIImage imageNamed:@"recordStart.png"] forState:UIControlStateNormal];
        [mainCameraBtn setBackgroundImage:[UIImage imageNamed:@"recordStop.png"] forState:UIControlStateSelected];
        [mainCameraBtn setSelected:NO];
        [self setUIlayout];
        [self scrollButtonToCenter:btnVideo.center.x];
    }
}

/**
 *  Capture/Record button action
 *
 *  @param sender captureButton
 */
- (IBAction)camerabuttonAction:(id)sender
{
    UIButton * btn = sender;
    switch (mode) {
        case isCamera:
            if ([delegate respondsToSelector:@selector(takePhoto)]) {
                [delegate takePhoto];
            }
            break;
        case isVideo:
            if ([btn isSelected] == YES) {
                if ([delegate respondsToSelector:@selector(stopVideo)]) {
                    [delegate stopVideo];
                    [self stopTimer];
                }
            }
            else{
                [btn setSelected:YES];
                [modeScrollView setHidden:YES];
                [indicatorLbl setHidden:YES];
                [btnCancel setHidden:YES];
                [bgsemitranperentView2 setHidden:YES];
                if ([delegate respondsToSelector:@selector(startVideo)]) {
                    [delegate startVideo];
                    [self startTimer];
                }
                
            }
            break;
        default:
            break;
    }
}


-(void)startTimer
{
    //  intitialise the timer to show time elapsed in video record mode
    [flipButton setHidden:YES];
    [flashButton setHidden:YES];
    [btnlastImage setHidden:YES];
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    secondsLeft = 60;
}

-(void)timerFired
{
    // Update counter
    if(secondsLeft > 0 ){
        [redIndicatorLbl setHidden:(!redIndicatorLbl.hidden)];
        secondsLeft -- ;
        seconds = (secondsLeft %3600) % 60;
        timeLable.text = [NSString stringWithFormat:@"00:%02d / 01:00", seconds];
    }
    else{
        // Stop video if reached maximum limit allowed by fencingapp
        if ([delegate respondsToSelector:@selector(stopVideo)]) {
            [delegate stopVideo];
            [self stopTimer];
        }
    }
}

- (void)stopTimer
{
    [timer invalidate];
    secondsLeft = 60;
}

/**
 *  Flips the camera to front or rear
 *
 *  @param sender flipButton
 */
- (IBAction)camerFlipButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(cameraFlipButtonAction)]) {
        [flashButton setHidden:!flashButton.isHidden];
        [delegate cameraFlipButtonAction];
    }
}

/**
 *  Presents camera roll library to show videos
 *
 *  @param sender libraryButton
 */
- (IBAction)showLibrary:(id)sender
{
    // Pick from camera roll button action
    if ([delegate respondsToSelector:@selector(showLibraryForVideo:)]) {
        if (mode == isVideo)
            [delegate showLibraryForVideo:YES];
        else
            [delegate showLibraryForVideo:NO];
    }
}

/**
 *  Toggles flash mode
 *
 *  @param sender flashButton
 */
- (IBAction)flashButtonAction:(id)sender
{
    // Flash toggle button action
    if ([delegate respondsToSelector:@selector(flashButtonClicked:)]) {
        UIButton * btn = sender;
        [btn setSelected:!btn.selected];
        [delegate flashButtonClicked:btn.selected];
    }
}

/**
 *  Cancels and dissmisses image picker
 *
 *  @param sender cancelButton
 */
- (IBAction)cancelButtonAction:(id)sender
{
    if ([delegate respondsToSelector:@selector(didCancelPicker)]) {
        [delegate didCancelPicker];
    }
}

-(void)scrollButtonToCenter:(NSInteger)i_btnCenterX
{
    [svCameraMode setContentOffset:CGPointMake(i_btnCenterX - (svCameraMode.frame.size.width/2), svCameraMode.contentOffset.y)
                          animated:YES];
}
@end
