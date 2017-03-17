//
//  Header.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 11/5/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#ifndef SpaceMarker_Header_h
#define SpaceMarker_Header_h


#pragma mark - logging

/*
 LOG -- calls NSLog only if DEBUG is defined
 */
#ifdef DEBUG
#define LOG(...) // NSLog{__VA_ARGS__)
#else
#define LOG(...) /* */
#endif

// System Version (iOS)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 LOGLINE -- calls NSLog only if DEBUG is defined, also adds in file, line numbers
 */
#define MAXIMUM_DURATION_FOR_AUDIO_IN_MINUTES 3.0
#ifdef DEBUG
#define LOGLINE(fmt, ...) // NSLog{(@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define FTLOGCALL LOG(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#define LOGLINE(...) /* */
#define FTLOGCALL /* */
#endif

#define PCRELEASE(_obj) _obj = nil

#define REPORTABLE_DARK_TEXT_COLOR [UIColor colorWithRed:43.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]
#define REPORTABLE_ORANGE_COLOR [UIColor colorWithRed:200/255.0 green:94/255.0 blue:19/255.0 alpha:1]
#define REPORTABLE_CREAM_COLOR [UIColor colorWithRed:242/255.0 green:240/255.0 blue:237/255.0 alpha:1]
#define PLACEHOLDER_TEXT_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]


#define POINT_SABRE  1
#define POINT_FOIL   2
#define POINT_EPEE   3

#pragma mark - screen size macro
#define ASSET_BY_SCREEN_HEIGHT(regular, longScreen) (([[UIScreen mainScreen] bounds].size.height <= 480.0) ? regular : longScreen)

#define UPDATE_LIST @"UPDATE_LIST"
#define NOTIFICATION_LOCATION_FAILED   @"NOTIFICATION_LOCATION_FAILED"
#define NOTIFICATION_LOCATION_UPDATED   @"NOTIFICATION_LOCATION_UPDATED"
#define FILE_SHARED_SUCCESSFULLY @"FILE_SHARED_SUCCESSFULLY"
#define UPDATE_REPORT_LIST @"UPDATE_REPORT_LIST"
#define ADDED_NEW_TAG @"ADDED_NEW_TAG"
#define DROPBOX_LINKING_DONE @"DROPBOX_LINKING_DONE"

#define THUMBNAIL_IMAGE     @"THUMBNAIL_IMAGE"
#define THUMBNAIL_VIDEO     @"THUMBNAIL_VIDEO"

#define FONT_REGULAR UIFont fontWithName:@"DIN-Regular"
#define FONT_MEDIUM UIFont fontWithName:@"DIN-Medium"
#define FONT_LIGHT UIFont fontWithName:@"DIN-Light"

#define FONT_SIZE_FOR_CELL 17.0
#define FONT_SIZE_FOR_TAG 13.0
#define FONT_SIZE_FOR_SETTINGS_CELL 15.0
#define FONT_SIZE_FOR_SECTION_HEADER 14.0
#define FONT_SIZE_FOR_LABEL 17.0
#define FONT_SIZE_FOR_TIMER_LABEL 52.0
#define FONT_SIZE_FOR_NAVIGATION_BAR_BUTTONS 12.0

#define k_ANIMATION 0.35

#define DEFAULT_RESPONDER_HEIGHT 216

#define MAXIMUM_LINES_LIMIT_FOR_CAPTION_FIELD 30
#define MAXIMUM_CHARACTERS_LIMIT_FOR_FILENAME 30

#define kMaximumHeight [[[[[UIApplication sharedApplication] delegate] window].rootViewController view] bounds].size.height * 16
#define kMinimumHeight ([[[[[UIApplication sharedApplication] delegate] window].rootViewController view] bounds].size.height - ([[UIApplication sharedApplication] isStatusBarHidden]?0:STATUS_BAR_HEIGHT))
#define kMaximumCharacterCountForNote 1000

// Constants used to represent your AWS Credentials.
#define ACCESS_KEY_ID          @"AKIAI7WS2JAEPFRONRYA"
#define SECRET_KEY             @"jwn5MFpOTU4VuuHIqA32wyKS8dFUA9lbpDzGZkAx"
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define APP_DELEGATE ((SMAppDelegate*)[[UIApplication sharedApplication] delegate])
#define IS_RETINA (([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)?YES:NO)
#define SCREEN_WIDTH  320
#define SCREEN_HEIGTH 480

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

typedef enum
{
    AudioTagType = 1,
    VideoTagType,
    PhotoTagType,
    NoteTagType
}TagType;


#endif
