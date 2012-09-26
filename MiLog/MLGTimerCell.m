//
//  MLGTimerCell.m
//  MiLog
//
//  Created by Christopher Morse on 9/22/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#define NEW 0
#define ACTIVE 1
#define PAUSE 2
#define HISTORY 3

#import "MLGTimerCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MLGTimerCell



@synthesize name, timer, startDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureWithTimerEvent:(TimerEvent *)event
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.startDate.text = [dateFormatter stringFromDate:[event start]];
    self.name.text = [[event name] description];
    self.timer.text = [event timeString];
    self.timer.layer.cornerRadius = 4;
    self.name.textColor = [UIColor colorWithRed:0.18 green:0.37 blue:0.47 alpha:1];
    if (event.state == ACTIVE) {
        self.timer.textColor = [UIColor colorWithRed:0.24 green:0.85 blue:1.0 alpha:1];
    }
    else if (event.state == HISTORY) {
        self.name.textColor = [UIColor grayColor];
        self.timer.textColor = [UIColor grayColor];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else {
        self.timer.textColor = [UIColor colorWithRed:1.0 green:0.05 blue:0.15 alpha:1];
    }

}

@end
