//
//  SMDateFormatterViewController.h

//  FencingApp
//
//  Created by Aniruddha Kadam on 13/06/13.
//  Copyright (c) 2013 Krushnai Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMDateFormatterViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    NSInteger lastSelectedCell;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)doneButtonAction:(id)sender;

@end
