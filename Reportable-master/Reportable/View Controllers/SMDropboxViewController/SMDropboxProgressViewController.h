//
//  SMDropboxProgressViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 16/04/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMDropboxComponent.h"

@class SMDropboxProgressViewController;
@protocol SMDropboxProgressDelegate <NSObject>
-(void)delegatedCancelButtonAction;
@end
@interface SMDropboxProgressViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *dropboxProgressContainerView;
@property (strong, nonatomic) IBOutlet UIProgressView *dropboxProgressView;
@property (strong, nonatomic) IBOutlet UILabel *dropboxProgressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dropboxSuccessImageView;
@property (strong, nonatomic) IBOutlet UIButton *dropboxCancelButton;
@property (strong, nonatomic) IBOutlet UIButton *dropboxDoneButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *dropboxProgressActivityIndicatorView;
@property (strong, nonatomic) IBOutlet UIView *dropboxProgressViewContainer;
@property (nonatomic,assign) id <SMDropboxProgressDelegate> delegate;

- (IBAction)dropboxCancelButtonAction:(id)sender;
- (IBAction)dropboxDoneButtonAction:(id)sender;
@end
