//
//  SMNoteActivity.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMNoteActivityDelegate

-(void) showNoteEditor;

@end
@interface SMNoteActivity : UIActivity

+ (NSString*)activityTypeString;
@property id<SMNoteActivityDelegate> delegate;

@end
