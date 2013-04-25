//
//  SLPanningCell.m
//  SLPanningTableViewCell
//
//  Created by Spencer Williams on 3/31/13.
//  Copyright (c) 2013 spilliams. All rights reserved.
//

#import "SLPanningTableViewCell.h"

@implementation SLPanningTableViewCell

#pragma mark - Cell Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // TODO fancy shimming
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [self setState:SLPanningTableViewCellStateClosed];
    [super prepareForReuse];
}

#pragma mark - Public API

- (void)setState:(SLPanningTableViewCellState)newState
{
    NSString *newStateString = @"Open";
    if (newState == SLPanningTableViewCellStateClosed) {
        newStateString = @"Closed";
    }
    BOOL delegateConforms = self.delegate && [self.delegate conformsToProtocol:@protocol(SLPanningTableViewCellDelegate)];
    
    SEL willSelector = NSSelectorFromString([NSString stringWithFormat:@"cellWillPan%@",newStateString]);
    if (delegateConforms &&
        [self.delegate respondsToSelector:willSelector]) {
        [self.delegate performSelector:willSelector];
    }
    
    // TODO do animation stuff
    
    SEL didSelector = NSSelectorFromString([NSString stringWithFormat:@"cellDidPan%@",newStateString]);
    if (delegateConforms &&
        [self.delegate respondsToSelector:didSelector]) {
        [self.delegate performSelector:didSelector];
    }
}

@end
