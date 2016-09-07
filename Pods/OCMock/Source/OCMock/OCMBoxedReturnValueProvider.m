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

#import "OCMBoxedReturnValueProvider.h"
#import "OCMFunctionsPrivate.h"
#import "NSValue+OCMAdditions.h"

@implementation OCMBoxedReturnValueProvider

- (void)handleInvocation:(NSInvocation *)anInvocation
{
	const char *returnType = [[anInvocation methodSignature] methodReturnType];
    NSUInteger returnTypeSize = [[anInvocation methodSignature] methodReturnLength];
    char valueBuffer[returnTypeSize];
    NSValue *returnValueAsNSValue = (NSValue *)returnValue;

    if([self isMethodReturnType:returnType compatibleWithValueType:[returnValueAsNSValue objCType]])
    {
        [returnValueAsNSValue getValue:valueBuffer];
        [anInvocation setReturnValue:valueBuffer];
    }
    else if([returnValueAsNSValue getBytes:valueBuffer objCType:returnType])
    {
        [anInvocation setReturnValue:valueBuffer];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Return value cannot be used for method; method signature declares '%s' but value is '%s'.", returnType, [returnValueAsNSValue objCType]];
    }
}


- (BOOL)isMethodReturnType:(const char *)returnType compatibleWithValueType:(const char *)valueType
{
    /* Same types are obviously compatible */
    if(strcmp(returnType, valueType) == 0)
        return YES;

    /* Allow void* for methods that return id, mainly to be able to handle nil */
    if(strcmp(returnType, @encode(id)) == 0 && strcmp(valueType, @encode(void *)) == 0)
        return YES;

    return OCMEqualTypesAllowingOpaqueStructs(returnType, valueType);
}


@end
