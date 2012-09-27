//
//  MLGTimerCell.h
//  MiLog
//
//  Created by Christopher Morse on 9/22/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TimerEvent.h"

@interface MLGTimerCell : UITableViewCell


@property(weak, nonatomic) IBOutlet UILabel *name;
@property(weak, nonatomic) IBOutlet UILabel *startDate;
@property(weak, nonatomic) IBOutlet UILabel *timer;

- (void)configureWithTimerEvent:(TimerEvent *)event;


@end
