//
//  SMPDFViewController.m
//  SpaceMarker
//
//  Created by Aniruddha Kadam on 23/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "SMPDFViewController.h"
#import "SMTag.h"
#import "Utility.h"
#import "SMLocationTracker.h"
#import "SMSharedData.h"
#import "SMDropboxProgressViewController.h"

@implementation SMPDFViewController{
    SMDropboxProgressViewController *progressVC;
    SMTag *currentTag;
}
@synthesize webViewPDF;
@synthesize delegate;
@synthesize pdfPassword;
@synthesize backButton;
@synthesize navigationBar;
@synthesize pdfFilePath;
@synthesize statusBarView;

- (IBAction)backButtonAction:(id)sender {
    NSSet *set = [NSSet setWithObject:[[[SMSharedData sharedManager] tags] objectAtIndex:0]];
    [[SMSharedData sharedManager] removeTags:set];
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andArrayOfTags:(NSMutableArray *)tagsArray andPassword:(NSString *)password andReportName:(NSString *)reportName andUsername:(NSString *)username andNotes:(NSString *)notes andDateString:(NSString *)dateString
{
    // Custom initialisation method
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        tags = [[NSMutableArray alloc] initWithArray:tagsArray];
        sharedTags= [[NSMutableArray alloc] initWithArray:[[SMSharedData sharedManager] tags]];
        fileName = reportName;
        pdfUsername = username;
        notesText = notes;
        if (password == nil)
            pdfPassword = nil;
        else
            pdfPassword = [NSMutableString stringWithString:password];
        dateString1 = dateString;
    }
    webViewPDF.delegate = self;
    isSavedPDF = NO;
    [self generate];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withReportName:(NSString *)reportName andTag:(SMTag *)tag
{
    currentTag = tag;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        fileName = reportName;
    webViewPDF.delegate = self;
    NSURL *pdfURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", reportName]];
    [self performSelector:@selector(showPDF:) withObject:pdfURL.path afterDelay:0.1];
    isSavedPDF = YES;
    [self generate];
    return self;
}

-(void)generate{
    pageSize = CGSizeMake(800, 1280);
    currentPage = 0;
    if([tags count] > 0)
    {
        self.pdfFilePath = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
        [self generatePdfWithFilePath:self.pdfFilePath
         .path ];
    }
}
#pragma mark -Drawing Methods
/**
 *  Writes page number as a footer
 *
 *  @param pageNumber page number
 */
- (void)drawPageNumber:(NSInteger)pageNumber
{
    NSString* pageNumberString = [NSString stringWithFormat:@"Page %ld", (long)pageNumber];
    NSString* footerText = [NSString stringWithFormat:@"Created in Reportable"];
    
    UIFont* theFont = [FONT_REGULAR size:12];
    
    CGSize pageNumberStringSize = [pageNumberString sizeWithFont:theFont
                                               constrainedToSize:pageSize
                                                   lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect stringRenderingRect = CGRectMake(kBorderInset,
                                            pageSize.height - 40.0,
                                            pageSize.width - 2*kBorderInset,
                                            pageNumberStringSize.height);
    
    [pageNumberString drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
    [footerText drawInRect:stringRenderingRect withFont:theFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}

/**
 *  Draws header string in specified rect with given font
 *
 *  @param header header string
 *  @param font   font to be used
 *  @param rect   rect to draw string in
 */
- (void) drawHeader:(NSString *)header withfont:(UIFont *)font inRect:(CGRect)rect
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.20, 0.20, 0.20, 1.0);
    [header drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
}

- (void) drawText:(NSString *)textStr OfTag:(SMTag *)tag
{
    UIFont *font = [FONT_REGULAR size:16.0];
    CGSize stringSize = [textStr sizeWithFont:font
                            constrainedToSize:CGSizeMake(700 ,1000)
                                lineBreakMode:NSLineBreakByWordWrapping];
    //Add new Page
    if ((currentHeight + stringSize.height + 3*kNoteGap + 60) > pageSize.height - 100)
    {
        NSDictionary *dict;
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
        currentHeight = kNoteHeaderGap;
        //Draw Page Number at the bottom
        currentPage++;
        [self drawPageNumber:currentPage];
    }
    // Draw Header
    [self drawNoteHeaderForTag:tag];
    //Draw text
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.20, 0.20, 0.20, 1.0);
    currentHeight = currentHeight + 2* kMarginInset;
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, currentHeight, 700, stringSize.height);
    [textStr drawInRect:renderingRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    currentHeight = currentHeight + stringSize.height + 2* kMarginInset;
}

- (void) drawImage:(UIImage *)image OfTag:(SMTag *)tag
{
    //Scaling logic
    if (image.size.height > 300){
        int width = (image.size.width / image.size.height )* 300;
        image = [Utility imageWithImage:image scaledToSize:CGSizeMake(width, 300)];
    }
    if (image.size.width > 300 ){
        int height = (image.size.height / image.size.width) * 300;
        image = [Utility imageWithImage:image scaledToSize:CGSizeMake(300, height)];
    }
    //Add new Page
    if ((currentHeight + image.size.height + 3*kImageGap + 60) > pageSize.height - 100){
        NSDictionary *dict;
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
        currentHeight =  kImageHeaderGap;
        //Draw Page Number at the bottom
        currentPage++;
        [self drawPageNumber:currentPage];
    }
    // Draw header
    [self drawImageHeader:tag];
    [image drawInRect:CGRectMake(kBorderInset + kMarginInset, currentHeight+40, image.size.width, image.size.height)];
    currentHeight = currentHeight + image.size.height + 2*kImageHeaderGap;
}

#pragma mark - Draw Lines
- (void) drawLineBelowHeader
{
    // Draws line at current height leaving offset
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, kReportHeaderLineWidth);
    CGContextSetStrokeColorWithColor(currentContext, [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1.0].CGColor);
    CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset, currentHeight);
    CGPoint endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset, currentHeight);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    currentHeight = currentHeight + kMarginInset;
}

- (void) drawLineAtDistance:(float)dist shouldDrawFull:(BOOL)full
{
    // Draws line at given distance leaving offset
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, kLineWidth);
    CGContextSetStrokeColorWithColor(currentContext, [UIColor grayColor].CGColor);
    CGPoint startPoint = CGPointMake(kMarginInset + kBorderInset,currentHeight+kMarginInset);
    if(startPoint.y>pageSize.height*0.9)
        return;
    CGPoint endPoint;
    if(full)
        endPoint = CGPointMake(pageSize.width - 2*kMarginInset -2*kBorderInset,currentHeight+kMarginInset);
    else
        endPoint = CGPointMake(pageSize.width *0.1,currentHeight+kMarginInset);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFillStroke);
    currentHeight = currentHeight + kMarginInset;
}

-(BOOL)shouldAutorotate{
    return NO;
}

#pragma mark - Draw Headers

/**
 *  Draw header of the report
 */
-(void)drawReportHeader
{
    NSString *headerString = nil;
    int increment = (15+5)*(IS_RETINA?2:1);
    CGRect renderingRect;
    headerString = [fileName substringToIndex:([fileName length]-4)];
    renderingRect = CGRectMake(kBorderInset + kMarginInset, increment, pageSize.width - 2*kBorderInset - 2*kMarginInset, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:26.0] inRect:renderingRect];
    
    headerString = [NSString stringWithFormat:@"Date Created : %@",dateString1];
    renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset+increment, pageSize.width - 2*kBorderInset - 2*kMarginInset, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:18.0] inRect:renderingRect];
    increment  = increment + 20;
    
    if (pdfUsername && ![pdfUsername isEqualToString:@""]){
        headerString = [NSString stringWithFormat:@"Created by : %@",pdfUsername];
        renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset +increment, pageSize.width - 2*kBorderInset - 2*kMarginInset, 50);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:18.0] inRect:renderingRect];
        increment  = increment + 20;
    }
    
    if(notesText && ![notesText isEqualToString:@""]){
        headerString = [NSString stringWithFormat:@"Notes : %@",notesText];
        CGSize stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:18.0]
                                     constrainedToSize:CGSizeMake(700 ,1000)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset +increment, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:18.0] inRect:renderingRect];
        increment  = increment + stringSize.height;
    }
    currentHeight = 2*kBorderInset+increment;
}

/**
 *  Get string from the date specified in the format selected by user in settings.
 *
 *  @param date date to be converted
 *
 *  @return string converted by date
 */
- (NSString *)getDateInReadableFormatWithDate:(NSDate *)date shouldShowTime:(BOOL)shouldShowTime{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:[SMSharedData sharedManager].dateFormat];
    if (shouldShowTime)
        [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *dateToreturn = [NSString stringWithFormat:@"%@",dateString];
    return  dateToreturn;
}


/**
 *  Draw header information for the file on PDF
 *
 *  @param tag file to write information about
 */
-(void)drawNoteHeaderForTag:(SMTag *)tag
{
    NSString *headerString = nil;
    NSString *tagHeader = tag.name;
    headerString = [NSString stringWithFormat:@"Title : "];
    CGSize stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                                 constrainedToSize:CGSizeMake(700 ,1000)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + currentHeight, stringSize.width, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
    CGSize stringSize2 = [tagHeader sizeWithFont:[FONT_REGULAR size:16.0]
                               constrainedToSize:CGSizeMake(700 ,1000)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width, kBorderInset + kMarginInset + currentHeight, stringSize2.width, 50);
    [self drawHeader:tagHeader withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
    currentHeight = currentHeight + 20;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E MMMM d, YYYY"];
    NSString *dateString = [self getDateInReadableFormatWithDate:tag.dateTaken shouldShowTime:NO];
    headerString = [NSString stringWithFormat:@"Date Created : "];
    stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                          constrainedToSize:CGSizeMake(700 ,1000)
                              lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + currentHeight, stringSize.width, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
    stringSize2 = [dateString sizeWithFont:[FONT_REGULAR size:16.0]
                         constrainedToSize:CGSizeMake(700 ,1000)
                             lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width, kBorderInset + kMarginInset + currentHeight, stringSize2.width, 50);
    [self drawHeader:dateString withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
    currentHeight = currentHeight + 20;
    if(tag.address && ![tag.address isEqualToString:@""]){
        headerString = [NSString stringWithFormat:@"Location : "];
        CGSize stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                                     constrainedToSize:CGSizeMake(700 ,1000)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + currentHeight, stringSize.width, 50);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
        
        CGSize stringSize2 = [tag.address sizeWithFont:[FONT_REGULAR size:16.0]
                                     constrainedToSize:CGSizeMake(700 ,1000)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width, kBorderInset + kMarginInset + currentHeight, stringSize2.width, 50);
        
        if (renderingRect.size.width+renderingRect.origin.x >= pageSize.width - 2*kMarginInset) {
            currentHeight=currentHeight+30;
            renderingRect = CGRectMake(kBorderInset + kMarginInset,stringSize.height+ 5+currentHeight,stringSize2.width, stringSize2.height);
        }
        [self drawHeader:tag.address withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
        currentHeight = currentHeight +  stringSize2.height;
    }
    currentHeight = currentHeight +  kNoteGap;
}

/**
 *  Draw header information for image file
 *
 *  @param tag image file
 */
-(void)drawImageHeader:(SMTag *)tag
{
    currentHeight = currentHeight + kImageHeaderGap;
    NSString *headerString = nil;
    CGRect renderingRect;
    NSString *tagHeader =  tag.name;
    headerString = [NSString stringWithFormat:@"Title : "];
    CGSize stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                                 constrainedToSize:CGSizeMake(700 ,1000)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset,  kMarginInset + currentHeight, stringSize.width, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
    CGSize stringSize2 = [tagHeader sizeWithFont:[FONT_REGULAR size:16.0]
                               constrainedToSize:CGSizeMake(700 ,1000)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width,  kMarginInset + currentHeight, stringSize2.width, 50);
    [self drawHeader:tagHeader withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
    currentHeight = currentHeight + 20;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"E MMMM d, YYYY"];
    NSString *dateString = [self getDateInReadableFormatWithDate:tag.dateTaken shouldShowTime:NO];
    headerString = [NSString stringWithFormat:@"Date Created : "];
    stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                          constrainedToSize:CGSizeMake(700 ,1000)
                              lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset,  kMarginInset+ currentHeight,stringSize.width, 50);
    [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
    stringSize2 = [dateString sizeWithFont:[FONT_REGULAR size:16.0]
                         constrainedToSize:CGSizeMake(700 ,1000)
                             lineBreakMode:NSLineBreakByWordWrapping];
    renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width,  kMarginInset + currentHeight, stringSize2.width, 50);
    [self drawHeader:dateString withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
    currentHeight = currentHeight + 20;
    if(tag.address && ![tag.address isEqualToString:@""]){
        headerString = [NSString stringWithFormat:@"Location : "];
        stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                              constrainedToSize:CGSizeMake(700 ,1000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        renderingRect = CGRectMake(kBorderInset + kMarginInset,  kMarginInset+ currentHeight,stringSize.width, 50);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
        stringSize2 = [tag.address sizeWithFont:[FONT_REGULAR size:16.0]
                              constrainedToSize:CGSizeMake(700 ,1000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width,  kMarginInset + currentHeight, stringSize2.width, 50);
        [self drawHeader:tag.address withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
        currentHeight = currentHeight + kImageGap;
    }
}

#pragma mark - Generate and Show PDF Actions

/**
 *  Generate PDF at file specified
 *
 *  @param thefilePath path to store PDF
 */
- (void) generatePdfWithFilePath: (NSString *)thefilePath
{
    NSMutableData *pdfData = [NSMutableData data];
    if (pdfPassword != nil) {
        CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL,0,NULL,NULL);
        CFDictionarySetValue(dict, kCGPDFContextUserPassword, (__bridge const void *)(pdfPassword));
        CFDictionarySetValue(dict, kCGPDFContextOwnerPassword, (__bridge const void *)(pdfPassword));
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, (__bridge NSDictionary *)(dict));
        
    }
    else
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    BOOL doneFlag = NO;
    do
    {
        //Start a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        //Draw a page number at the bottom of each page.
        currentPage++;
        [self drawPageNumber:currentPage];
        //Draw text fo our header.
        [self drawReportHeader];
        //Draw a line below the header.
        [self drawLineBelowHeader];
        //Draw an image
        for(NSNumber *i in tags)
        {
            int ind= [i intValue];
            SMTag *tag = [sharedTags objectAtIndex:ind];
            switch ((int)(tag.type))
            {
                case 1: // Audio
                {
                    [self drawImage:[UIImage imageNamed:@"audio_icon_for_listView.png"] OfTag:tag];
                    [self drawCaptionForTag:tag];
                    [self drawLineAtDistance:currentHeight+10 shouldDrawFull:NO];
                }
                    break;
                case 2: // Video
                {
                    NSURL *videoURL = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", tag.name]];
                    UIImage *thumbImage = [Utility thumbnailFromVideo:videoURL atTime:0.2];
                    UIImage *image = [Utility imageWithImage:thumbImage scaledToSizeWithSameAspectRatio:CGSizeMake(thumbImage.size.width , thumbImage.size.height)];
                    image = [Utility addImageForReportFirstImage:image secondImage:[UIImage imageNamed:@"video_icon_for_listView.png"]];
                    [self drawImage:image OfTag:tag];
                    [self drawCaptionForTag:tag];
                    [self drawLineAtDistance:currentHeight+10 shouldDrawFull:NO];
                }
                    break;
                case 3: // Photo
                {
                    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", tag.name]];
                    [self drawImage:[UIImage imageWithContentsOfFile:url.path] OfTag:tag];
                    [self drawCaptionForTag:tag];
                    [self drawLineAtDistance:currentHeight+10 shouldDrawFull:NO];
                }
                    break;
                case 4: // Note
                {
                    NSString *stringLoremIpsum = @"";
                    NSURL *url = [[Utility dataStoragePath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", tag.name]];
                    NSData *data = [NSData dataWithContentsOfFile:url.path];
                    textString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    textString = [textString stringByAppendingString:stringLoremIpsum];
                    [self drawText:textString OfTag:tag];
                    [self drawCaptionForTag:tag];
                    [self drawLineAtDistance:currentHeight shouldDrawFull:NO];
                }
                    break;
                default:
                    break;
            }
        }
        doneFlag = YES;
    }
    while (!doneFlag);
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    tempURL =[NSURL URLWithString: [cachesPath stringByAppendingPathComponent:@"file.pdf"]];
    [pdfData writeToFile:tempURL.path atomically:YES];
    [pdfData writeToFile:thefilePath atomically:YES];
}

/**
 *  Draw caption of the specified file at current height
 *
 *  @param tag file
 */
-(void)drawCaptionForTag:(SMTag *)tag{
    NSString *headerString;
    CGSize stringSize;
    CGSize stringSize2;
    CGRect renderingRect;
    if(tag.caption && ![tag.caption isEqualToString:@""])
    {
        headerString = [NSString stringWithFormat:@"Caption : "];
        stringSize  = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                               constrainedToSize:CGSizeMake(700 ,1000)
                                   lineBreakMode:NSLineBreakByWordWrapping];
        //Add new Page
        if ((currentHeight + stringSize.height + 3*kNoteGap + 60) > pageSize.height - 100)
        {
            
            NSDictionary *dict;
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
            currentHeight = kNoteHeaderGap;
            
            //Draw Page Number at the bottom
            currentPage++;
            [self drawPageNumber:currentPage];
        }
        renderingRect = CGRectMake(kBorderInset + kMarginInset,  currentHeight,stringSize.width, 50);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
        stringSize2 = [tag.caption sizeWithFont:[FONT_REGULAR size:16.0]
                              constrainedToSize:CGSizeMake(700 ,1000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        //Add new Page
        if ((currentHeight + stringSize2.height + 3*kNoteGap + 60) > pageSize.height - 100)
        {
            
            NSDictionary *dict;
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
            currentHeight = kNoteHeaderGap;
            //Draw Page Number at the bottom
            currentPage++;
            [self drawPageNumber:currentPage];
        }
        renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width,  currentHeight, stringSize2.width, stringSize2.height);
        if (renderingRect.size.width+renderingRect.origin.x >= pageSize.width - 2*kMarginInset) {
            currentHeight=currentHeight+30;
            renderingRect = CGRectMake(kBorderInset + kMarginInset, currentHeight,stringSize2.width, stringSize2.height);
        }
        [self drawHeader:tag.caption withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
        currentHeight = currentHeight + stringSize2.height + kMarginInset;
    }
    if(tag.copyright && ![tag.copyright isEqualToString:@""])
    {
        headerString = [NSString stringWithFormat:@"Credit : "];
        stringSize = [headerString sizeWithFont:[FONT_MEDIUM size:16.0]
                              constrainedToSize:CGSizeMake(700 ,1000)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        //Add new Page
        if ((currentHeight + stringSize.height + 3*kNoteGap + 60) > pageSize.height - 100)
        {
            
            NSDictionary *dict;
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
            currentHeight = kNoteHeaderGap;
            //Draw Page Number at the bottom
            currentPage++;
            [self drawPageNumber:currentPage];
        }
        renderingRect = CGRectMake(kBorderInset + kMarginInset, currentHeight,stringSize.width, 50);
        [self drawHeader:headerString withfont:[FONT_MEDIUM size:16.0] inRect:renderingRect];
        stringSize2 = [tag.copyright sizeWithFont:[FONT_REGULAR size:16.0]
                                constrainedToSize:CGSizeMake(700 ,1000)
                                    lineBreakMode:NSLineBreakByWordWrapping];
        //Add new Page
        if ((currentHeight + stringSize2.height + 3*kNoteGap + 60) > pageSize.height - 100)
        {
            
            NSDictionary *dict;
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), dict);
            currentHeight = kNoteHeaderGap;
            //Draw Page Number at the bottom
            currentPage++;
            [self drawPageNumber:currentPage];
        }
        renderingRect = CGRectMake(kBorderInset + kMarginInset+stringSize.width,  currentHeight, stringSize2.width, 50);
        [self drawHeader:tag.copyright withfont:[FONT_REGULAR size:16.0] inRect:renderingRect];
        currentHeight = currentHeight + stringSize2.height + kMarginInset;
    }
}

/**
 *  Display PDF located at path
 *
 *  @param filePath path of PDF file
 */
-(void)showPDF:(NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSURL *targetURL = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webViewPDF loadRequest:request];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"PDF Not Found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(isSavedPDF){
        // PDF is saved and being presented from home screen, so animate it.
        UIView *viewToFade=self.webViewPDF;
        CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
        f.origin.x  = f.origin.x + 10;
        CGRect firstFrame= viewToFade.frame;
        [viewToFade setFrame:f];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:firstFrame];
            [self.view setAlpha:1.0];
            [self.webViewPDF setAlpha:1.0];
        } completion:^(BOOL finished) {
            [mainShareButton setHidden:NO];
            [mainBackButton setHidden:NO];
            [backButton setHidden:NO];}];
    }
    else
        [self.webViewPDF setAlpha:1.0];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
}
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (isSavedPDF)
        [self.navigationBar.topItem setTitle:fileName];
    else
        [self.navigationBar.topItem setTitle:[fileName substringToIndex:[fileName rangeOfString:@"." options:NSBackwardsSearch].location]];
    [self.backButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [doneButton.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(3.5, 0, 0, 0);
    doneButton.titleEdgeInsets = UIEdgeInsetsMake(3.5, 0, 0, 0);
    if(isSavedPDF==NO){
        [navigationBar.topItem setTitle:[fileName substringToIndex:[fileName rangeOfString:@"."].location]];
        [navigationBar.topItem.rightBarButtonItem setCustomView:doneButton];
        [navigationBar.topItem.leftBarButtonItem setCustomView:self.backButton];
    }
    else
        [navigationBar.topItem setTitle:fileName];
}

-(void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(showPDF:) withObject:self.pdfFilePath.path afterDelay:0.0];
    if (isSavedPDF)
        [self.view setAlpha:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)savePDFAction:(id)sender {
    if(isSavedPDF)
    {
        // If is saved and opened from home screen, animate it to dismiss
        UIView *viewToFade=self.webViewPDF;
        CGRect f = [[SMSharedData sharedManager] currentTagsFrame];
        f.origin.x  = f.origin.x + self.webViewPDF.frame.origin.x;
        f.origin.y = f.origin.y+self.webViewPDF.frame.origin.y;
        [mainShareButton setHidden:YES];
        [mainBackButton setHidden:YES];
        [backButton setHidden:YES];
        [viewToFade setFrame:self.webViewPDF.frame];
        [UIView animateWithDuration:k_ANIMATION animations:^{
            [viewToFade setFrame:f];
            [self.view setAlpha:0.0];
            [[SMSharedData sharedManager] setIsFileBeingOpened:NO];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    if(delegate)
        [delegate cancelPDFWithMode];
}

/**
 *  Share PDF via iMessage,Dropbox or mail
 *
 *  @param sender actionButton
 */
- (IBAction)actionButtonAction:(id)sender {
    NSURL *pdfFileName = self.pdfFilePath;
    NSString *str=[[pdfFileName.path componentsSeparatedByString:@"/"] lastObject];
    NSString *fileNameToAttach = str;
    MFMailComposeViewController *picker;
    picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSArray *arr = [[NSArray alloc] initWithObjects:pdfFileName, nil];
    [self.view endEditing:YES];
    [Utility presentShareActivitySheetForViewController:self andObjects:arr andTagType:nil andSubjectLine:[[fileNameToAttach componentsSeparatedByString:@".pdf"] objectAtIndex:0]];
}

/**
 *  Called when user selects Dropbox for sharing PDF
 */
-(void)delegatedDropboxActivitySelected{
    [self dismissViewControllerAnimated:YES completion:^{
        if([Utility connectedToInternet]){
            if([[DBSession sharedSession] isLinked]){
                SMDropboxListViewController *dropboxListVC = [[SMDropboxListViewController alloc] initWithNibName:@"SMDropboxListViewController" bundle:nil andDirectory:@"" andMode:1];
                [dropboxListVC setDelegate:self];
                UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:dropboxListVC];
                [navigationVC setNavigationBarHidden:YES];
                [self presentViewController:navigationVC animated:YES completion:nil];
            }
            else
                [[DBSession sharedSession] linkFromController:self];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Please connect to internet to use dropbox" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

/**
 *  Delegate method called when user selects destination directory to export PDF to
 *
 *  @param path pathToExportPDFTo
 */
-(void)delegatedDropboxExportActionWithDirectoryPath:(NSString *)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:pdfFilePath.path])
    {
        [self dismissViewControllerAnimated:NO completion:^{
            // NSLog{@"Exists");
            NSString *destDir = path;
            [[[SMDropboxComponent sharedComponent] restClient] setDelegate:self];
            
            progressVC = [[SMDropboxProgressViewController alloc] initWithNibName:@"SMDropboxProgressViewController" bundle:nil];
            [self.view addSubview:progressVC.view];
            
            [progressVC setDelegate:self];
            [progressVC.dropboxProgressActivityIndicatorView startAnimating];
            [progressVC.dropboxProgressView setProgress:0.0f];
            [progressVC.dropboxProgressLabel setText:@"Exporting"];
            
            [[SMDropboxComponent sharedComponent].restClient uploadFile:pdfFilePath.path toPath:destDir withParentRev:nil fromPath:pdfFilePath.path];
            
        }];
    }
    else
    {
        // NSLog{@"File not found at path : %@",pdfFilePath.path);
    }
}

-(void)delegatedCancelButtonAction{
    [self savePDFAction:nil];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    [progressVC.dropboxProgressView setProgress:progress];
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath{
    // Exporting finished. Notify user.
    [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
    [progressVC.dropboxProgressActivityIndicatorView setHidden:YES];
    [progressVC.dropboxSuccessImageView setHidden:NO];
    [progressVC.dropboxProgressLabel setText:@"Exported"];
    [progressVC.dropboxCancelButton setEnabled:NO];
    [progressVC.dropboxDoneButton setEnabled:YES];
    [progressVC.dropboxProgressActivityIndicatorView stopAnimating];
}

@end
