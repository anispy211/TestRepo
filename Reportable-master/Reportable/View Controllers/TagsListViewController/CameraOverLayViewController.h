//
//  ViewController.h
//  PoCCamVidSwipe
//
//  Created by Amin Siddiqui on 01/04/14.
//  Copyright (c) 2016 Krushnai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

enum {
    isCamera = 1,
    isVideo = 2
};
typedef NSUInteger avMode;

@protocol CameraOverlayDelegate <NSObject>

- (void) didChangeMode:(BOOL)isCamera;
- (void) showLibraryForVideo:(BOOL)isVideo;
- (void) startVideo;
- (void) stopVideo;
- (void) takePhoto;
- (void) didCancelPicker;
- (void) cameraFlipButtonAction;
- (void) flashButtonClicked:(BOOL)isFlashOff;
- (void) hdrButtonClicked:(BOOL)ishdrOff;

@end


@interface  CameraOverLayViewController : UIViewController
{
    avMode mode;
    NSMutableArray *assets;
    IBOutlet UIView *vwAVContainer;
    IBOutlet UIScrollView *svCameraMode;
    IBOutlet UIButton *btnVideo;
    IBOutlet UIButton *btnCamera;
    IBOutlet UIButton *btnlastImage;
    IBOutlet UISwipeGestureRecognizer *gesSwipeLeft;
    IBOutlet UISwipeGestureRecognizer *gesSwipeRight;
    IBOutlet UIButton * mainCameraBtn;
    IBOutlet UIScrollView * modeScrollView;
    IBOutlet UILabel * indicatorLbl;
    IBOutlet UIButton * btnCancel;
    IBOutlet UILabel * redIndicatorLbl;
    IBOutletCollection(UIButton) NSArray *allButtonsArray;
    NSTimer *timer;
    int  seconds;
    int secondsLeft;
    IBOutlet UIView * bgsemitranperentView1;
    IBOutlet UIView * bgsemitranperentView2;
}

@property (nonatomic,unsafe_unretained) id <CameraOverlayDelegate> delegate;

- (IBAction)showLibrary:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)setModeToCamera;
- (IBAction)setModeToVideo;
@end
