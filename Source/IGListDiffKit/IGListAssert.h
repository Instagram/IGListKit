/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifndef IGAssert
#define IGAssert( condition, ... ) NSCAssert( (condition) , ##__VA_ARGS__)
#endif // IGAssert

#ifndef IGFailAssert
#define IGFailAssert( ... ) IGAssert( (NO) , ##__VA_ARGS__)
#endif // IGFailAssert

#ifndef IGParameterAssert
#define IGParameterAssert( condition ) IGAssert( (condition) , @"Invalid parameter not satisfying: %@", @#condition)
#endif // IGParameterAssert

#ifndef IGAssertMainThread
#define IGAssertMainThread() IGAssert( ([NSThread isMainThread] == YES), @"Must be on the main thread")
#endif // IGAssertMainThread

#ifndef IGAssertNonnull
/// Takes in a potentially-nullable value, asserts that it is not null, and "returns" it as a nonnull
/// value. If the value is `nil`, this is technically unsafe, so use of this macro should be limited
/// to cases where we definitely expect a value to be nonnull, and would be very surprised if it is
/// nil. This is intended to allow us to incrementally improve the nullability coverage and handling
/// in our codebase as we move towards Swift.
#define IGAssertNonnull(value) ({ \
    /* evaluate the value only once, to avoid repeated side-effects */ \
    __typeof(*(value)) *__nonnull IGAssertNonnull_unwrapped_value = (id)(value); \
    /* stringify the value expression with # to embed in assertion message */ \
    IGAssert(IGAssertNonnull_unwrapped_value, @"%s was unexpectedly nil", #value); \
    /* "return" the value to the caller */ \
    IGAssertNonnull_unwrapped_value; \
})
#endif // IGAssertNonnull
