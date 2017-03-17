//
//  SMNavigationBar.m

//  FencingApp
//
//  Created by Aniruddha Kadam on 3/12/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import "SMNavigationBar.h"
#import "Utility.h"

@implementation SMNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [Utility applyReportableNavigationBarPropertiesToNavigationBar:self];
    }
    return self;
}

@end
