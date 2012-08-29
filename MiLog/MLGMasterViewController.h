//
//  MLGMasterViewController.h
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLGDetailViewController;

#import <CoreData/CoreData.h>

@interface MLGMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MLGDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
