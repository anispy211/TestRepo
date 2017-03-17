//
//  SMSettingsActivity.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 2/19/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMSettingsActivity.h"
@interface SMSettingsActivity()

@property (nonatomic, copy) NSArray *activityItems;

@end
@implementation SMSettingsActivity



+ (NSString *)activityTypeString
{
    return @"";
}

- (NSString *)activityType {
    return [SMSettingsActivity activityTypeString];
}

- (NSString *)activityTitle {
    return @"Settings";
}
- (UIImage *)activityImage {
    return [UIImage imageNamed:@"note.png"];
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

}

- (UIViewController *)activityViewController {
    return nil;
}

@end
