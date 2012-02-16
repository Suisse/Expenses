
//
//  EditingViewController.h
//  Expenses
//
//  Created by Anthony Longland on 10/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
@interface EditingViewController : UIViewController {
	
	UITextField *textField;

    NSManagedObject *editedObject;
    NSString *editedFieldKey;
    NSString *editedFieldName;
	
    BOOL editingDate;
	UIDatePicker *datePicker;
}

@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) NSManagedObject *editedObject;
@property (nonatomic, retain) NSString *editedFieldKey;
@property (nonatomic, retain) NSString *editedFieldName;

@property (nonatomic, assign, getter=isEditingDate) BOOL editingDate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

- (IBAction)cancel;
- (IBAction)save;

@end

