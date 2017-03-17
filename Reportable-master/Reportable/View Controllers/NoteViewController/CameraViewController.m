//
//  CameraViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "CameraViewController.h"
#import "CustomOverlayView.h"

#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1

// Screen dimensions

@interface CameraViewController ()

@end
@implementation CameraViewController
{
    CustomOverlayView *overlay;
    BOOL didCancel;
}

@synthesize picker;
@synthesize cameraDelegate;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    overlay = [[CustomOverlayView alloc]
               initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [[UIScreen mainScreen] bounds].size.height)];
    
    overlay.delegate = self;
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.navigationBarHidden = YES;
    self.picker.toolbarHidden = YES;
    self.picker.wantsFullScreenLayout = YES;
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            [assets addObject:result];
            
        } else {
            [self performSelectorOnMainThread:@selector(showCamera) withObject:nil waitUntilDone:NO];
            ALAsset *lastPicture = (ALAsset *)[assets lastObject];
            [overlay.lastPicture setImage:[UIImage imageWithCGImage:[lastPicture thumbnail]] forState:UIControlStateNormal];
        }
    };
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    assets = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:assetGroupEnumerator
                         failureBlock: ^(NSError *error) {
                             [self showCamera];
                         }];
}

- (void) showCamera
{
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    UIImagePickerControllerCameraCaptureModeVideo
    
    // Must be NO.
    self.picker.showsCameraControls = NO;
    self.picker.cameraViewTransform =
    CGAffineTransformScale(self.picker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
    
    // When showCamera is called, it will show by default the back camera, so if the flashButton was
    // hidden because the user switched to the front camera, you have to show it again.
    if (overlay.flashButton.hidden) {
        overlay.flashButton.hidden = NO;
    }
    
    self.picker.cameraOverlayView = overlay;
    
    // If the user cancelled the selection of an image in the camera roll, we have to call this method
    // again.
    if (!didCancel) {
        [self presentViewController:self.picker animated:YES completion:nil];
    } else {
        didCancel = NO;
    }
}
        

- (void)cancelCamera
{
    UIViewController *t= self;
    [self dismissViewControllerAnimated:YES completion:^{
        [t dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)takePicture
{
    [picker takePicture];
}

- (void)imageEditingDoneWithResultantImage:(UIImage *)image{
    if (cameraDelegate)
        [cameraDelegate selectedImageFromCamera:image];
    
    // [self cancelCamera];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
        
        

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *aImage = [info objectForKey:UIImagePickerControllerOriginalImage];;
    
    if (aPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum (aImage, nil, nil , nil);

        overlay.pictureButton.enabled = YES;
        [overlay.lastPicture setImage:aImage forState:UIControlStateNormal];
        if(aImage.size.width>aImage.size.height)
        {
            CGImageRef ref = aImage.CGImage;
            aImage = [UIImage imageWithCGImage:ref scale:1 orientation:UIImageOrientationRight];
        }
    }
    [self.navigationController.navigationBar setHidden:YES];
//    ImageEditingViewController *imageEditingViewController = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
       
        [self continueSavingImage:aImage];
//        imageEditingViewController = [[ImageEditingViewController alloc] initWithNibName:@"ImageEditingViewController_iPhone" bundle:nil withImageName:aImage];
//        
        // imageEditingViewController.imageEditingViewDelegate = self;
        self.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:imageEditingViewController animated:YES ];
        self.hidesBottomBarWhenPushed=NO;
    }
    [self.picker dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_LIST object:nil];
}

-(void)continueSavingImage:(UIImage *)selectedImage{
    NSMutableArray * array = [[SMSharedData sharedManager] tags];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"type == %d",3];
    NSArray *filteredArray  = [array filteredArrayUsingPredicate:predicate];
            NSString *fileName;
    if(filteredArray && [filteredArray count] > 0)
    {
        NSInteger lastphotoID = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastDefaultPhotoID"];
        NSURL *newURL;

            do {
                fileName =[NSString stringWithFormat:@"Photo %d",(int)++lastphotoID];
                newURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
            } while ([[NSFileManager defaultManager] fileExistsAtPath:newURL.path]);
        [[NSUserDefaults standardUserDefaults] setInteger:lastphotoID forKey:@"LastDefaultPhotoID"];
    }
    else{
        fileName = [NSString stringWithFormat:@"Photo 1"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"LastDefaultPhotoID"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SMTag *photoTag = [[SMTag alloc] init];
    NSURL *imageURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", fileName]];
    
    NSData *pngData = UIImageJPEGRepresentation(selectedImage, 1.0);
    [pngData writeToFile:imageURL.path atomically:YES];
    
    photoTag.name = fileName;
    photoTag.type = 3;
    
    
    NSURL *thumbnailURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpeg", fileName, THUMBNAIL_IMAGE]];
    
    UIImage *image = [Utility imageWithImage:selectedImage scaledToSizeWithSameAspectRatio:CGSizeMake(100, 100)];
    pngData = UIImageJPEGRepresentation(image, 1.0);
    [pngData writeToFile:thumbnailURL.path atomically:YES];
    
    [[SMSharedData sharedManager] addDefaultStampsToTag:photoTag];
    [[SMSharedData sharedManager] addNewTag:photoTag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tagCreated"
                                                        object:self];
    [self dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    didCancel = YES;
    [self showCamera];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (IBAction) backButton:(id)sender
{
    self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (IBAction)doneButton:(id)sender
{
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (overlay.flashButton.hidden) {
        overlay.flashButton.hidden = NO;
    }
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void) changeFlash:(id)sender
{
    switch (self.picker.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [(UIButton *)sender setImage:[UIImage imageNamed:@"flash01"] forState:UIControlStateNormal];
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            break;
            
        case UIImagePickerControllerCameraFlashModeOn:
            [(UIButton *)sender setImage:[UIImage imageNamed:@"flash03"] forState:UIControlStateNormal];
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            break;
            
        case UIImagePickerControllerCameraFlashModeOff:
            [(UIButton *)sender setImage:[UIImage imageNamed:@"flash02"] forState:UIControlStateNormal];
            self.picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
    }
}

- (void)changeCamera
{
    if (self.picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        overlay.flashButton.hidden = NO;
    } else {
        self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        overlay.flashButton.hidden = YES;
    }
}

- (void)showLibrary
{
   // self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self.picker dismissViewControllerAnimated:NO completion:nil];

    
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    
    [self.navigationController pushViewController:imagePickerController animated:YES];
    
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

@end
