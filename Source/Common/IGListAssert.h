/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#ifndef IGAssert
#define IGAssert( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // IGAssert

#ifndef IGParameterAssert
#define IGParameterAssert( condition ) IGAssert( (condition) , @"Invalid parameter not satisfying: %@", @#condition)
#endif // IGParameterAssert

#ifndef IGAssertMainThread
#define IGAssertMainThread() IGAssert( ([NSThread isMainThread] == YES), @"Must be on the main thread")
#endif // IGAssertMainThread
