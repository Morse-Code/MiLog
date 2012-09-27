//
//  MLGMasterViewController.m
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "MLGMasterViewController.h"

#import "MLGDetailViewController.h"

#import "MLGTimerCell.h"

#define NEW 0
#define ACTIVE 1
#define PAUSE 2
#define HISTORY 3

@interface MLGMasterViewController ()


- (void)configureCell:(MLGTimerCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;


@end

@implementation MLGMasterViewController


@synthesize pollingTimer = _pollingTimer;
@synthesize activeTimerCount = _activeTimerCount;

#pragma mark -
# pragma mark Set Up View

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                        action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (MLGDetailViewController *) [[self.splitViewController.viewControllers lastObject]
                                                                                                       topViewController];
    self.activeTimerCount = 0;
    NSArray *fetchedEvents = [[self fetchedResultsController] fetchedObjects];
    BOOL activeTimers = FALSE;
    for (TimerEvent *anEvent in fetchedEvents) {
        if (anEvent.state == ACTIVE) {
            activeTimers = TRUE;
            self.activeTimerCount++;
        }
    }
    if (!activeTimers) {
        self.pollingTimer = nil;
    }
    else if (self.pollingTimer == nil) {
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 2.0
                                                             target:self
                                                           selector:@selector(updateTimers)
                                                           userInfo:nil repeats:YES];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.activeTimerCount;
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else {
        return YES;
    }
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    TimerEvent *newManagedObject = [TimerEvent addEventToContext:context];
    [self performSegueWithIdentifier:@"showDetail" sender:newManagedObject];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[self.fetchedResultsController sections] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView
titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TimerCell";
    MLGTimerCell *cell = (MLGTimerCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MLGTimerCell alloc]
                              initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)                          tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimerEvent *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([event state] == HISTORY || [event state] == NEW) {

        return @"Delete";
    }
    else {
        return @"Reset";
    }
}

- (BOOL)    tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    TimerEvent *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (event.state == NEW || event.state == HISTORY) {
            [context deleteObject:event];
        }
        else {
            [event resetTimer];
        }
        NSError *error = nil;

        if (![context save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

            abort();
        }
    }
}

- (BOOL)    tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        TimerEvent *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = event;
    }
    else {
        TimerEvent *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        if (event.state == ACTIVE) {
            [self pauseTimerWithTimerEvent:event];
        }
        else if (event.state != HISTORY) {
            [self startTimerWithTimerEvent:event];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)                       tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    TimerEvent *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"showDetail" sender:object];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    [[segue destinationViewController] setDetailItem:sender];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row + (indexPath.section % 2)) % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
}

- (void)configureCell:(MLGTimerCell *)cell
          atIndexPath:(NSIndexPath *)indexPath {

    TimerEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithTimerEvent:event];
}

#pragma mark -
#pragma mark Timer Methods

- (void)startTimerWithTimerEvent:(TimerEvent *)event {
    if (self.pollingTimer == nil) {
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 2.0
                                                             target:self
                                                           selector:@selector(updateTimers)
                                                           userInfo:nil repeats:YES];
        NSLog(@"Polling timer created");
    }
    event.start = [NSDate date];
    event.state = ACTIVE;
}

- (void)pauseTimerWithTimerEvent:(TimerEvent *)event {
    NSArray *fetchedEvents = [[self fetchedResultsController] fetchedObjects];
    BOOL activeTimers = FALSE;
    for (TimerEvent *anEvent in fetchedEvents) {
        if (anEvent.state == ACTIVE) {
            activeTimers = TRUE;
        }
    }
    if (!activeTimers) {
        self.pollingTimer = nil;
    }
    [event setElapsedForStopDate:[NSDate date] withState:PAUSE];
    [self saveContext];
}

- (void)updateTimers {
    NSArray *fetchedEvents = [[self fetchedResultsController] fetchedObjects];
    BOOL activeTimers = FALSE;
    for (TimerEvent *event in fetchedEvents) {
        if (event.state == ACTIVE) {
            activeTimers = TRUE;
            [event setTimeIntervalToDate:[NSDate date]];
        }
    }
    if (!activeTimers && self.pollingTimer != nil) {
        self.pollingTimer = nil;
    }
}

#pragma mark -
#pragma mark Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimerEvent"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                                                         initWithFetchRequest:fetchRequest
                                                                                         managedObjectContext:self.managedObjectContext
                                                                                           sectionNameKeyPath:@"sectionName"
                                                                                                    cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:(MLGTimerCell *) [tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

            abort();
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
