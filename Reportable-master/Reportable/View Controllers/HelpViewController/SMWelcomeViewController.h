//
//  SMWelcomeViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/11/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMNavigationBar.h"

@interface SMWelcomeViewController : UIViewController
<UIScrollViewDelegate>
{
	IBOutlet UIScrollView* scrollView;
	IBOutlet UIPageControl* pageControl;
    IBOutlet UILabel *tutorialLabel;
    IBOutlet UIBarButtonItem *doneButton;
	NSArray *textMatterArray;
    BOOL pageControlIsChangingPage;
}
@property (nonatomic, retain) UIView *scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIsEnteringFromSettings:(BOOL)isFromSettings;
/* for pageControl */
- (IBAction)changePage:(id)sender;

@property (weak, nonatomic) IBOutlet SMNavigationBar *navigationBar;
/* internal */
- (void)setupPage;

- (IBAction)skipButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end
