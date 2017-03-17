//
//  SMPhotoFullScreenViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 12/05/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMPhotoFullScreenViewController.h"

@interface SMPhotoFullScreenViewController ()
{
    NSString *imagePath;
}

@end

@implementation SMPhotoFullScreenViewController
@synthesize imageView;
@synthesize imageViewContainerScrollView;

/**
 *  Custom initialisation method
 *
 *  @param nibNameOrNil   nibNameOrNil
 *  @param nibBundleOrNil nibBundleOrNil description
 *  @param path           path of the image
 *
 *  @return self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andWithImageAtPath:(NSString *)path
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        imagePath = path;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initial Setup
    UIImage *image= [[UIImage alloc] initWithContentsOfFile:imagePath];
    [self.imageView setImage:image];
    [self.imageViewContainerScrollView setMaximumZoomScale:5.0];
    [self.imageViewContainerScrollView setFrame:self.view.frame];
    [self.imageViewContainerScrollView setContentSize:self.view.frame.size];
    [UIView animateWithDuration:0.5 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.view setAlpha:1.0];
    }];
    UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetectedOnImage:)];
    [tapGestureRecoginzer setNumberOfTapsRequired:2];
    [tapGestureRecoginzer setNumberOfTouchesRequired:1];
    [self.imageView addGestureRecognizer:tapGestureRecoginzer];
    // Do any additional setup after loading the view from its nib.
}

/**
 *  Exit full screen mode on double tap
 *
 *  @param gesture double tap gesture
 */
-(void)tapGestureDetectedOnImage:(UIGestureRecognizer *)gesture{
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setAlpha:0.0];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    } completion:^(BOOL finished) {
        [[SMSharedData sharedManager] setShouldAutorotate:NO];
        UIWindow *win = [SMSharedData sharedManager].mainWindow;
        [[UIApplication sharedApplication].delegate setWindow:win];
        [win makeKeyAndVisible];
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    }];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
