//
//  CameraViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"
#import "Utility.h"
#import "SMTag.h"

@protocol CameraViewController
@optional
- (void)selectedImageFromCamera:(UIImage *)selectedImage;
@end


@interface CameraViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate,QBImagePickerControllerDelegate> {
    UIImageView *imageView;
    NSMutableArray *assets;
}

@property (nonatomic, strong) UIImagePickerController *picker;
@property (unsafe_unretained) id<CameraViewController> cameraDelegate;

- (void) changeFlash:(id)sender;
- (void) changeCamera;
- (void) showLibrary;
- (void)showCamera;
- (void)takePicture;
- (void)cancelCamera;
@end
