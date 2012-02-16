

//
//  DetailViewController.h
//  Expenses
//
//  Created by Anthony Longland on 10/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class Expense, EditingViewController;

@interface DetailViewController : UITableViewController {
    Expense *expense;
	NSDateFormatter *dateFormatter;
	NSUndoManager *undoManager;
}

@property (nonatomic, retain) Expense *expense;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSUndoManager *undoManager;

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;
- (void)updateRightBarButtonItemState;

@end

