
//
//  RootViewController.m
//  Expenses
//
//  Created by Anthony Longland on 10/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddViewControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;	    
    NSManagedObjectContext *addingManagedObjectContext;	    
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext *addingManagedObjectContext;

- (IBAction)addExpense;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
