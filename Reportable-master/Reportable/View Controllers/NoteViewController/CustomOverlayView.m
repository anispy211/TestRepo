//
//  CustomOverlayView.m
//  CustomCamera
//
//  Created by Carlos Balduz Bernal on 23/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomOverlayView.h"

@implementation CustomOverlayView

@synthesize delegate, flashButton, changeCameraButton, pictureButton, lastPicture;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        UIImage *buttonImageNormal;
        // Add the flash button
        if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
            self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.flashButton.frame = CGRectMake(10, 30, 57.5, 57.5);
            buttonImageNormal = [UIImage imageNamed:@"flash02"];
            [self.flashButton setImage:buttonImageNormal forState:UIControlStateNormal];
            [self.flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.flashButton];
        }
        // Add the camera button
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.changeCameraButton.frame = CGRectMake(238, 10, 71, 36);
            buttonImageNormal = [UIImage imageNamed:@"camera_toggle"];
            [self.changeCameraButton setImage:buttonImageNormal forState:UIControlStateNormal];
            [self.changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.changeCameraButton];
        }
        UIToolbar *toolbar = nil;
        toolbar   = [[UIToolbar alloc] init];
        [toolbar setTintColor:[UIColor blackColor]];

        if (IS_IPHONE5) {
            [toolbar setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height -100, 320, 100)];
            buttonImageNormal = [UIImage imageNamed:@"take_picture_iphone5"];
        }
        else{
            [toolbar setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height -56, 320, 56)];
            buttonImageNormal = [UIImage imageNamed:@"take_picture"];
        }
      
        toolbar.backgroundColor= [UIColor blackColor];
        [self addSubview:toolbar];
        
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Cancel"
                                      style:UIBarButtonItemStyleBordered
                                      target:self
                                      action:@selector(cancelButtonClicked:)];
        [btnCancel setTintColor:[UIColor blackColor]];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] ;
       
        self.pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pictureButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [self.pictureButton setImage:buttonImageNormal forState:UIControlStateDisabled];
        [self.pictureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *b= [[UIBarButtonItem alloc] initWithCustomView:self.pictureButton];
        if(IS_IPHONE5)
            self.pictureButton.frame = CGRectMake(toolbar.bounds.size.width*0.5-toolbar.bounds.size.width*0.125,toolbar.bounds.size.height*0.1, toolbar.bounds.size.width*0.25, toolbar.bounds.size.height*0.8);
        else
            self.pictureButton.frame = CGRectMake(toolbar.bounds.size.width*0.5-toolbar.bounds.size.width*0.125,toolbar.bounds.size.height*0.1, toolbar.bounds.size.width*0.30, toolbar.bounds.size.height*0.8);
        self.lastPicture = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.lastPicture.layer setCornerRadius:1.0];   //prev was 3.0
        [self.lastPicture.layer setBorderWidth:0.5];
        [self.lastPicture setClipsToBounds:YES];
        [self.lastPicture.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.lastPicture addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *b2= [[UIBarButtonItem alloc] initWithCustomView:self.lastPicture];
        self.lastPicture.frame = CGRectMake(toolbar.bounds.size.width*0.9,toolbar.bounds.size.height*0.25, toolbar.bounds.size.height*0.6, toolbar.bounds.size.height*0.6);
        
        
        toolbar.items = [NSArray arrayWithObjects:btnCancel,flex,b,flex,b2, nil];
        // Add the gallery button
     
   

      //  [self addSubview:self.lastPicture];
    }
    return self;
}

- (void)cancelButtonClicked:(id)sender{
    [self.delegate cancelCamera];
}
        

- (void)takePicture:(id)sender
{
    self.pictureButton.enabled = NO;
    [self.delegate takePicture];
}

- (void)setFlash:(id)sender
{
    [self.delegate changeFlash:sender];
}

- (void)changeCamera:(id)sender
{
    [self.delegate changeCamera];
}
//
- (void)showCameraRoll:(id)sender
{
    [self.delegate showLibrary];
}



@end
