/*
 *  Copyright (c) 2014-2016 Erik Doernenburg and contributors
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

#import "OCMMacroState.h"
#import "OCMStubRecorder.h"
#import "OCMockObject.h"
#import "OCMExpectationRecorder.h"
#import "OCMVerifier.h"
#import "OCMInvocationMatcher.h"


@implementation OCMMacroState

static NSString *const OCMGlobalStateKey = @"OCMGlobalStateKey";

#pragma mark  Methods to begin/end macros

+ (void)beginStubMacro
{
    OCMStubRecorder *recorder = [[[OCMStubRecorder alloc] init] autorelease];
    OCMMacroState *macroState = [[OCMMacroState alloc] initWithRecorder:recorder];
    [NSThread currentThread].threadDictionary[OCMGlobalStateKey] = macroState;
    [macroState release];
}

+ (OCMStubRecorder *)endStubMacro
{
    NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
    OCMMacroState *globalState = threadDictionary[OCMGlobalStateKey];
    OCMStubRecorder *recorder = [(OCMStubRecorder *)[globalState recorder] retain];
    [threadDictionary removeObjectForKey:OCMGlobalStateKey];
    return [recorder autorelease];
}


+ (void)beginExpectMacro
{
    OCMExpectationRecorder *recorder = [[[OCMExpectationRecorder alloc] init] autorelease];
    OCMMacroState *macroState = [[OCMMacroState alloc] initWithRecorder:recorder];
    [NSThread currentThread].threadDictionary[OCMGlobalStateKey] = macroState;
    [macroState release];
}

+ (OCMStubRecorder *)endExpectMacro
{
    return [self endStubMacro];
}


+ (void)beginRejectMacro
{
    OCMExpectationRecorder *recorder = [[[OCMExpectationRecorder alloc] init] autorelease];
    [recorder never];
    OCMMacroState *macroState = [[OCMMacroState alloc] initWithRecorder:recorder];
    [NSThread currentThread].threadDictionary[OCMGlobalStateKey] = macroState;
    [macroState release];
}

+ (OCMStubRecorder *)endRejectMacro
{
    return [self endStubMacro];
}


+ (void)beginVerifyMacroAtLocation:(OCMLocation *)aLocation
{
    OCMVerifier *recorder = [[[OCMVerifier alloc] init] autorelease];
    [recorder setLocation:aLocation];
    OCMMacroState *macroState = [[OCMMacroState alloc] initWithRecorder:recorder];
    [NSThread currentThread].threadDictionary[OCMGlobalStateKey] = macroState;
    [macroState release];
}

+ (void)endVerifyMacro
{
    [[NSThread currentThread].threadDictionary removeObjectForKey:OCMGlobalStateKey];
}


#pragma mark  Accessing global state

+ (OCMMacroState *)globalState
{
    return [NSThread currentThread].threadDictionary[OCMGlobalStateKey];
}


#pragma mark  Init, dealloc, accessors

- (id)initWithRecorder:(OCMRecorder *)aRecorder
{
    if ((self = [super init]))
    {
        recorder = [aRecorder retain];
    }
    
    return self;
}

- (void)dealloc
{
    [recorder release];
    NSAssert([NSThread currentThread].threadDictionary[OCMGlobalStateKey] != self, @"Unexpected dealloc while set as the global state");
    [super dealloc];
}

- (OCMRecorder *)recorder
{
    return recorder;
}


#pragma mark  Changing the recorder

- (void)switchToClassMethod
{
    [recorder classMethod];
}


@end
