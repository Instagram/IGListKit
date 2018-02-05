/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

/**
 Conform to this protocol and return value and `ListSectionController`-constructor pairs to display data in a
 `ListSwiftAdapter`.
 */
public protocol ListSwiftAdapterDataSource: class {

    /**
     Return a list of value and `ListSectionController`-constructor pairs.
     
     @param adpater The adapter requesting the data.
     
     @return An array of value and `ListSectionController`-constructor pairs.

     @note `ListSwiftPair` uses "type-erasure" to enforce the same type betweeen the `value` and
     `ListSwiftSectionController` returned in the `constructor` closure. It is recommended that you map and type your
     data. You can also use the abbreviated `.pair(_,_)` method on `ListSwiftPair` to shorten your implementation.

     For example:

     ```
     func values(adapter: ListSwiftAdapter) -> [ValuePair] {
       return values.flatMap({
         if let value = $0 as? Person {
           return .pair(value, { PersonSectionController() })
         }
         return nil
       })
     }
     ```
     */
    func values(adapter: ListSwiftAdapter) -> [ListSwiftPair]

}
