//
//  ACEViewController.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACEDrawingView.h"
#import <AVFoundation/AVUtilities.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"

#define kActionSheetColor       100
#define kActionSheetTool        101

@interface ACEViewController ()<UIActionSheetDelegate, ACEDrawingViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ACEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the delegate
    self.drawingView.delegate = self;
    
    self.clearButton.enabled = TRUE;
    
    // start with a black pen
    self.lineWidthSlider.value = self.drawingView.lineWidth;
    
    // init the preview image
    self.previewImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.previewImageView.layer.borderWidth = 2.0f;
    
    // set draggable text properties
    self.drawingView.draggableTextFontName = @"MarkerFelt-Thin";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Activity Sheet



- (void)presentActivityController:(UIActivityViewController *)controller {
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    

    
    // for iPad: make the presentation a Popover
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    if (IS_IPAD)
    {
        popController.sourceView = self.tempBtn;
        popController.sourceRect = self.tempBtn.frame;
    }
    
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}


#pragma mark - Actions

- (IBAction)backButtonAction:(id)sender
{
    
    
    [self.view removeFromSuperview];

}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //do what you need to do when animation ends...
    [self.view removeFromSuperview];

}



#pragma mark - Actions

- (void) grabAndShareImage
{
    // show the preview image
    UIImage *baseImage = [self.baseImageView image];
    UIImage * img =  baseImage ? [self.drawingView applyDrawToImage:baseImage] : self.drawingView.image;
    
    
    NSArray *items = @[img];
    
    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    // and present it
    [self presentActivityController:controller];
}



- (IBAction)shareButtonAction:(id)sender
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(grabAndShareImage) withObject:self afterDelay:1.5];
    
}


- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.drawingView canUndo];
    self.redoButton.enabled = [self.drawingView canRedo];
}

- (IBAction)takeScreenshot:(id)sender
{
    // show the preview image
    UIImage *baseImage = [self.baseImageView image];
    self.previewImageView.image =  baseImage ? [self.drawingView applyDrawToImage:baseImage] : self.drawingView.image;
    self.previewImageView.hidden = NO;
    
    // close it after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.previewImageView.hidden = YES;
    });
}

- (IBAction)undo:(id)sender
{
    [self.drawingView undoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)redo:(id)sender
{
    [self.drawingView redoLatestStep];
    [self updateButtonStatus];
}

- (IBAction)clear:(id)sender
{
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"You want to clear all drawing" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        if ([self.baseImageView image])
        {
            // [self.baseImageView setImage:nil];
            [self.drawingView setFrame:self.baseImageView.frame];
        }
        
        [self.drawingView clear];
        [self updateButtonStatus];

    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Other action
        NSLog(@"Clear canceled");
    }];
    [alert addAction:otherAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


#pragma mark - ACEDrawing View Delegate

- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}


#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (actionSheet.tag == kActionSheetColor) {
            
            //self.colorButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.lineColor = [UIColor blackColor];
                    break;
                    
                case 1:
                    self.drawingView.lineColor = [UIColor redColor];
                    break;
                    
                case 2:
                    self.drawingView.lineColor = [UIColor greenColor];
                    break;
                    
                case 3:
                    self.drawingView.lineColor = [UIColor blueColor];
                    break;
            }
            
        } else {
            
            self.toolButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.drawTool = ACEDrawingToolTypePen;
                    break;
                    
                case 1:
                    self.drawingView.drawTool = ACEDrawingToolTypeLine;
                    break;
                    
                case 2:
                    self.drawingView.drawTool = ACEDrawingToolTypeArrow;
                    break;
                    
                case 3:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;
                    break;
                    
                case 4:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;
                    break;
                    
                case 5:
                    self.drawingView.drawTool = ACEDrawingToolTypeEraser;

                    break;
                    
                case 6:
                    self.drawingView.drawTool = ACEDrawingToolTypeDraggableText;
                    break;
                    
                case 7:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;
                    break;
                    
                case 8:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;
                    break;
            }
            
            // if eraser, disable color and alpha selection
            self.colorButton.enabled = self.alphaButton.enabled = buttonIndex != 6;
        }
    }
}

#pragma mark - Settings

- (IBAction)colorChange:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Selet a color"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Black", @"Red", @"Green", @"Blue", nil];
    
    [actionSheet setTag:kActionSheetColor];
    [actionSheet showInView:self.view];
}

- (IBAction)toolChange:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Selet a tool"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Pen", @"Line", @"Arrow",
                                  @"Rectangle", @"Ellipse",@"Eraser",@"Text",nil];
    
    
    
//                                  @"Rect (Fill)", @"Ellipse (Fill)",
//                                  @"Eraser",
//                                  nil];
    
    [actionSheet setTag:kActionSheetTool];
    [actionSheet showInView:self.view];
}

- (IBAction)toggleWidthSlider:(id)sender
{
    // toggle the slider
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
    self.lineAlphaSlider.hidden = YES;
}

- (IBAction)widthChange:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
}

- (IBAction)toggleAlphaSlider:(id)sender
{
    // toggle the slider
    self.lineAlphaSlider.hidden = !self.lineAlphaSlider.hidden;
    self.lineWidthSlider.hidden = YES;
}

- (IBAction)alphaChange:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
}

- (IBAction)imageChange:(id)sender
{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    [self.drawingView clear];
    [self updateButtonStatus];
    
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.baseImageView setImage:image];
    [self.drawingView setFrame:AVMakeRectWithAspectRatioInsideRect(image.size, self.baseImageView.frame)];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
