//
//  CustomOverlayView.h
//  CustomCamera
//
//  Created by Carlos Balduz Bernal on 23/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomOverlayView : UIView

@property (nonatomic, weak) CameraViewController *delegate;
@property (nonatomic, weak) UIButton *pictureButton;
@property (nonatomic, weak) UIButton *flashButton;
@property (nonatomic, weak) UIButton *changeCameraButton;
@property (nonatomic, weak) UIBarButtonItem *cancelButton;
@property (nonatomic, weak) UIButton *lastPicture;

@end