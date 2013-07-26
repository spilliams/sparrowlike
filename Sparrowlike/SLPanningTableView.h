//
//  SLPanningTableView.h
//  Sparrowlike
//
//  Created by Jay Chae  on 7/26/13.
//
//

#import <UIKit/UIKit.h>

@interface SLPanningTableView : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic) float openCellLastTX;
@property (nonatomic, strong) NSIndexPath *openCellIndexPath;

@end
