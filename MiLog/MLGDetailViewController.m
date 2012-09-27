//
//  MLGDetailViewController.m
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "MLGDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define NEW 0
#define ACTIVE 1
#define PAUSE 2
#define HISTORY 3

@interface MLGDetailViewController ()


@property(strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
@end

@implementation MLGDetailViewController

#pragma mark -
#pragma mark Managing the Detail Item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView {
    if (self.detailItem) {
        self.name.text = self.detailItem.name;
        self.note.text = self.detailItem.note;
        self.archiveButton.layer.cornerRadius = 4;
        if ([self.name.text isEqual:@"Untitled Event"]) {
            [self.name selectAll:self];
        }
        if (self.detailItem.state == HISTORY) {
            [self.archiveButton setTitle:@"Delete" forState:UIControlStateNormal];
        }
        else if (self.detailItem.state != HISTORY) {
            [self.archiveButton setTitle:@"Archive" forState:UIControlStateNormal];
        }
    }
}

#pragma mark -
#pragma mark Setting up the view

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self
                                                                         action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [self configureView];
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

#pragma mark -
#pragma mark  Save and Cancel

- (void)save {

    self.detailItem.name = self.name.text;
    self.detailItem.note = self.note.text;

    NSError *error = nil;
    if (![self.detailItem.managedObjectContext save:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        abort();
    }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)cancel {

    if (self.detailItem.state == NEW) {
        [self.detailItem.managedObjectContext deleteObject:self.detailItem];
    }

    NSError *error = nil;
    if (![self.detailItem.managedObjectContext save:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        abort();
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedArchiveButton:(UIButton *)button {
    if (self.detailItem.state == HISTORY) {
        [self.detailItem.managedObjectContext deleteObject:self.detailItem];
    }
    else if (self.detailItem.state != HISTORY) {
        self.detailItem.state = HISTORY;
        self.detailItem.sectionName = @"History";
    }
    [self save];
}

#pragma mark -
#pragma mark Split view for iPad

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark -
#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    return YES;
}


@end
