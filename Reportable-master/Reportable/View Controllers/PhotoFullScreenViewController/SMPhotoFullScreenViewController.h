//
//  SMPhotoFullScreenViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 12/05/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMPhotoFullScreenViewController : UIViewController
{
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *imageViewContainerScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andWithImageAtPath:(NSString *)path;
@end
