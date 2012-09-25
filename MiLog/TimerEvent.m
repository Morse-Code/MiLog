//
//  TimerEvent.m
//  MiLog
//
//  Created by Christopher Morse on 9/22/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "TimerEvent.h"

#define NEW 0
#define ACTIVE 1
#define PAUSE 2
#define HISTORY 3

@interface TimerEvent ()



@property(nonatomic) NSTimeInterval elapsedAlias;

- (NSString *)timeStringForInterval:(NSTimeInterval)interval;

@end

@implementation TimerEvent



@dynamic name;
@dynamic note;
@dynamic timeString;
@dynamic start;
@dynamic stop;
@dynamic state;
@dynamic timeStamp;
@synthesize elapsedAlias = elapsed;
@dynamic sectionName;


+ (TimerEvent *)addEventToContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:[TimerEvent entityName]
                                              inManagedObjectContext:context];
    NSAssert1(entity != nil, @"The entity description for TimerEvent in %@ is nil", context);
    TimerEvent *entry = [[TimerEvent alloc] initWithEntity:entity
                            insertIntoManagedObjectContext:context];
    entry.timeStamp = [NSDate date];
    entry.state = NEW;
    entry.elapsed = 0.0;
    entry.stop = nil;
    entry.timeString = [entry timeStringForInterval:entry.elapsed];
    entry.sectionName = @"Active Timers";
    NSError *error = nil;
    if (![context save:&error]) {
        [NSException raise:NSInternalInconsistencyException format:@"An error occured when saving the context: %@",
                                                                   [error localizedDescription]];
    }
    return entry;
}

+ (NSString *)entityName
{
    return @"TimerEvent";
}


- (void)setElapsed:(NSTimeInterval)interval
{
    self.elapsedAlias = interval;
}

- (NSTimeInterval)elapsed
{
    return self.elapsedAlias;
}

- (NSTimeInterval)setTimeIntervalToDate:(NSDate *)date
{
    NSTimeInterval interval = [date timeIntervalSinceDate:self.start];
    interval += self.elapsed;
    self.timeString = [self timeStringForInterval:interval];
    return interval;
}

- (NSString *)timeStringForInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *time = [dateFormatter stringFromDate:date];
    return time;
}

- (void)setElapsedForStopDate:(NSDate *)date
                    withState:(int16_t)state
{
    if (state == HISTORY) {
        self.sectionName = @"History";
    }
    else {
        self.sectionName = @"Active Timers";
    }
    self.state = state;
    self.stop = date;
    self.elapsed = [self setTimeIntervalToDate:date];
}

@end
