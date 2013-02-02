//
//  CustomTableViewController.m
//  Sparrowlike
//
//  Created by Spencer Williams on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTableViewController.h"
#import "Constants.h"
#import "CustomCell.h"

@implementation CustomTableViewController
@synthesize openCellLastTX, openCellIndexPath;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [cell addGestureRecognizer:panGestureRecognizer];
    
    return cell;
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CustomCell *cell = (CustomCell *)[panGestureRecognizer view];
    CGPoint translation = [panGestureRecognizer translationInView:[cell superview] ];
    return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
}

#pragma mark - Gesture handlers

-(void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    float threshold = (PAN_OPEN_X+PAN_CLOSED_X)/2.0;
    float vX = 0.0;
    float compare;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(CustomCell *)[panGestureRecognizer view] ];
    UIView *view = ((CustomCell *)panGestureRecognizer.view).frontView;
    
    switch ([panGestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            if (self.openCellIndexPath.section != indexPath.section || self.openCellIndexPath.row != indexPath.row) {
                [self snapView:((CustomCell *)[self.tableView cellForRowAtIndexPath:self.openCellIndexPath]).frontView toX:PAN_CLOSED_X animated:YES];
                [self setOpenCellIndexPath:nil];
                [self setOpenCellLastTX:0];
            }
            break;
        case UIGestureRecognizerStateEnded:
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
        case UIGestureRecognizerStateChanged:
            compare = self.openCellLastTX+[panGestureRecognizer translationInView:self.view].x;
            if (compare > PAN_CLOSED_X)
                compare = PAN_CLOSED_X;
            else if (compare < PAN_OPEN_X)
                compare = PAN_OPEN_X;
            [view setTransform:CGAffineTransformMakeTranslation(compare, 0)];
            break;
        default:
            break;
            
            
    }
}

-(void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated
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

#pragma mark -
#pragma UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
    if ([sender isEqual:[self tableView]]) {
        CustomCell *openCell = (CustomCell *) [self.tableView cellForRowAtIndexPath:openCellIndexPath];
        [self snapView:openCell.frontView toX:PAN_CLOSED_X animated:YES];
    }
}



@end
