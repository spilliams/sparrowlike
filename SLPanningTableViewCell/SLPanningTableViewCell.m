//
//  SLPanningCell.m
//  SLPanningTableViewCell
//
//  Created by Spencer Williams on 3/31/13.
//  Copyright (c) 2013 spilliams. All rights reserved.
//

#import "SLPanningTableViewCell.h"

@interface SLPanningTableViewCell ()
@property (nonatomic) SLPanningTableViewCellState panState;
@end

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
    if (newState == SLPanningTableViewCellStateTransitory) {
        // not a feature, not a bug.
        return;
    }
    
    NSString *newStateString = @"Open";
    if (newState == SLPanningTableViewCellStateClosed) {
        newStateString = @"Closed";
    }
    BOOL delegateExistsAndConforms = self.delegate && [self.delegate conformsToProtocol:@protocol(SLPanningTableViewCellDelegate)];
    
    SEL willSelector = NSSelectorFromString([NSString stringWithFormat:@"cellWillPan%@",newStateString]);
    if (delegateExistsAndConforms &&
        [self.delegate respondsToSelector:willSelector]) {
        [self.delegate performSelector:willSelector];
    }
    
    // TODO do animation stuff
    
    SEL didSelector = NSSelectorFromString([NSString stringWithFormat:@"cellDidPan%@",newStateString]);
    if (delegateExistsAndConforms &&
        [self.delegate respondsToSelector:didSelector]) {
        [self.delegate performSelector:didSelector];
    }
    
    [self setPanState:newState];
}

#pragma mark - Property Overrides

- (void)setPanState:(SLPanningTableViewCellState)panState
{
    SLPanningTableViewCellState oldState = _panState;
    _panState = panState;
    if (self.delegate &&
        [self.delegate conformsToProtocol:@protocol(SLPanningTableViewCellDelegate)] &&
        [self.delegate respondsToSelector:@selector(cell:changedFromState:toState:)]) {
        [self.delegate cell:self changedFromState:oldState toState:panState];
    }
}

@end
