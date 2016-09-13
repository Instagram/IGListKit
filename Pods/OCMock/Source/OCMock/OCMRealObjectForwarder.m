/*
 *  Copyright (c) 2010-2016 Erik Doernenburg and contributors
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

#import <objc/runtime.h>
#import "OCPartialMockObject.h"
#import "OCMRealObjectForwarder.h"
#import "OCMFunctionsPrivate.h"


@implementation OCMRealObjectForwarder

- (void)handleInvocation:(NSInvocation *)anInvocation 
{
	id invocationTarget = [anInvocation target];

    [anInvocation setSelector:OCMAliasForOriginalSelector([anInvocation selector])];
	if ([invocationTarget isProxy])
	{
	    if (class_getInstanceMethod([invocationTarget mockObjectClass], @selector(realObject)))
	    {
	        // the method has been invoked on the mock, we need to change the target to the real object
	        [anInvocation setTarget:[(OCPartialMockObject *)invocationTarget realObject]];
	    }
	    else
	    {
	        [NSException raise:NSInternalInconsistencyException
	                    format:@"Method andForwardToRealObject can only be used with partial mocks and class methods."];
	    }
	}

	[anInvocation invoke];
}


@end
