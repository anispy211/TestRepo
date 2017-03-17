//
//  SMVideoActivity.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 1/4/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMNoteActivity.h"


@interface SMNoteActivity()

@property (nonatomic, copy) NSArray *activityItems;

@end

@implementation SMNoteActivity

@synthesize delegate;


+ (NSString *)activityTypeString
{
    return @"";
}

- (NSString *)activityType {
    return [SMNoteActivity activityTypeString];
}

- (NSString *)activityTitle {
    return @"Note";
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
    if(delegate)
        [delegate showNoteEditor];
}

- (UIViewController *)activityViewController {
    return nil;
}



@end
