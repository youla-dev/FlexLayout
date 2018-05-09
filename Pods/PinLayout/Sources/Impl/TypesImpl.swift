//  Copyright (c) 2017 Luc Dion
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

typealias Context = () -> String
typealias Size = (width: CGFloat?, height: CGFloat?)

extension HorizontalAlign {
    var description: String {
        switch self {
        case .left: return "left"
        case .center: return "center"
        case .right: return "right"
        case .start: return "start"
        case .end: return "end"
        }
    }
}

extension VerticalAlign {
    var description: String {
        switch self {
        case .top: return "top"
        case .center: return "center"
        case .bottom: return "bottom"
        }
    }
}
    
class EdgeListImpl: EdgeList {
    internal let view: PView

    init(view: PView) {
        self.view = view
    }

    var top: VerticalEdge { return VerticalEdgeImpl(view: view, type: .top) }
    var vCenter: VerticalEdge { return VerticalEdgeImpl(view: view, type: .vCenter) }
    var bottom: VerticalEdge { return VerticalEdgeImpl(view: view, type: .bottom) }

    var left: HorizontalEdge { return HorizontalEdgeImpl(view: view, type: .left) }
    var hCenter: HorizontalEdge { return HorizontalEdgeImpl(view: view, type: .hCenter) }
    var right: HorizontalEdge { return HorizontalEdgeImpl(view: view, type: .right) }
    
    // RTL support
    var start: HorizontalEdge { return view.isLTR() ? left : right }
    var end: HorizontalEdge { return view.isLTR() ? right : left }
}

class HorizontalEdgeImpl: HorizontalEdge {
    enum EdgeType: String {
        case left
        case hCenter
        case right
    }

    let view: PView
    let type: EdgeType

    func x(keepTransform: Bool) -> CGFloat {
        let rect = Coordinates.getViewRect(view, keepTransform: keepTransform)
        
        switch type {
        case .left:    return rect.origin.x
        case .hCenter: return rect.midX
        case .right:   return rect.maxX
        }
    }

    internal init(view: PView, type: EdgeType) {
        self.view = view
        self.type = type
    }
}

class VerticalEdgeImpl: VerticalEdge {
    enum EdgeType: String {
        case top
        case vCenter
        case bottom
    }
    
    internal let view: PView
    internal let type: EdgeType

    func y(keepTransform: Bool) -> CGFloat {
        let rect = Coordinates.getViewRect(view, keepTransform: keepTransform)
        
        switch type {
        case .top:     return rect.origin.y
        case .vCenter: return rect.midY
        case .bottom:  return rect
            .maxY
        }
    }

    internal init(view: PView, type: EdgeType) {
        self.view = view
        self.type = type
    }
}

class AnchorListImpl: AnchorList {
    internal let view: PView

    internal init(view: PView) {
        self.view = view
    }

    var topLeft: Anchor { return AnchorImpl(view: view, type: .topLeft) }
    var topCenter: Anchor { return AnchorImpl(view: view, type: .topCenter) }
    var topRight: Anchor { return AnchorImpl(view: view, type: .topRight) }
    var centerLeft: Anchor { return AnchorImpl(view: view, type: .centerLeft) }
    var center: Anchor { return AnchorImpl(view: view, type: .center) }
    var centerRight: Anchor { return AnchorImpl(view: view, type: .centerRight) }
    var bottomLeft: Anchor { return AnchorImpl(view: view, type: .bottomLeft) }
    var bottomCenter: Anchor { return AnchorImpl(view: view, type: .bottomCenter) }
    var bottomRight: Anchor { return AnchorImpl(view: view, type: .bottomRight) }

    // RTL support
    var topStart: Anchor { return view.isLTR() ? topLeft : topRight }
    var topEnd: Anchor { return view.isLTR() ? topRight : topLeft }
    var centerStart: Anchor { return view.isLTR() ? centerLeft : centerRight }
    var centerEnd: Anchor { return view.isLTR() ? centerRight : centerLeft }
    var bottomStart: Anchor { return view.isLTR() ? bottomLeft : bottomRight }
    var bottomEnd: Anchor { return view.isLTR() ? bottomRight : bottomLeft }
}

enum AnchorType: String {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
}

class AnchorImpl: Anchor {
    let view: PView
    let type: AnchorType

    func point(keepTransform: Bool) -> CGPoint {
        switch type {
        case .topLeft: return Coordinates.topLeft(view, keepTransform: keepTransform)
        case .topCenter: return Coordinates.topCenter(view, keepTransform: keepTransform)
        case .topRight: return Coordinates.topRight(view, keepTransform: keepTransform)
        case .centerLeft: return Coordinates.centerLeft(view, keepTransform: keepTransform)
        case .center: return Coordinates.center(view, keepTransform: keepTransform)
        case .centerRight: return Coordinates.centerRight(view, keepTransform: keepTransform)
        case .bottomLeft: return Coordinates.bottomLeft(view, keepTransform: keepTransform)
        case .bottomCenter: return Coordinates.bottomCenter(view, keepTransform: keepTransform)
        case .bottomRight: return Coordinates.bottomRight(view, keepTransform: keepTransform)
        }
    }

    fileprivate init(view: PView, type: AnchorType) {
        self.view = view
        self.type = type
    }
}
 
extension CGFloat {
    public var description: String {
        if self.truncatingRemainder(dividingBy: 1) == 0.0 {
            return "\(Int(self))"
        } else {
            return "\(self)"
        }
    }
}
    
internal extension FitType {
    var name: String {
        switch self {
        case .width: return ".width"
        case .height: return ".height"
        case .widthFlexible: return ".widthFlexible"
        case .heightFlexible: return ".heightFlexible"
        }
    }
    
    var isFlexible: Bool {
        return self == .widthFlexible || self == .heightFlexible
    }
}

