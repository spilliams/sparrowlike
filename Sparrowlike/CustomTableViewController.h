//
//  CustomTableViewController.h
//  Sparrowlike
//
//  Created by Spencer Williams on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomCell;

@interface CustomTableViewController : UITableViewController <UITableViewDataSource, UIGestureRecognizerDelegate,
                                                                UIScrollViewDelegate>
@property (nonatomic) float openCellLastTX;
@property (nonatomic, strong) NSIndexPath *openCellIndexPath;
- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated;

@end
