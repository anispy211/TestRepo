//
//  SMDropboxProgressViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 16/04/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMDropboxProgressViewController.h"

@interface SMDropboxProgressViewController ()

@end

@implementation SMDropboxProgressViewController

@synthesize dropboxProgressContainerView;
@synthesize dropboxProgressLabel;
@synthesize dropboxProgressView;
@synthesize dropboxProgressActivityIndicatorView;
@synthesize dropboxSuccessImageView;
@synthesize dropboxCancelButton;
@synthesize dropboxDoneButton;
@synthesize dropboxProgressViewContainer;

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
    // Initial Setup
    [self.dropboxCancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dropboxProgressLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_SETTINGS_CELL]];
    [self.dropboxDoneButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [self.dropboxCancelButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    [self.dropboxProgressViewContainer setFrame:CGRectMake(0, screenHeight/2-self.dropboxProgressViewContainer.frame.size.height/2, self.dropboxProgressViewContainer.frame.size.width, self.dropboxProgressViewContainer.frame.size.height)];
    // Do any additional setup after loading the view from its nib.
}
        
-(BOOL)shouldAutorotate
{
    return NO;
}

/**
 *  Cancel Dropbox Import/Export
 *
 *  @param sender cancelButton
 */
- (IBAction)dropboxCancelButtonAction:(id)sender {
    [[SMDropboxComponent sharedComponent].restClient cancelAllRequests];
    [self.dropboxProgressActivityIndicatorView stopAnimating];
    [self.view removeFromSuperview];
}

/**
 *  Dropbox sharing finish button action
 *
 *  @param sender finishButton
 */
- (IBAction)dropboxDoneButtonAction:(id)sender {
    if([self.delegate respondsToSelector:@selector(delegatedCancelButtonAction)]){
        [self.delegate delegatedCancelButtonAction];
        return;
    }
    [self.view removeFromSuperview];
}
@end
