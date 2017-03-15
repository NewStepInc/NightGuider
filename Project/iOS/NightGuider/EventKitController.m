//
//  EventKitController.m
//  Nightlife_2
//
//  Created by Werner Kohn on 05.04.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "EventKitController.h"

@implementation EventKitController

- (id) init {
    self = [super init];
    if (self) {
        _eventStore = [[EKEventStore alloc] init];
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                _eventAccess = YES;
            }
            else {
                NSLog(@"Event access not granted: %@", error);
            }
        }];
        
        /*
        [_eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if (granted) { _reminderAccess = YES;
            } else {
                NSLog(@"Reminder access not granted: %@",error);
            }
        }];
         */
    }
    return self;
}

- (void) addEventWithName:(NSString*) eventName startTime:(NSDate*) startDate endTime:(NSDate*) endDate {
    if (!_eventAccess) {
        NSLog(@"No event acccess!");
        return;
    }
    
    //1. Create an Event
    EKEvent *event = [EKEvent
    eventWithEventStore:self.eventStore];
    event.title = eventName;
    //3. Set the start and end date
    event.startDate = startDate;
    event.endDate = endDate;
    //4. Set an alarm (This is optional)
  //  EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-72000];
    //EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-97200];
    EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:[[NSUserDefaults standardUserDefaults] integerForKey:@"alarmBeforeEvent"]];

    [event addAlarm:alarm];
    //5. Add a note (This is optional)
    //event.notes = @"This will be exciting";
    //6. Specify the calendar to store the event
    event.calendar=self.eventStore.defaultCalendarForNewEvents;
    
    NSError *err;
    BOOL success = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    if (!success) {
        NSLog(@"There was an error saving event: %@", err);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event konnte dem Kalender leider nicht hinzugefügt werden" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
            [alert show];
        

    }
    else {
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event wurde dem Kalender hinzugefügt" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    
    [alert show];
    }

}

- (void) addEventWithName:(NSString*) eventName startTime:(NSDate*) startDate endTime:(NSDate*) endDate timeBeforeEvent:(int) timeBeforeEvent{
    if (!_eventAccess) {
        NSLog(@"No event acccess!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kein Zugriff" message:@"Bitte erlaube den Zugriff auf den Kalender in den Einstellungen" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        
        [alert show];

        return;
    }
    
    //1. Create an Event
    EKEvent *event = [EKEvent
                      eventWithEventStore:self.eventStore];
    event.title = eventName;
    //3. Set the start and end date
    event.startDate = startDate;
    event.endDate = endDate;
    //4. Set an alarm (This is optional)
    //  EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-72000];
    //EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:-97200];
    EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:timeBeforeEvent];
    
    [event addAlarm:alarm];
    //5. Add a note (This is optional)
    //event.notes = @"This will be exciting";
    //6. Specify the calendar to store the event
    event.calendar=self.eventStore.defaultCalendarForNewEvents;
    
    NSError *err;
    BOOL success = [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
    if (!success) {
        NSLog(@"There was an error saving event: %@", err);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event konnte dem Kalender leider nicht hinzugefügt werden" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        
        [alert show];
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event wurde dem Kalender hinzugefügt" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        
        [alert show];
    }
    
}


@end
