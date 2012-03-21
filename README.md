Disclaimer: I recently had to figure all this stuff out on my own, and I ventured down many blind alleys before stumbling on this solution. My aim is to document my progress so that others may spend less time following in my footsteps and more time forging ahead. Cheers!

------------

So you want some panning table cells? Like the ones on the [Sparrow app](http://sparrowmailapp.com/)*? (Similar to the ones in the Twitter app, except those use a swipe gesture not a pan gesture. There are a [few differences](http://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizers/GestureRecognizers.html#//apple_ref/doc/uid/TP40009541-CH6-SW12) between swiping and panning).

Oh, you really wanted swipe? Ok look [here](https://github.com/boctor/idev-recipes/tree/master/SideSwipeTableView) or [here](https://github.com/lukeredpath/LRSlidingTableViewCell) for submoduleable frameworks. Otherwise follow me!

Another Disclaimer: note that the likeness to Sparrow's app ends at the cell panning. This demo does not cover the table panning that Sparrow has (although if you are a gesture newbie this demo may give you some insight to start tackling that).

All of the code I describe below is provided in this here repository, free of charge and free in speech. If you have questions on, concerns about or problems with it, please [open an issue](https://github.com/spilliams/sparrowlike/issues/new).

##Overview

All we have to do is add some subviews to our **CustomCell** class, and give it a gesture recognizer to manipulate those subviews (specifically the front one). Then we will want some variables in the **CustomTableViewController** to keep track of state. For the purposes of this demo we are only allowing one cell open at a time. If your app requires something different you will probably need different state variables.

##Requirements

* Xcode 4
* An iPhone app that uses Storyboards and ARC

##Implementation

First of all go to Storyboard, set up your custom table view with custom cells. I am not going to go into how that is done (there are some pretty good [UITableView tutorials](http://www.raywenderlich.com/tag/uitableview) out there).  
I will say however that this demo requires that your table view is owned by **CustomTableViewController** and any cells you want the gestures to work on should be owned by **CustomCell** (if you have your own classes for these that is ok, just do some word-substitution in your head from here on out).

###CustomCell

In Storyboard, set up two views inside your cell's view. Make them the same size, shape and position as the cell. Wire the views to two properties in **CustomCell**: `frontView` and `backView`. Somehow differentiate the views (make one a different color, stick on some labels, etc). Make sure the `frontView` is in front.

One last thing: From Storyboard select the cell and in the Attributes editor (command+alt+4) set `Selection` to `None`. This will remove the annoying blue selection background that appears every time you tap a cell. If you really want to you can make your own, but [they may not behave the way you expect](http://giorgiocalderolla.com/2011/04/16/customizing-uitableviewcells-a-better-way/)).

Your cell is now ready.

###Constants

This demo makes use of a separate `Constants.h` file that defines the following:

    #define FAST_ANIMATION_DURATION 0.35
    #define SLOW_ANIMATION_DURATION 0.75
    #define PAN_CLOSED_X 0
    #define PAN_OPEN_X -300

Notice that `PAN_OPEN_X` is not -320. This is because our cell will have a tab handle visible on the left side of the screen when it is in the open position. If you want to make your cell fly off the screen entirely then `#define PAN_OPEN_X -320`. Since the pan gesture is recognized by the cell and it is only the cell's `frontView` that pans away, the pan gesture will still be caught if the cell is in the open position. For this demo we want a small "handle" to remain visible when the cell is open.

Make the **CustomTableViewController** `#import "Constants.h"`.

###CustomTableViewController setup

Make sure in its `.h` that **CustomTableViewController** implements the *UITableViewDataSource* and *UIGestureRecognizerDelegate* protocols. Note that you will need to implement the following methods in its `.m` (but you will not need to declare them in the `.h` because they are already declared in the protocols):

    #pragma mark - Table view data source
    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    #pragma mark - Gesture recognizer delegate
    - (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer

We will also need a couple of state variables and our own handler method for the pan gesture. Declare these in the `.h` and `@synthesize`/implement them in the `.m`:

    @property (nonatomic) float openCellLastTX;
    @property (nonatomic, strong) NSIndexPath *openCellIndexPath;
    - (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer;
    - (void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated;

`openCellLastTX` keeps track of the last x-translation value we recorded. Essentially this lets us "continue" the pan. Useful when the user wants to close a cell by panning (also has connotations if you disable the "snapping"--more on that in a bit). This is sometimes 0.  
`openCellIndexPath` keeps track of which cell is currently open. This is sometimes `nil`.  
`-handlePan:` does the actual view manipulation.  
`-snapView:toX:animated:` will "snap" our cell to a certain x-translation from its origin.

###CustomTableView table data source

Most of the stuff in the data source does not apply to this demo (stuff like `-numberOfSectionsInTableView:` and `-tableView:numberOfRowsInSection:`). However we do need to add a few lines to `-tableView:cellForRowAtIndexPath:`:

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [cell addGestureRecognizer:panGestureRecognizer];

This tells the cell that it should recognize a pan gesture, and that when it does it will send messages to `self` (both delegate messages and the `-handlePan:` call). Note that the action selector has a `:`. This means that the gesture recognizer will send itself in the method call. This is very useful because pans are continuous gestures and we specifically want to capture this continuity.

###CustomTableView gesture recognizer delegate

The reason we need the *UIGestureRecognizerDelegate* protocol is because without it we cannot cancel invalid pan gestures. Case in point: If you run the app now you will not be able to scroll the table. That is because the `panGestureRecognizer` will always succeed, causing the hidden `UIScrollViewPanGestureRecognizer` to fail. There is some highly-recommended interesting [documentation](http://developer.apple.com/library/ios/DOCUMENTATION/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizers/GestureRecognizers.html#//apple_ref/doc/uid/TP40009541-CH6-SW15) on gesture hierarchies. Basically we want to cancel any pan gestures that are not horizontal in nature. We do this with a simple test.

    - (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
    {
        CustomCell *cell = (CustomCell *)[panGestureRecognizer view];
        CGPoint translation = [panGestureRecognizer translationInView:[cell superview] ];
        return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
    }

Oh yeah: you probably already noticed this, but your **CustomTableViewController** will want to `#import "CustomCell.h"`.

###CustomTableView gesture handler

Now for the fun part. We are going to do this in increments so that neither of us get lost. :)

First set up a simple pan gesture handler.

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

You can test that it works! Run the app and you should be able to not only scroll the table, but also see that your pan gesture is working. What next? What should happen during the different states of this gesture?

- Began: the open cell should snap closed (unless it is the one currently being touched).
- Changed: the current cell should track with the user's finger, but not outside its boundaries.
- Ended: the current cell should snap either open or closed, taking into account the final velocity of the touch.  
  This event should also set/reset our state variables accordingly.

Ok, now for the meat of the handler. To start, we will need a few variables in front of the `switch` block. Because `switch` is a C thing and not an Objective-C thing, we cannot declare objects inside it. But we want to use most of these in multiple places anyway, so go ahead and put the following above the `switch` statement:

    float threshold = (PAN_OPEN_X+PAN_CLOSED_X)/2.0;
    float vX = 0.0;
    float compare;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(CustomCell *)[panGestureRecognizer view] ];
    UIView *view = ((CustomCell *)panGestureRecognizer.view).frontView;

`threshold` describes the line that divides "this cell will snap open when you let go" and "this cell will snap closed when you let go". Right now it is set halfway between open and closed.  
`vX` is the velocity of the touch. We only really use this in the Ended case.  
`compare` is useful for checking against `threshold` and the out-of-bounds conditions.  
`indexPath` is the index path of the current cell.  
`view` is the view that is responding to the gesture.

In the Began block:

    if (self.openCellIndexPath.section != indexPath.section || self.openCellIndexPath.row != indexPath.row) {
        [self snapView:((CustomCell *)[self.tableView cellForRowAtIndexPath:self.openCellIndexPath]).frontView toX:PAN_CLOSED_X animated:YES];
        [self setOpenCellIndexPath:nil];
        [self setOpenCellLastTX:0];
    }
    break;

Basically we are checking that this cell and the open cell are different, and if they are we snap the open cell closed and reset the state variables.

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

First of all note that in an Ended state we cannot use `-translationInView:`. So that is the reason why `compare = view.transform.tx + vX` and not `[panGestureRecognizer translationInView:self.view].x + vX` (side note about `-translationInView:`: it returns a `CGPoint` describing the **difference** between the currently-touched point and the initially-touched point).  
Secondly note the velocity factor formula. Looks a little bit like the acceleration equation `d = (vf + vi)*t / 2`. Essentially we want to figure out how far the cell *would* travel if it had no boundaries. Then we use that position to determine which side to snap to. Sure, it does not go through that animation of slowing down to its final position before the animation of the snap, but it is a lot more intuitive than if we did not take velocity into account at all.

In the Changed block:

    compare = self.openCellLastTX+[panGestureRecognizer translationInView:self.view].x;
    if (compare > PAN_CLOSED_X)
        compare = PAN_CLOSED_X;
    else if (compare < PAN_OPEN_X)
        compare = PAN_OPEN_X;
    [view setTransform:CGAffineTransformMakeTranslation(compare, 0)];
    break;

We are testing the current translation of the cell against `PAN_OPEN_X` and `PAN_CLOSED_X` because we do not want the user to be able to pan the cell outside of its bounds (it would still snap back to the bound, but it is just not a UI feature we want to support in this demo).  
Also make note of the way we translate the view. There are several ways to do it, including using [`CGRectOffset`](http://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGGeometry/Reference/reference.html#//apple_ref/doc/uid/TP30000955-CH1g-F17162)s, [`CGRectMake`](http://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CGGeometry/Reference/reference.html#//apple_ref/doc/uid/TP30000955-CH1g-F17161)s and [`setCenter`](http://developer.apple.com/library/ios/documentation/uikit/reference/uiview_class/UIView/UIView.html#//apple_ref/doc/uid/TP40006816-CH3-SW3)s. We use [`CGAffineTransform`](http://developer.apple.com/library/mac/#documentation/graphicsimaging/Reference/CGAffineTransform/Reference/reference.html)s because they are fun.  
Lastly notice the use of `openCellLastTX` (we used it in the Began and Ended blocks too but this note is more apt here). If we were to disable the snapping in the Ended block right now you would notice that when you begin a pan gesture the cell will pick up where it left off. This is not by accident. This is a side-effect of keeping the `openCellLastTX` state property. When you end a pan gesture, the x-translation is saved so that it may be re-applied at the beginning of the next pan gesture (but only the beginning: notice we do not save `openCellLastTX` during the Changed state).

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

Pretty simple. It allows us to animate any x-transformation of a view.

And that about does it! It should be working properly now. If you have questions or concerns please [open an issue](https://github.com/spilliams/sparrowlike/issues/new).

------------

*I apologize for the shameless Sparrow shout-out, but it was the only example of this particular UX I could find.