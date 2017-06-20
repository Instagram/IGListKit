/*
 *  Copyright (c) 2009-2016 Erik Doernenburg and contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

#import "OCObserverMockObject.h"
#import "OCMObserverRecorder.h"
#import "OCMLocation.h"
#import "OCMFunctionsPrivate.h"


@implementation OCObserverMockObject

#pragma mark  Initialisers, description, accessors, etc.

- (id)init
{
    if ((self = [super init]))
    {
        recorders = [[NSMutableArray alloc] init];
        centers = [[NSMutableArray alloc] init];
    }
	
	return self;
}

- (id)retain
{
    return [super retain];
}

- (void)dealloc
{
    for(NSNotificationCenter *c in centers)
        [c removeObserver:self];
    [centers release];
	[recorders release];
	[super dealloc];
}

- (NSString *)description
{
	return @"OCMockObserver";
}

- (void)setExpectationOrderMatters:(BOOL)flag
{
    expectationOrderMatters = flag;
}

- (void)autoRemoveFromCenter:(NSNotificationCenter *)aCenter
{
    @synchronized(centers)
    {
        [centers addObject:aCenter];
    }
}


#pragma mark  Public API

- (id)expect
{
	OCMObserverRecorder *recorder = [[[OCMObserverRecorder alloc] init] autorelease];
    @synchronized(recorders)
    {
        [recorders addObject:recorder];
    }
	return recorder;
}

- (void)verify
{
    [self verifyAtLocation:nil];
}

- (void)verifyAtLocation:(OCMLocation *)location
{
    @synchronized(recorders)
    {
        if([recorders count] == 1)
        {
            NSString *description = [NSString stringWithFormat:@"%@: expected notification was not observed: %@",
             [self description], [[recorders lastObject] description]];
            OCMReportFailure(location, description);
        }
        else if([recorders count] > 0)
        {
            NSString *description = [NSString stringWithFormat:@"%@ : %@ expected notifications were not observed.",
             [self description], @([recorders count])];
            OCMReportFailure(location, description);
        }
    }
}


#pragma mark  Receiving recording requests via macro

- (NSNotification *)notificationWithName:(NSString *)name object:(id)sender
{
    return [[self expect] notificationWithName:name object:sender];
}

- (NSNotification *)notificationWithName:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo
{
    return [[self expect] notificationWithName:name object:sender userInfo:userInfo];
}


#pragma mark  Receiving notifications

- (void)handleNotification:(NSNotification *)aNotification
{
    @synchronized(recorders)
    {
        NSUInteger i, limit;
        
        limit = expectationOrderMatters ? 1 : [recorders count];
        for(i = 0; i < limit; i++)
        {
            if([[recorders objectAtIndex:i] matchesNotification:aNotification])
            {
                [recorders removeObjectAtIndex:i];
                return;
            }
        }
    }
	[NSException raise:NSInternalInconsistencyException format:@"%@: unexpected notification observed: %@", [self description], 
	  [aNotification description]];
}


@end
