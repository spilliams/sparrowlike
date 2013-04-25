//
//  SLPanningCell.h
//  SLPanningTableViewCell
//
//  Created by Spencer Williams on 3/31/13.
//  Copyright (c) 2013 spilliams. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SLPanningTableViewCellDelegate;

typedef enum {
    SLPanningTableViewCellDirectionNone,
    SLPanningTableViewCellDirectionLeft,
    SLPanningTableViewCellDirectionRight,
    SLPanningTableViewCellDirectionEither,
} SLPanningTableViewCellDirection;

typedef enum {
    SLPanningTableViewCellStateClosed,
    SLPanningTableViewCellStateOpenLeft,
    SLPanningTableViewCellStateOpenRight,
} SLPanningTableViewCellState;

/** A panning cell responds to horizontal pan gestures that "open" and "close"
 its content view.
 
 It may send messages to its delegate about its state.
 */
@interface SLPanningTableViewCell : UITableViewCell
/// The cell's delegate
/// @see SLPanningCellDelegate
@property (nonatomic) id<SLPanningTableViewCellDelegate> delegate;
/// The direction the cell is allowed to pan
@property (nonatomic) SLPanningTableViewCellDirection direction;
/// Change the cell's state programmatically.
/// @param newState The new state of the cell
- (void)setState:(SLPanningTableViewCellState)newState;
@end

/** Classes that conform to SLPanningCellDelegate may receive messages about the
 state of panning cells.
 
 Note that the "will" methods won't fire unless it's absolutely certain that the
 cell will end up in that state. That is, if a pan gesture opens the cell most
 of the way, then closes it most of the way, then ends, the only calls made to
 the delegate will be -cellWillPanClosed: and -cellDidPanClosed:.
 */
@protocol SLPanningTableViewCellDelegate <NSObject>

@optional
/// Fires when the cell is about to start its animation towards being open.
/// @param cell The cell
- (void)cellWillPanOpen:(SLPanningTableViewCell *)cell;
/// Fires when the cell has completed its animation towards being open.
/// @param cell The cell
- (void)cellDidPanOpen:(SLPanningTableViewCell *)cell;
/// Fires when the cell is about to start its animation towards being closed.
/// @param cell The cell
- (void)cellWillPanClosed:(SLPanningTableViewCell *)cell;
/// Fires when the cell has completed its animation towards being closed.
/// @param cell The cell
- (void)cellDidPanClosed:(SLPanningTableViewCell *)cell;

@end


