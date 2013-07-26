//
//  SLPanningTableView.m
//  Sparrowlike
//
//  Created by Jay Chae  on 7/26/13.
//
//

#import "SLPanningTableView.h"
#import "SLPanningTableViewCell.h"


static const CGFloat FAST_ANIMATION_DURATION = 0.35;
static const CGFloat SLOW_ANIMATION_DURATION = 0.75;

static const NSInteger PAN_CLOSED_X = 0;
static const NSInteger PAN_OPEN_X = -300;


@implementation SLPanningTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if ([panGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return NO;
    }
    
    SLPanningTableViewCell *cell = (SLPanningTableViewCell *)[panGestureRecognizer view];
    CGPoint translation = [panGestureRecognizer translationInView:[cell superview] ];
    return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
}


- (void)handleSparrowPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    float threshold = (PAN_OPEN_X+PAN_CLOSED_X)/2.0;
    float vX = 0.0;
    float compare;
    float finalX;
    NSIndexPath *indexPath = [self indexPathForCell:(SLPanningTableViewCell *)[panGestureRecognizer view] ];
    UIView *view = ((SLPanningTableViewCell *)panGestureRecognizer.view).panningView;
    
    switch ([panGestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            if (self.openCellIndexPath.section != indexPath.section || self.openCellIndexPath.row != indexPath.row) {
                [self snapView:((SLPanningTableViewCell *)[self cellForRowAtIndexPath:self.openCellIndexPath]).panningView toX:PAN_CLOSED_X animated:YES];
                [self setOpenCellIndexPath:nil];
                [self setOpenCellLastTX:0];
            }
            break;
        case UIGestureRecognizerStateEnded:
            vX = (FAST_ANIMATION_DURATION/2.0)*[panGestureRecognizer velocityInView:self].x;
            compare = view.transform.tx + vX;
            if (compare > threshold) {
                finalX = MAX(PAN_OPEN_X,PAN_CLOSED_X);
                [self setOpenCellLastTX:0];
            } else {
                finalX = MIN(PAN_OPEN_X,PAN_CLOSED_X);
                [self setOpenCellLastTX:view.transform.tx];
            }
            [self snapView:view toX:finalX animated:YES];
            if (finalX == PAN_CLOSED_X) {
                [self setOpenCellIndexPath:nil];
            } else {
                [self setOpenCellIndexPath:[self indexPathForCell:(SLPanningTableViewCell *)panGestureRecognizer.view]];
            }
            break;
        case UIGestureRecognizerStateChanged:
            compare = self.openCellLastTX+[panGestureRecognizer translationInView:self].x;
            if (compare > MAX(PAN_OPEN_X,PAN_CLOSED_X))
                compare = MAX(PAN_OPEN_X,PAN_CLOSED_X);
            else if (compare < MIN(PAN_OPEN_X,PAN_CLOSED_X))
                compare = MIN(PAN_OPEN_X,PAN_CLOSED_X);
            [view setTransform:CGAffineTransformMakeTranslation(compare, 0)];
            break;
        default:
            break;
            
            
    }
}

-(void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:FAST_ANIMATION_DURATION];
    }
    
    [view setTransform:CGAffineTransformMakeTranslation(x, 0)];
    
    if (animated) {
        [UIView commitAnimations];
    }
}


@end
