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

- (void)save;

- (void)cancel;

@end
