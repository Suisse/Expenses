
//
//  AddViewController.h
//  Expenses
//
//  Created by Anthony Longland on 10/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "DetailViewController.h"


@protocol AddViewControllerDelegate;


@interface AddViewController : DetailViewController {
	id <AddViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id <AddViewControllerDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@protocol AddViewControllerDelegate
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save;
@end

