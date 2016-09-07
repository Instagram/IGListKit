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

#import "OCMPassByRefSetter.h"


@implementation OCMPassByRefSetter

- (id)initWithValue:(id)aValue
{
    if ((self = [super init]))
    {
        value = [aValue retain];
    }
	
	return self;
}

- (void)dealloc
{
	[value release];
	[super dealloc];
}

- (void)handleArgument:(id)arg
{
    void *pointerValue = [arg pointerValue];
    if(pointerValue != NULL)
    {
        if([value isKindOfClass:[NSValue class]])
            [(NSValue *)value getValue:pointerValue];
        else
            *(id *)pointerValue = value;
    }
}

@end
