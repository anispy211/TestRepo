//
//  SMDropboxCustomCell.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 26/03/14.
//  Copyright (c) 2016 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMDropboxCustomCell : UITableViewCell{
}
@property (strong, nonatomic) IBOutlet UILabel *filenameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkMark;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

@end
