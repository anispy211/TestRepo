//
//  SMSplashViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/6/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMSplashViewController.h"

@interface SMSplashViewController ()

@end

@implementation SMSplashViewController
@synthesize splashImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_IPHONE5) {
        [self.splashImageView setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        
    }else{
        [self.splashImageView setImage:[UIImage imageNamed:@"Default@2x.png"]];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
