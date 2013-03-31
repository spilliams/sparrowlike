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

@interface SLPanningCell : UITableViewCell
@property (nonatomic) id<SLPanningTableViewCellDelegate> delegate;
@property (nonatomic) SLPanningTableViewCellDirection direction;
- (void)setState:(SLPanningTableViewCellState)newState;
@end

@protocol SLPanningTableViewCellDelegate <NSObject>

@optional
- (void)cellWillPanOpen:(SLPanningCell *)cell;
- (void)cellDidPanOpen:(SLPanningCell *)cell;
- (void)cellWillPanClosed:(SLPanningCell *)cell;
- (void)cellDidPanClosed:(SLPanningCell *)cell;

@end


