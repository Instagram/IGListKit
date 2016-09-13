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

#import "OCMInvocationStub.h"
#import "OCMFunctionsPrivate.h"
#import "OCMArg.h"
#import "OCMArgAction.h"
#import "NSInvocation+OCMAdditions.h"

@implementation OCMInvocationStub

- (id)init
{
    self = [super init];
    invocationActions = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    [invocationActions release];
    [super dealloc];
}


- (void)addInvocationAction:(id)anAction
{
    [invocationActions addObject:anAction];
}

- (NSArray *)invocationActions
{
    return invocationActions;
}


- (void)handleInvocation:(NSInvocation *)anInvocation
{
    NSMethodSignature *signature = [recordedInvocation methodSignature];
    NSUInteger n = [signature numberOfArguments];
    for(NSUInteger i = 2; i < n; i++)
    {
        id recordedArg = [recordedInvocation getArgumentAtIndexAsObject:i];
        id passedArg = [anInvocation getArgumentAtIndexAsObject:i];

        if([recordedArg isProxy])
            continue;

        if([recordedArg isKindOfClass:[NSValue class]])
            recordedArg = [OCMArg resolveSpecialValues:recordedArg];

        if(![recordedArg isKindOfClass:[OCMArgAction class]])
            continue;

        [recordedArg handleArgument:passedArg];
    }

    [invocationActions makeObjectsPerformSelector:@selector(handleInvocation:) withObject:anInvocation];
}

@end
