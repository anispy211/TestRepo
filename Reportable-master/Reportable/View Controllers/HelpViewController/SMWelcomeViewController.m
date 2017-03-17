//
//  SMWelcomeViewController.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/11/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMWelcomeViewController.h"

@interface SMWelcomeViewController ()
{
    BOOL shouldHideDone;
}
@end

@implementation SMWelcomeViewController
@synthesize scrollView;
@synthesize pageControl;
@synthesize nextButton;
@synthesize navigationBar;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIsEnteringFromSettings:(BOOL)isFromSettings
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        shouldHideDone = isFromSettings;
    }
    return self;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!APP_DELEGATE.hasLaunchedOnce)
        [self.navigationBar.topItem setRightBarButtonItem:nil];
    [self setupPage];
    [tutorialLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_LABEL]];
    [tutorialLabel setTextColor:REPORTABLE_DARK_TEXT_COLOR];
    [self.pageControl setCurrentPageIndicatorTintColor:REPORTABLE_ORANGE_COLOR];
    // Do any additional setup after loading the view from its nib.
    if(self.navigationController)
       [self.navigationBar.topItem setTitle:@"HELP"];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1]];
    if(shouldHideDone)
        [self.navigationBar.topItem setRightBarButtonItem:nil];
    else
        [self.navigationBar.topItem setLeftBarButtonItem:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

/**
 *  Create scroll view and add images and labels to create help screens
 */
- (void)setupPage
{
	scrollView.delegate = self;
	[scrollView setCanCancelContentTouches:NO];
	scrollView.clipsToBounds = YES;
	scrollView.scrollEnabled = YES;
	scrollView.pagingEnabled = YES;
    textMatterArray = [[NSArray alloc] initWithObjects: @"Launch Reportable and record audio, take a photo or video, or write a note. You can also import media from your camera roll.", @"Then, tap on the file to edit the metadata. Scroll down to fill in caption and copyright information. All metadata is automatically embedded in the file.", @"If you want to share a summary overview or our media, tap on Select, then PDF.The document will contain thumbnails of your media and the correspoing metadata.",@"You can share files with your co-workers by email, iMessage or by exporting to your Dropbox.",nil];
    NSString *str=[textMatterArray objectAtIndex:0];
    [tutorialLabel setText:str];
	NSUInteger nimages = 0;
	CGFloat cx = 0;
	for (; ; nimages++) {
		NSString *imageName = [NSString stringWithFormat:@"image%d.png", (int)(nimages + 1)];
		UIImage *image = [UIImage imageNamed:imageName];
		if (image == nil) {
			break;
		}
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		CGRect rect = imageView.frame;
		rect.size.height = image.size.height;
		rect.size.width = scrollView.frame.size.width-60;
		rect.origin.x =  cx+30;
		rect.origin.y = ((scrollView.frame.size.height - image.size.height) / 2)-(IS_IPHONE5?50:70);
        imageView.contentMode=UIViewContentModeScaleAspectFit;
		imageView.frame = rect;
		[scrollView addSubview:imageView];
		cx += scrollView.frame.size.width;
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	}
	self.pageControl.numberOfPages = nimages;
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];    
}

/**
 *  Skip tutorial
 *
 *  @param sender skipButton
 */
- (IBAction)skipButtonAction:(id)sender {
    if(self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
	// Detect page number and assign value to page control
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    if(pageControl.currentPage == 3 && !APP_DELEGATE.hasLaunchedOnce && shouldHideDone==NO)
        [self.navigationBar.topItem setRightBarButtonItem:doneButton];
    [tutorialLabel setText:[textMatterArray objectAtIndex:pageControl.currentPage]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
/**
 *  Called when user changes value of page control
 *
 *  @param sender pageControl
 */
- (IBAction)changePage:(id)sender
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}

- (void)viewDidUnload {
    [self setNavigationBar:nil];
    tutorialLabel = nil;
    doneButton = nil;
    [super viewDidUnload];
}
@end
