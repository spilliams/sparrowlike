//
//  CustomTableViewController.h
//  Sparrowlike
//
//  Created by Spencer Williams on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomCell;
@class SLPanningTableView;
@class SLPanningTableViewCell;

@interface CustomTableViewController : UIViewController <UITableViewDataSource, UIGestureRecognizerDelegate,UITableViewDelegate,
                                                                UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet SLPanningTableView *tableView;
@end
