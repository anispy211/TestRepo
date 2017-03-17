//
//  Utility.h

//  FencingApp
//
//  Created by Dinesh B Gore on 05/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMDropboxActivity.h"
#import <AVFoundation/AVFoundation.h>

@interface Utility : NSObject {
   
}
+(void)applyReportableNavigationBarPropertiesToNavigationBar:(UINavigationBar *)navBar;
+ (void)presentShareActivitySheetForViewController:(UIViewController *)viewController andObjects:(NSArray *)activitiesItems andTagType:(NSInteger)tagType andSubjectLine:(NSString *)subjectLine;
+ (NSURL *) dataStoragePath;
+ (BOOL)connectedToInternet;
+ (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *) thumbnailFromVideo:(NSURL *)movieURL atTime:(NSTimeInterval)time;
+ (UIImage*) addImage:(UIImage *)image secondImage:(UIImage *)image2;
+ (UIImage*) imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
+(BOOL)color:(UIColor *)color1 matchesColor:(UIColor *)color2;
+ (UIImage*)addImageForReportFirstImage:(UIImage *)image1 secondImage:(UIImage *)image2;
@end
