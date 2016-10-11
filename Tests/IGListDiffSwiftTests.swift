/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import XCTest
import IGListKit

// conforms to IGListDiffable via NSObject (IGDKCommon) in IGDKCommon.h
class ObjCClass: NSObject {

}

class SwiftClass: IGListDiffable {

    let id: Int
    let value: String

    init(id: Int, value: String) {
        self.id = id
        self.value = value
    }

    @objc func diffIdentifier() -> NSObjectProtocol {
        return NSNumber(value: id)
    }

    func isEqual(_ object: IGListDiffable?) -> Bool {
        if let object = object as? SwiftClass {
            return id == object.id && value == object.value
        }
        return false
    }

}

class IGDiffingSwiftTests: XCTestCase {

    func testConformance() {
        XCTAssertTrue(ObjCClass.conforms(to: IGListDiffable.self))
    }

    func testDiffingStrings() {
        let o: [NSString] = ["a", "b", "c"]
        let n: [NSString] = ["a", "c", "d"]
        let result = IGListDiff(o as [IGListDiffable]?, n, .equality)
        XCTAssertEqual(result.deletes, IndexSet(integer: 1))
        XCTAssertEqual(result.inserts, IndexSet(integer: 2))
        XCTAssertEqual(result.moves.count, 0)
        XCTAssertEqual(result.updates.count, 0)
    }

    func testDiffingNumbers() {
        let o: [NSNumber] = [0, 1, 2]
        let n: [NSNumber] = [0, 2, 4]
        let result = IGListDiff(o as [IGListDiffable]?, n, .equality)
        XCTAssertEqual(result.deletes, IndexSet(integer: 1))
        XCTAssertEqual(result.inserts, IndexSet(integer: 2))
        XCTAssertEqual(result.moves.count, 0)
        XCTAssertEqual(result.updates.count, 0)
    }

    func testDiffingSwiftClass() {
        let o = [SwiftClass(id: 0, value: "a"), SwiftClass(id: 1, value: "b"), SwiftClass(id: 2, value: "c")]
        let n = [SwiftClass(id: 0, value: "a"), SwiftClass(id: 2, value: "c"), SwiftClass(id: 4, value: "d")]
        let result = IGListDiff(o, n, .equality)
        XCTAssertEqual(result.deletes, IndexSet(integer: 1))
        XCTAssertEqual(result.inserts, IndexSet(integer: 2))
        XCTAssertEqual(result.moves.count, 0)
        XCTAssertEqual(result.updates.count, 0)
    }

    func testDiffingSwiftClassPointerComparison() {
        let o = [SwiftClass(id: 0, value: "a"), SwiftClass(id: 1, value: "b"), SwiftClass(id: 2, value: "c")]
        let n = [SwiftClass(id: 0, value: "a"), SwiftClass(id: 2, value: "c"), SwiftClass(id: 4, value: "d")]
        let result = IGListDiff(o, n, .pointerPersonality)
        XCTAssertEqual(result.deletes, IndexSet(integer: 1))
        XCTAssertEqual(result.inserts, IndexSet(integer: 2))
        XCTAssertEqual(result.moves.count, 0)
        XCTAssertEqual(result.updates.count, 2)
    }

    func testDiffingSwiftClassWithUpdates() {
        let o = [SwiftClass(id: 0, value: "a"), SwiftClass(id: 1, value: "b"), SwiftClass(id: 2, value: "c")]
        let n = [SwiftClass(id: 0, value: "b"), SwiftClass(id: 1, value: "b"), SwiftClass(id: 2, value: "b")]
        let result = IGListDiff(o, n, .equality)
        XCTAssertEqual(result.deletes.count, 0)
        XCTAssertEqual(result.inserts.count, 0)
        XCTAssertEqual(result.moves.count, 0)
        XCTAssertEqual(result.updates.count, 2)
    }
}
