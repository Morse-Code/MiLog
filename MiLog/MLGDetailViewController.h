//
//  MLGDetailViewController.h
//  MiLog
//
//  Created by Christopher Morse on 8/29/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerEvent.h"

@class TimerEvent;

@interface MLGDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate>



@property(strong, nonatomic) TimerEvent *detailItem;

@property(weak, nonatomic) IBOutlet UITextField *name;
@property(weak, nonatomic) IBOutlet UITextView *note;
@property(weak, nonatomic) IBOutlet UIButton *archiveButton;

//Saves modified name and note fields to NSManagedObjectContext.
- (void)save;

//Effectively discards any changes to name and note fields and saves the NSManagedObjectContext.
- (void)cancel;

- (IBAction)pressedArchiveButton:(UIButton *)button;

@end
