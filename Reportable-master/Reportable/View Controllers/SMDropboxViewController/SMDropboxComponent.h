//
//  SMDropboxComponent.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 26/03/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
@interface SMDropboxComponent : NSObject <DBRestClientDelegate>
+ (SMDropboxComponent*)sharedComponent;
@property (nonatomic, strong) DBRestClient *restClient;
@end
