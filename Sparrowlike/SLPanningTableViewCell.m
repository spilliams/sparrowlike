//
//  SLPanningTableViewCell.m
//  Sparrowlike
//
//  Created by Jay Chae  on 7/26/13.
//
//

#import "SLPanningTableViewCell.h"

@interface SLPanningTableViewCell ()


@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end


@implementation SLPanningTableViewCell

@synthesize panGestureRecognizer;
@synthesize panningView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initAllSubviews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)initAllSubviews {
    [self initPanningView];
}


- (void)setDelegateForPanGesture:(id<UIGestureRecognizerDelegate>)delegate {
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panGestureRecognizer addTarget:delegate action:@selector(handleSparrowPan:)];
    [panGestureRecognizer setDelegate:delegate];
    [self addGestureRecognizer:panGestureRecognizer];
}

/*
 Subclass should override this contents on the panning
 */

- (void)initPanningView {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];

}

@end
