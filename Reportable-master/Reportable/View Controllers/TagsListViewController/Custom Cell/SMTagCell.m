//
//  CVCell.m
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c)  2016 Charismatic Megafauna Ltd. All rights reserved.
//

#import "SMTagCell.h"

@implementation SMTagCell
@synthesize titleLabel = _titleLabel;
@synthesize titleLabelBGImageView = _titleLabelBGImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"SMTagCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.titleLabelBGImageView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(2, 2)]; //add corner radius to title label of file
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.titleLabelBGImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        [self.titleLabel setFont:[FONT_REGULAR size:FONT_SIZE_FOR_TAG]];
        self.titleLabelBGImageView.layer.mask = maskLayer;
    }
    return self;
}

@end
