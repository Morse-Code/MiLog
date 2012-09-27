//
//  TimerEvent.h
//  MiLog
//
//  Created by Christopher Morse on 9/22/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimerEvent : NSManagedObject


@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *note;
@property(nonatomic, retain) NSString *timeString;
@property(nonatomic, retain) NSDate *start;
@property(nonatomic, retain) NSDate *stop;
@property(nonatomic) int16_t state;
@property(nonatomic) NSDate *timeStamp;
@property(nonatomic) NSTimeInterval elapsed;
@property(nonatomic, retain) NSString *sectionName;

//Convenience method for adding the recieving entity to the passed ManagedObjectContext
+ (TimerEvent *)addEventToContext:(NSManagedObjectContext *)context;

////Convenience method to return the string name of the entity.
+ (NSString *)entityName;

//Convenience method for setting entity properties using a passed date.
- (NSTimeInterval)setTimeIntervalToDate:(NSDate *)date;

//Convenience method for setting entity properties using a passed date and state {NEW, ACTIVE, PAUSED, HISTORY}
- (void)setElapsedForStopDate:(NSDate *)date
                    withState:(int16_t)state;

- (void)resetTimer;


@end
