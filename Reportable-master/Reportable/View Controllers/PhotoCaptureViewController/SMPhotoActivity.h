//
//  SMPhotoActivity.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMPhotoActivityDelegate

- (void)startTakingPhoto;

@end

@interface SMPhotoActivity : UIActivity


+ (NSString*)activityTypeString;

@property id<SMPhotoActivityDelegate> delegate;

@end
