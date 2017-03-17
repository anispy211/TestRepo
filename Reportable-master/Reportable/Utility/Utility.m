//
//  Utility.m

//  FencingApp
//
//  Created by Dinesh B Gore on 05/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import "Utility.h"
#import <MediaPlayer/MediaPlayer.h>

#define radians(degrees) (degrees * M_PI/180)


@implementation Utility

/**
 *  Returns default storage URL to store files locally
 *
 *  @return data storage URL
 */
+ (NSURL *)dataStoragePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:cachePath];
    return url;
}

/**
 *  Returns scaled image
 *
 *  @param image   original image
 *  @param newSize size to scale to
 *
 *  @return scaled image
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  Returns thumbnail for image captured at time
 *
 *  @param movieURL URL of the video
 *  @param time     time to capture thumbnail at
 *
 *  @return thumbnail images
 */
+ (UIImage *)thumbnailFromVideo:(NSURL *)movieURL atTime:(NSTimeInterval)time
{
    // set up the movie player
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc]
                                   initWithContentURL:movieURL];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = time;
    mp.currentPlaybackTime = time;
    // get the thumbnail
    UIImage *thumbnail = [mp thumbnailImageAtTime:time timeOption:MPMovieTimeOptionNearestKeyFrame];
    // clean up the movie player
    [mp stop];
    return(thumbnail);
}

/**
 *  Masks an image over another image
 *
 *  @param image1 image beloe
 *  @param image2 image above
 *
 *  @return masked image
 */
+ (UIImage*)addImage:(UIImage *)image1 secondImage:(UIImage *)image2
{
    UIImage *bottomImage = image1;
    UIImage *image = image2;
    CGSize newSize = CGSizeMake(image1.size.width, image1.size.height);
    UIGraphicsBeginImageContext( newSize );
    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [image drawInRect:CGRectMake(0,0,newSize.width ,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  Returns image to be embedded in report created by masking two images
 *
 *  @param image1 image below
 *  @param image2 image above
 *
 *  @return masked image
 */
+ (UIImage*)addImageForReportFirstImage:(UIImage *)image1 secondImage:(UIImage *)image2
{
    UIImage *bottomImage = image1;
    UIImage *image = image2;
    CGSize newSize = CGSizeMake(image1.size.width, image1.size.height);
    UIGraphicsBeginImageContext( newSize );
    //  Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //  Apply supplied opacity
    [image drawInRect:CGRectMake(image1.size.width/2-image2.size.width/2,image1.size.height/2-image2.size.height/2,image2.size.width ,image2.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  Applies properties to navigation bar according to Reportable style
 *
 *  @param navBar customized navigation bar
 */
+(void)applyReportableNavigationBarPropertiesToNavigationBar:(UINavigationBar *)navBar{
    navBar.opaque = YES;
    navBar.backgroundColor = [UIColor clearColor];
    navBar.tintColor = [UIColor clearColor];
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        UIImage *image = [UIImage imageNamed:@"navigationBar.png"];
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    UIFont *font = [FONT_REGULAR size:(navBar.tag==100)?17.0:19.0];
    UIButton *button =(UIButton *)navBar.topItem.rightBarButtonItem.customView;
    [button.titleLabel setTextColor:REPORTABLE_CREAM_COLOR];
    [button.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    button.titleEdgeInsets = UIEdgeInsetsMake(3.5, 0, 0, 0);
    [button setTitleColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    button =(UIButton *)navBar.topItem.leftBarButtonItem.customView;
    
    [button setTitleColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [button.titleLabel setTextColor:REPORTABLE_CREAM_COLOR];
    button.titleEdgeInsets = UIEdgeInsetsMake(3.5, 0, 0, 0);
    [button.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS]];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  font, NSFontAttributeName,
                                  REPORTABLE_CREAM_COLOR, NSForegroundColorAttributeName,
                                  [UIColor blackColor], UITextAttributeTextShadowColor,
                                  [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                  nil]];
    [navBar setTitleVerticalPositionAdjustment:0.8 forBarMetrics:UIBarMetricsDefault];
}

/**
 *  Image scaled by given size to match aspect ratio
 *
 *  @param sourceImage image to scale
 *  @param targetSize  size to scale image at
 *
 *  @return scaled image
 */
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo =CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    bitmapInfo =kCGImageAlphaNoneSkipLast;
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
        CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
        alphaInfo = kCGImageAlphaNone;
        //I noticed, that the result was better, if I resized it to 360 instead of 320 and then manually cropped it. There will be of course a tiny part missing, but if you think about it, it will make sense. If you resize 1600x1200 to 480x320 you can not constrain proportions. Try it in photoshop :)
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

/**
 *  Present activity sheet to allow user to share files via iMessage,Dropbox or mail
 *
 *  @param viewController  view controller to present activity sheeet to
 *  @param activitiesItems application activities
 *  @param tagType         type of file
 *  @param subjectLine     subject line to be added as mail composer's subject
 */
+ (void)presentShareActivitySheetForViewController:(UIViewController *)viewController andObjects:(NSArray *)activitiesItems andTagType:(NSInteger)tagType andSubjectLine:(NSString *)subjectLine
{
    SMDropboxActivity *dropboxActivity= [[SMDropboxActivity alloc] init];
    [dropboxActivity setDelegate:viewController];
    NSArray *applicationActivities = [NSArray arrayWithObject:dropboxActivity];
    NSMutableArray *customActivityItems = [NSMutableArray arrayWithArray:activitiesItems];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:customActivityItems applicationActivities:applicationActivities];
    // Removed un-needed activities
    [activityVC setValue:subjectLine forKey:@"subject"];
    
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SHARED_SUCCESSFULLY object:activityType];
            // NSLog{@"The selected activity was %@", activityType);
        }
    };
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypePostToFacebook,
                                            UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList,
                                            UIActivityTypePostToTwitter,UIActivityTypePostToFlickr,
                                            UIActivityTypeAssignToContact,UIActivityTypePostToVimeo,
                                            UIActivityTypePrint,UIActivityTypePostToTencentWeibo,
                                            UIActivityTypeAirDrop,
                                            nil];
    else
        activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypePostToFacebook,
                                            UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypePostToTwitter,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypePrint,(tagType==2 || tagType == 1)?UIActivityTypeMessage:nil,
                                            nil];
    [viewController presentViewController:activityVC animated:YES completion:nil];
}

/**
 *  Returns if device is connected to internet
 *
 *  @return network status
 */
+ (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"https://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}

/**
 *  Returns if a color matches another color
 *
 *  @param color1 first color
 *  @param color2 second color
 *
 *  @return true if colors match or false
 */
+(BOOL)color:(UIColor *)color1 matchesColor:(UIColor *)color2
{
    CGFloat red1, red2, green1, alpha1, green2, blue1, blue2, alpha2;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    // NSLog{@"Color 1 : %f , %f, %f ,%f ",red1,green1,blue1,alpha1);
    // NSLog{@"Color 2 : %f , %f, %f ,%f ",red2,green2,blue2,alpha2);
    
    return (red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2);
}
@end
