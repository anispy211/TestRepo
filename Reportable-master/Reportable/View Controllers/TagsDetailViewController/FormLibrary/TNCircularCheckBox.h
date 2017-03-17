//
//  TNCircleCheckBox.h
//  TNCheckBox
//
//  Created by Frederik Jacques on 02/04/14.
//  Copyright (c) 2016 Frederik Jacques. All rights reserved.
//

#import "TNCheckBox.h"

@interface TNCircularCheckBox : TNCheckBox

@property (nonatomic, strong) TNCircularCheckBoxData *data;

- (instancetype)initWithData:(TNCircularCheckBoxData *)data;
- (void)checkWithAnimation:(BOOL)animated;


@end
