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

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) NSTimeInterval stop;
@property (nonatomic) int16_t state;
@property (nonatomic) NSTimeInterval timeStamp;

@end
