/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifndef IGAssert
#define IGAssert( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // IGAssert

#ifndef IGWarn
#define IGWarn( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // IGWarn

#ifndef IGWarnAssert
#define IGWarnAssert( ... ) IGAssert( (NO) , ##__VA_ARGS__)
#endif // IGWarnAssert

#ifndef IGFailAssert
#define IGFailAssert( ... ) IGAssert( (NO) , ##__VA_ARGS__)
#endif // IGFailAssert

#ifndef IGFailure
#define IGFailure( ... ) IGAssert( (NO) , ##__VA_ARGS__)
#endif // IGFailure


#ifndef IGParameterAssert
#define IGParameterAssert( condition ) IGAssert( (condition) , @"Invalid parameter not satisfying: %@", @#condition)
#endif // IGParameterAssert

#ifndef IGAssertMainThread
#define IGAssertMainThread() IGAssert( ([NSThread isMainThread] == YES), @"Must be on the main thread")
#endif // IGAssertMainThread
