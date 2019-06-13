/**
 Copyright (c) Facebook, Inc. and its affiliates.
 
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

enum CornerRadius {
    case top
    case none
    case bottom
    case both
}
extension UIView {
    func roundCorners(cornersRadius: CornerRadius, radius: CGFloat, height: CGFloat? = nil) {
        var corners: UIRectCorner = UIRectCorner(arrayLiteral: [])
        switch cornersRadius {
        case .both:
            corners = UIRectCorner(arrayLiteral: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        case .bottom:
            corners = UIRectCorner(arrayLiteral: [.bottomLeft, .bottomRight])
        case .top:
            corners = UIRectCorner(arrayLiteral: [.topLeft, .topRight])
        case .none:
            corners = UIRectCorner(arrayLiteral: [])
        }
        var rect = bounds
        if let height = height {
            rect.size.height = height
        }
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func removeRoundCornerMask() {
        applyRoundCornerMask(top: false, bottom: false)
    }

    func applyRoundCornerMaskTop(cornerRadius: CGFloat = 8.0) {
        applyRoundCornerMask(top: true, bottom: false)
    }

    func applyRoundCornerMaskBottom(cornerRadius: CGFloat = 8.0) {
        applyRoundCornerMask(top: false, bottom: true)
    }

    func applyRoundCornerMaskFull(cornerRadius: CGFloat = 8.0) {
        applyRoundCornerMask(top: true, bottom: true)
    }

    private func applyRoundCornerMask(top: Bool, bottom: Bool, cornerRadius: CGFloat = 8.0) {
        guard top || bottom else {
            layer.mask = nil
            return
        }

        let maskLayer = CAShapeLayer()
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        var byRoundingCorners: UIRectCorner = []
        if top && bottom {
            byRoundingCorners = .allCorners
        } else if top {
            byRoundingCorners = [.topRight, .topLeft]
        } else if bottom {
            byRoundingCorners = [.bottomLeft, .bottomRight]
        }
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii).cgPath
        layer.mask = maskLayer
    }
}
