//
//  EventKitController.h
//  Nightlife_2
//
//  Created by Werner Kohn on 05.04.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>


@interface EventKitController : NSObject

@property (strong, readonly) EKEventStore *eventStore;
@property (assign, readonly) BOOL eventAccess;
@property (assign, readonly) BOOL reminderAccess;

-(void)addEventWithName:(NSString*)eventName startTime:(NSDate*)startDate endTime:(NSDate*)endDate;
-(void)addEventWithName:(NSString*)eventName startTime:(NSDate*)startDate endTime:(NSDate*)endDate timeBeforeEvent:(int) timeBeforeEvent;


@end
