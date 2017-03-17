//
//  SMDropboxActivity.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 20/03/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMDropboxActivity;

@protocol SMDropboxActivityDelegate <NSObject>

-(void)delegatedDropboxActivitySelected;

@end
@interface SMDropboxActivity : UIActivity
@property (nonatomic,weak) id <SMDropboxActivityDelegate> delegate;
@end
