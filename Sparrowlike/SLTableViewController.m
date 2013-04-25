//
//  SLTableViewController.m
//  Sparrowlike
//
//  Created by Spencer Williams on 4/25/13.
//  Copyright (c) 2013 Spencer Williams. All rights reserved.
//

#import "SLTableViewController.h"
#import "SLTableViewCell.h"

@interface SLTableViewController ()

@end

@implementation SLTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.textLabel setText:[NSString stringWithFormat:@"%d %d",indexPath.section,indexPath.row]];
    [cell setDelegate:self];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SLPanningTableViewCell delegate

- (void)cell:(SLPanningTableViewCell *)cell changedFromState:(SLPanningTableViewCellState)oldState toState:(SLPanningTableViewCellState)newState
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"cell [%d,%d] changed from state %d to state %d",
          indexPath.section,
          indexPath.row,
          oldState,
          newState);
}
@end
