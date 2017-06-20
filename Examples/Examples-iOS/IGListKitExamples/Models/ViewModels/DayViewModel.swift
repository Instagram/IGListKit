/**
 Copyright (c) 2016-present, Facebook, Inc. All rights reserved.
 
 The examples provided by Facebook are for non-commercial testing and evaluation
 purposes only. Facebook reserves all rights not expressly granted.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import IGListKit

final class DayViewModel {

    let day: Int
    let today: Bool
    let selected: Bool
    let appointments: Int

    init(day: Int, today: Bool, selected: Bool, appointments: Int) {
        self.day = day
        self.today = today
        self.selected = selected
        self.appointments = appointments
    }

}

extension DayViewModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return day as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if self === object { return true }
        guard let object = object as? DayViewModel else { return false }
        return today == object.today && selected == object.selected && appointments == object.appointments
    }

}
