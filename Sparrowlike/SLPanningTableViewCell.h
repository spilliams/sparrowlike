//
//  SLPanningTableViewCell.h
//  Sparrowlike
//
//  Created by Jay Chae  on 7/26/13.
//
//

#import <UIKit/UIKit.h>

@interface SLPanningTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *panningView;

- (void)setDelegateForPanGesture:(id<UIGestureRecognizerDelegate>)delegate;
- (void)initPanningView;
    
@end
