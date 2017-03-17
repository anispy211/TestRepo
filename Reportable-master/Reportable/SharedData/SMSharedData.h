//
//  SMSharedData.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 05/11/12.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>


@class SMTag;
@interface SMSharedData : NSObject
{
    

    NSMutableArray *tags;
}
@property (nonatomic,strong) UIWindow *mainWindow;
@property (nonatomic, readonly) NSMutableArray *tags;
@property (nonatomic) NSDateFormatterStyle dateFormat;
@property (nonatomic) NSString *deviceLocation;

@property (nonatomic, assign) CGRect currentTagsFrame;

@property BOOL isFileBeingOpened;
@property BOOL shouldAutorotate;
+ (SMSharedData*)sharedManager;
- (void)addNewTag:(SMTag *)tag;
- (NSInteger)checkIfTagExistsWithName:(NSString *)name;
- (void)removeTags:(NSSet *)objects;
- (NSArray*)photoTags;
- (NSArray*)audioTags;
- (NSArray*)videoTags;
- (void)savePDFPath:(NSString *)path withName:(NSString *)name;
- (void)setupApplicationDataFile;
- (void) addDefaultStampsToTag : (SMTag *)tag;
- (NSURL *)getPhotoUrlWithMetadata:(UIImage *)img withMetaData:(SMTag *)photoTag withName:(NSString *)fileName;
@end
