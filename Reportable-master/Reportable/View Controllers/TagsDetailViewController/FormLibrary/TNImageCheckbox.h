//
//  TNImageCheckBox.h
//  TNCheckBox
//
//  Created by Frederik Jacques on 02/04/14.
//  Copyright (c) 2016 Frederik Jacques. All rights reserved.
//

#import "TNCheckBox.h"

@interface TNImageCheckBox : TNCheckBox

@property (nonatomic, strong) TNImageCheckBoxData *data;

- (instancetype)initWithData:(TNImageCheckBoxData *)data;

@end
