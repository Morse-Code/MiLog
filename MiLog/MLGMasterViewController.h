//
//  MLGMasterViewController.h
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "MLGDetailViewController.h"

@interface MLGMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate> {
    NSDateFormatter *dateFormatter;
}



@property(strong, nonatomic) MLGDetailViewController *detailViewController;

@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) NSTimer *pollingTimer;

- (void)startTimerWithTimerEvent:(TimerEvent *)event;

- (void)pauseTimerWithTimerEvent:(TimerEvent *)event;

- (void)updateTimers;

@end
