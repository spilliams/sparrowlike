Disclaimer: I recently had to figure all this stuff out on my own, and I ventured down many blind alleys before stumbling on this solution. My aim is to document my progress so that others may spend less time following in my footsteps and more time forging ahead. Cheers!

------------

So you want some panning table cells? Like the ones on the Sparrow app? (Similar to the ones on Twitter, but those use a swipe gesture, not a pan gesture. There are a [few differences](http://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizers/GestureRecognizers.html#//apple_ref/doc/uid/TP40009541-CH6-SW12)).

Oh you really wanted swipe? Ok look [here](https://github.com/boctor/idev-recipes/tree/master/SideSwipeTableView) or [here](https://github.com/lukeredpath/LRSlidingTableViewCell). Otherwise follow me!

##Overview

All we have to do is add some subviews to our **CustomCell** class, and give it a gesture recognizer to manipulate those subviews (specifically the front one). Then we'll want some variables in the **CustomTableViewController** to keep track of state. For the purposes of this demo we're only allowing one cell open at a time for instance. Also note that the likeness to Sparrow's app ends at the cell panning. This demo does not cover the table panning that Sparrow has.

##Requirements

Xcode 4  
An iPhone app that uses Storyboards and ARC

##Implementation

First of all go to Storyboard, set up your custom table view with custom cells. I'm not going to go into how that's done. If you don't know, go read a [TableView tutorial](http://www.raywenderlich.com/tag/uitableview).  
I will say however that this demo requires that your **UITableViewController** is owned by **CustomTableViewController** and any cells you want the gestures to work on should be owned by **CustomCell** and have the identifier `CustomCell`.

###CustomCell

In Storyboard, set up two views inside your cell's view. Make them the same size, shape and position as the cell. Somehow differentiate the views (make one a different color, stick on some labels, etc). Make sure the `frontView` is in front. Wire the views to two properties in **CustomCell**: `frontView` and `backView`.

One last thing: In Storyboard, select the CustomCell and in the Attributes editor (command+alt+4) set `Selection` to `None`. This wil remove the annoying blue selection background that appears every time you tap a cell. If you really want you can make your own, but they may not behave the way you want ([description](http://giorgiocalderolla.com/2011/04/16/customizing-uitableviewcells-a-better-way/)).

Your cell is now ready.

###Constants

This demo makes use of a separate `Constants.h` file that defines the following:

    #define FAST_ANIMATION_DURATION 0.35
    #define SLOW_ANIMATION_DURATION 0.75
    #define PAN_CLOSED_X 0
    #define PAN_OPEN_X -300

The **CustomTableViewController.m** should then `#import "Contstants.h"`.

###CustomTableViewController setup

Make sure in the `.h` that **CustomTableViewController** implements the *UITableViewDataSource* and *UIGestureRecognizerDelegate* protocols. Note that you will need to implement the following methods in your `.m` (but you don't need to declare them in the `.h` because they're already declared in the protocols).

    #pragma mark - Table view data source
    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    #pragma mark - Gesture recognizer delegate
    - (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer

We'll also need a couple state variables and our own handler method for the pan gesture. Declare these in the `.h` and `@synthesize`/implement in the `.m`:

    @property (nonatomic) float openCellLastTX;
    @property (nonatomic, strong) NSIndexPath *openCellIndexPath;
    - (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
    - (void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated;

`openCellLastTX` keeps track of the last translate x-value we recorded. Essentially this lets us "continue" the pan. Useful when the user wants to close a cell by panning.  
`openCellIndexPath` keeps track of what cell is currently open. This is sometimes `nil`.  
`-handlePan:` does the actual view manipulation.  
`-snapView:toX:animated:` will "snap" our cell to a certain x-value.

###CustomTableView table data source

Most of the stuff in the data source does not apply to this demo (stuff like `-numberOfSectionsInTableView:` and `-tableView:numberOfRowsInSection:`). However we need to add a couple lines to `-tableView:cellForRowAtIndexPath:`:

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [cell addGestureRecognizer:panGestureRecognizer];

This tells the cell that it should recognize a pan gesture, and that when it does it will send messages to `self` (both delegate messages and the `-handlePan:` call). Note that the selector has a `:`. This means that the gesture recognizer will send itself in the method call. This is very useful because pans are continuous gestures and we specifically want to capture this continuity.

###CustomTableView gesture recognizer delegate

The reason we need the *UIGestureRecognizerDelegate* protocol is because without it we can't cancel invalid pan gestures. Case in point: If you ran the app now you probably wouldn't be able to scroll the table. That's because the `panGestureRecognizer` would always succeed, causing the hidden `UIScrollViewPanGestureRecognizer` to fail. There's some highly-recommended interesting [documentation](http://developer.apple.com/library/ios/DOCUMENTATION/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizers/GestureRecognizers.html#//apple_ref/doc/uid/TP40009541-CH6-SW15) on gesture hierarchies. Basically we want to cancel any pan gestures that are not horizontal in nature. We do this with a simple test.

    - (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
    {
        CustomCell *cell = (CustomCell *)[panGestureRecognizer view];
        CGPoint translation = [panGestureRecognizer translationInView:[cell superview] ];
        return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
    }

Oh yeah. You probably noticed, but you'll **CustomTableViewController** will want to `#import "CustomCell.h"`.

###CustomTableView gesture handler

Now for the fun part. We're going to do this in steps so you (and I) don't get lost.

First set up the baseline gesture handler to test that it works and everything.

    - (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
    {
        switch ([panGestureRecognizer state]) {
            case UIGestureRecognizerStateBegan:
                NSLog(@"Began!");
                break;
            case UIGestureRecognizerStateEnded:
                NSLog(@"Ended!");
                break;
            case UIGestureRecognizerStateChanged:
                NSLog(@"Changed!");
                break;
            default:
                break;
        }
    }

Run the app and you should be able to not only scroll the table, but also see that your pan gesture is working. What's next? Well let's talk about what we want to happen when this gesture occurs.

- Began: the open cell should snap closed (unless it's the one being gestured on now)
- Changed: the current cell should track with the user's finger, but not outside our boundaries
- Ended: the current cell should snap either open or closed, taking into account the velocity of the touch  
This event should also set/reset our state variables accordingly

Ok, now for the meat of the handler. To start, we'll need a few variables in front of the `switch` block. Because `switch` is a C thing and not an Objective-C thing, we can't declare objects inside it. But we want to use these in multiple places anyway, so go ahead and put these above the `switch` statement:

    float threshold = (PAN_OPEN_X+PAN_CLOSED_X)/2.0;
    float vX = 0.0;
    float compare;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(CustomCell *)[panGestureRecognizer view] ];
    UIView *view = ((CustomCell *)panGestureRecognizer.view).frontView;

`threshold` describes the line that divides "this cell will snap open when you let go" and "this cell will snap closed when you let go". Right now it's set halfway between open and closed.  
`vX` is the velocity of the touch. We only really use this in the Ended case. 
`compare` is useful for checking against `threshold` and our out-of-bounds conditions.  
`indexPath` is the index path of the current cell.  
`view` is the view that's responding to the gesture.

In the Began block:

    if (self.openCellIndexPath.section != indexPath.section || self.openCellIndexPath.row != indexPath.row) {
        [self snapView:((CustomCell *)[self.tableView cellForRowAtIndexPath:self.openCellIndexPath]).frontView toX:PAN_CLOSED_X animated:YES];
        [self setOpenCellIndexPath:nil];
        [self setOpenCellLastTX:0];
    }
    break;

Basically we're checking that this cell and the open cell are different, and if they are we snap it closed and reset the state variables.

In the Ended block:

    vX = (FAST_ANIMATION_DURATION/2.0)*[panGestureRecognizer velocityInView:self.view].x;
    compare = view.transform.tx + vX;
    if (compare > threshold) {
        [self snapView:view toX:PAN_CLOSED_X animated:YES];
        [self setOpenCellIndexPath:nil];
        [self setOpenCellLastTX:0];
    } else {
        [self snapView:view toX:PAN_OPEN_X animated:YES];
        [self setOpenCellIndexPath:[self.tableView indexPathForCell:(CustomCell *)panGestureRecognizer.view] ];
        [self setOpenCellLastTX:view.transform.tx];
    }
    break;

First of all note that in an Ended state we can't use `-translationInView:`. So that's the reason why `compare = view.transform.tx + vX` and not `[panGestureRecognizer translationInView:self.view].x + vX`.  
Secondly note the velocity formula. Looks a little bit like the acceleration equation `d = (vf + vi)*t / 2`. Essentially we want to figure out how far the cell *would* travel if it had no boundaries. Then we use that position to determine which side to snap to. Sure, it doesn't go through that animation of slowing down to its final position before the snap animation, but it's a lot more intuitive than if we didn't take velocity into account.  
Lastly: "Ok seriously, what's `openCellLastTX` for?" When you pan on an already-open cell, it will start at its current (transformed) position, not its original position.

In the Changed block:

    compare = self.openCellLastTX+[panGestureRecognizer translationInView:self.view].x;
    if (compare > PAN_CLOSED_X)
        compare = PAN_CLOSED_X;
    else if (compare < PAN_OPEN_X)
        compare = PAN_OPEN_X;
    [view setTransform:CGAffineTransformMakeTranslation(compare, 0)];
    break;

We're testing the current translation of the cell against `PAN_OPEN_X` and `PAN_CLOSED_X` because we don't want the user to be able to pan the cell outside of its bounds (it would still snap back to the bound, but it's just not a UI feature we want to support).  
Also make note of the way we translate the view. There are several ways to do it, including using [`CGRectOffset`](http://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGGeometry/Reference/reference.html#//apple_ref/doc/uid/TP30000955-CH1g-F17162)s, [`CGRectMake`](http://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGGeometry/Reference/reference.html#//apple_ref/doc/uid/TP30000955-CH1g-F17161)s and [`setCenter`](http://developer.apple.com/library/ios/documentation/uikit/reference/uiview_class/UIView/UIView.html#//apple_ref/doc/uid/TP40006816-CH3-SW3)s. We use [`CGAffineTransform`](http://developer.apple.com/library/mac/#documentation/graphicsimaging/Reference/CGAffineTransform/Reference/reference.html)s because they're fun.

Ok only one more piece to this puzzle:

    - (void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated
    {
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

Pretty simple. It allows us to animate the transformation of a view to any x point.

And that's it! It should be working properly now...let me know if you have questions? I may or may not develop this into a framework. I have some ideas about that acceleration stuff...