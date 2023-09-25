import SwiftUI

/// Represents any UML item (element, relationship, etc.) that can be selected by the user
public protocol SelectableUMLItem {
    var id: String? { get }
    var name: String? { get set }
    var owner: String? { get set }
    var bounds: Boundary? { get set }
    /// The path that should be highlighted when this element is selected
    var highlightPath: Path? { get }
    /// The path that should be highlighted when the corresponding feedback cell is tapped
    var temporaryHighlightPath: Path? { get }
    /// The path that should be highlighted if the item has a suggested feedback
    var suggestedHighlightPath: Path? { get }
    /// The point where this UML item prefers to have it's badge. Badges are used to indicate a feedback referencing this item
    var badgeLocation: CGPoint? { get }
    var boundsAsCGRect: CGRect? { get }
    var typeAsString: String? { get }
    /// Returns true if the given point lies within the boundary of this element
    func boundsContains(point: CGPoint) -> Bool
}

extension SelectableUMLItem {
    public var boundsAsCGRect: CGRect? {
        guard let xCoordinate = bounds?.x,
              let yCoordinate = bounds?.y,
              let width = bounds?.width,
              let height = bounds?.height else {
            return nil
        }
        return CGRect(x: xCoordinate, y: yCoordinate, width: width, height: height)
    }
    
    public var temporaryHighlightPath: Path? {
        highlightPath
    }
    
    public var suggestedHighlightPath: Path? {
        highlightPath
    }
}
