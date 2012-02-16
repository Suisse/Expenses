
//
//  RootViewController.h
//  Expenses
//
//  Created by Anthony Longland on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "DetailViewController.h"
#import "Expense.h"


@implementation RootViewController

@synthesize fetchedResultsController, managedObjectContext, addingManagedObjectContext;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Expenses";
	// Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
	// Configure the add button.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addExpense)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}


- (void)viewWillAppear {
	[self.tableView reloadData];
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.fetchedResultsController = nil;
}


#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Configure the cell to show the expense's title
	Expense *expense = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = expense.category;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Display the categories names as section headings.
    return [[[fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error;
		if (![context save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
    }   
}


#pragma mark -
#pragma mark Selection and moving

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Create and push a detail view controller.
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    Expense *selectedExpense = (Expense *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected expense to the new view controller.
    detailViewController.expense = selectedExpense;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Adding a Expense

/**
 Creates a new expense, an AddViewController to manage addition of the expense, and a new managed object context for the add controller to keep changes made to the expense discrete from the application's managed object context until the expense is saved.
 IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to merge changes after a save, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).  The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
*/
- (IBAction)addExpense {
	
    AddViewController *addViewController = [[AddViewController alloc] initWithStyle:UITableViewStyleGrouped];
	addViewController.delegate = self;
	
	// Create a new managed object context for the new expense -- set its persistent store coordinator to the same as that from the fetched results controller's context.
	NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
	self.addingManagedObjectContext = addingContext;
	[addingContext release];
	
	[addingManagedObjectContext setPersistentStoreCoordinator:[[fetchedResultsController managedObjectContext] persistentStoreCoordinator]];
		
	addViewController.expense = (Expense *)[NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:addingContext];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addViewController];
	
    [self.navigationController presentModalViewController:navController animated:YES];
	
	[addViewController release];
	[navController release];
}


/**
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new expense.
 */
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
	
	if (save) {
		/*
		 The new expense is associated with the add controller's managed object context.
		 This is good because it means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad -- but it does make it more difficult to get the new expense registered with the fetched results controller.
		 First, you have to save the new expense.  This means it will be added to the persistent store.  Then you can retrieve a corresponding managed object into the application delegate's context.  Normally you might do this using a fetch or using objectWithID: -- for example
		 
		 NSManagedObjectID *newExpenseID = [controller.expense objectID];
		 NSManagedObject *newexpense = [applicationContext objectWithID:newExpenseID];
		 
		 These techniques, though, won't update the fetch results controller, which only observes change notifications in its context.
		 You don't want to tell the fetch result controller to perform its fetch again because this is an expensive operation.
		 You can, though, update the main context using mergeChangesFromContextDidSaveNotification: which will emit change notifications that the fetch results controller will observe.
		 To do this:
		 1	Register as an observer of the add controller's change notifications
		 2	Perform the save
		 3	In the notification method (addControllerContextDidSave:), merge the changes
		 4	Unregister as an observer
		 */
		NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
		[dnc addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
		
		NSError *error;
		if (![addingManagedObjectContext save:&error]) {
			// Update to handle the error appropriately.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
		[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:addingManagedObjectContext];
	}
	// Release the adding managed object context.
	self.addingManagedObjectContext = nil;

	// Dismiss the modal view to return to the main list
    [self dismissModalViewControllerAnimated:YES];
}


/**
 Notification from the add controller's context's save operation. This is used to update the fetched results controller's managed object context with the new expense instead of performing a fetch (which would be a much more computationally expensive operation).
 */
- (void)addControllerContextDidSave:(NSNotification*)saveNotification {
	
	NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	// Merging changes causes the fetched results controller to update its results
	[context mergeChangesFromContextDidSaveNotification:saveNotification];	
}


#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Expense entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *amountDescriptor = [[NSSortDescriptor alloc] initWithKey:@"amount" ascending:YES];
	NSSortDescriptor *categoryDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
   	NSSortDescriptor *accountDescriptor = [[NSSortDescriptor alloc] initWithKey:@"account" ascending:YES];
   	NSSortDescriptor *noteDescriptor = [[NSSortDescriptor alloc] initWithKey:@"note" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:amountDescriptor, categoryDescriptor, accountDescriptor, noteDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"amount" cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[amountDescriptor release];
	[categoryDescriptor release];
    [accountDescriptor release];
    [noteDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	UITableView *tableView = self.tableView;

	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
	[addingManagedObjectContext release];
    [super dealloc];
}


@end

