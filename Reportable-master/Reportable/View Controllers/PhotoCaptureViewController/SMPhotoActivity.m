//
//  SMPhotoActivity.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMPhotoActivity.h"

@implementation SMPhotoActivity
@synthesize delegate;

+ (NSString *)activityTypeString
{
    return @"";
}

- (NSString *)activityType {
    return [SMPhotoActivity activityTypeString];
}

- (NSString *)activityTitle {
    return @"Photo";
}
- (UIImage *)activityImage {
    return [UIImage imageNamed:@"photos.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
};

- (void)prepareWithActivityItems:(NSArray *)activityItems {
       if(delegate)
        [delegate startTakingPhoto];
    
}

- (UIViewController *)activityViewController {
    return nil;
}





@end
