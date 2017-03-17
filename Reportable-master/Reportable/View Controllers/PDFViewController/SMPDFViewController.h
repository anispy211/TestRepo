//
//  SMPDFViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 23/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SMDropboxActivity.h"
#import "MBProgressHUD.h"
#import "SMDropboxListViewController.h"


#define kBorderInset            30.0
#define kBorderWidth            1.0
#define kMarginInset            10.0

//Line drawing
#define kReportHeaderLineWidth              3.0
#define kLineWidth              1.0

#define kImageHeaderGap         25
#define kNoteHeaderGap          25

#define kImageGap               35
#define kNoteGap                35

@protocol SMPDFViewControlerDelegate <NSObject>

-(void)cancelPDFWithMode;

@end

@interface SMPDFViewController : UIViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,UIWebViewDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,SMDropboxActivityDelegate,SMDropboxViewControllerDelegate,DBRestClientDelegate,SMDropboxProgressDelegate>
{
    CGSize pageSize;
    NSMutableArray *tags;
    NSInteger currentPage;
    NSInteger currentHeight;
    NSString *textString;
    NSString *fileName;
    NSString *pdfUsername;
    NSMutableArray *sharedTags;
    NSString *notesText;
    NSString *dateString1;
    NSURL *tempURL;
    BOOL isSavedPDF;
    IBOutlet UIButton *doneButton;
    IBOutlet UIButton *mainBackButton;
    IBOutlet UIButton *mainShareButton;
}

@property (nonatomic,strong)IBOutlet SMNavigationBar *navigationBar;
@property(nonatomic, strong) IBOutlet UIWebView *webViewPDF;
@property (nonatomic, strong)  IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic, strong)  NSURL *pdfFilePath;
@property (nonatomic, unsafe_unretained) id <SMPDFViewControlerDelegate> delegate;
@property(nonatomic, strong) NSMutableString * pdfPassword;

- (IBAction)backButtonAction:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withReportName:(NSString *)reportName andTag:(SMTag *)tag;
- (void) generatePdfWithFilePath: (NSString *)thefilePath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andArrayOfTags:(NSMutableArray *)tagsArray andPassword:(NSString *)password andReportName:(NSString *)reportName andUsername:(NSString *)username andNotes:(NSString *)notes andDateString:(NSString *)dateString;

@end
