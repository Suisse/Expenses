//
//  Expense.h
//  Expenses
//
//  Created by Anthony Longland on 09/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Expense : NSManagedObject

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *note;

@end
