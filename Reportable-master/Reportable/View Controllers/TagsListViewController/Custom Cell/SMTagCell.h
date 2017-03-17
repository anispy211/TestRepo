//
//  CVCell.h
//  CollectionViewExample
//
//  Created by Tim on 9/5/12.
//  Copyright (c) 2016 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SMTagCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *titleLabelBGImageView;
@property (nonatomic, strong) IBOutlet UIImageView *thumbView;

@end
