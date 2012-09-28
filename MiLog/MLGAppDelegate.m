//
//  MLGAppDelegate.m
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "MLGAppDelegate.h"

#import "MLGMasterViewController.h"

#define NEW 0
#define ACTIVE 1
#define PAUSE 2
#define HISTORY 3

@implementation MLGAppDelegate



@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *) self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id) navigationController.topViewController;

        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        MLGMasterViewController *controller = (MLGMasterViewController *) masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    else {
        UINavigationController *navigationController = (UINavigationController *) self.window.rootViewController;
        MLGMasterViewController *controller = (MLGMasterViewController *) navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    UINavigationController *navigationController = (UINavigationController *) self.window.rootViewController;
    MLGMasterViewController *controller = (MLGMasterViewController *) navigationController.topViewController;
    NSArray *fetchedEvents = [[controller fetchedResultsController] fetchedObjects];
    controller.activeTimerCount = 0;
    for (TimerEvent *anEvent in fetchedEvents) {
        if (anEvent.state == ACTIVE) {
            controller.activeTimerCount++;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = controller.activeTimerCount;
    [self saveContext];
    controller.pollingTimer = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

            abort();
        }
    }
}

#pragma mark -
#pragma mark Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:NSLocalizedString(@"MiLog", @"MiLog") withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MiLog.sqlite"];
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

    NSError *error = nil;
    NSDictionary *options = @{
    NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES
    };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                                                 initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL
                                                         options:options error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents Directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
                            lastObject];
}

@end
