//
//  MLGTimerCell.m
//  MiLog
//
//  Created by Christopher Morse on 9/22/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "MLGTimerCell.h"

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
}

@end
