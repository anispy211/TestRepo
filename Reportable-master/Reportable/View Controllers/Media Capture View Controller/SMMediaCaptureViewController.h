//
//  SMMediaCaptureViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 03/12/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
@class SMMediaCaptureViewController;


@interface SMMediaCaptureViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{}



@end

