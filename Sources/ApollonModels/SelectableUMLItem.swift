import SwiftUI

/// Represents any UML item (element, relationship, etc.) that can be selected by the user
public protocol SelectableUMLItem {
    var id: String? { get }
    var name: String? { get set }
    var owner: String? { get set }
    var bounds: Boundary? { get set }
    var boundsAsCGRect: CGRect? { get }
    var typeAsString: String? { get }
    /// Return true if the given point lies within the boundary of this element
    func boundsContains(point: CGPoint) -> Bool
}

extension SelectableUMLItem { // default implementations for all conforming types
    public var boundsAsCGRect: CGRect? {
        guard let xCoordinate = bounds?.x,
              let yCoordinate = bounds?.y,
              let width = bounds?.width,
              let height = bounds?.height else {
            return nil
        }
        return CGRect(x: xCoordinate, y: yCoordinate, width: width, height: height)
    }
}
