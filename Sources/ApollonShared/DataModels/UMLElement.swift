import SwiftUI

/// Contains all information of a specific UML element
/// Note: this is not a struct because we need references to handle parent-child relationship between elements
public class UMLElement: Codable, SelectableUMLItem {
    public let id: String?
    public var name: String?
    public var type: UMLElementType?
    public var owner: String?
    public var bounds: Boundary?
    public var direction: ElementDirection?
    public var assessmentNote: String?
    public var attributes: [String]?
    public var methods: [String]?
    public var children: [UMLElement]? = [] // not decoded

    /// Public Init, so that new UML elements can be created
    public init(id: String? = nil, name: String? = nil, type: UMLElementType? = nil, owner: String? = nil, bounds: Boundary? = nil, direction: ElementDirection? = nil, assessmentNote: String? = nil, attributes: [String]? = nil, methods: [String]? = nil) {
        self.id = id ?? UUID().uuidString.lowercased()
        self.name = name ?? type?.rawValue
        self.type = type
        self.owner = owner
        self.bounds = bounds
        self.direction = direction
        self.assessmentNote = assessmentNote
        self.attributes = attributes ?? []
        self.methods = methods ?? []
    }

    /// UMLElement Coding Keys
    public enum UMLElementCodingKeys: String, CodingKey {
        case id
        case name
        case type
        case owner
        case bounds
        case direction
        case assessmentNote
        case attributes
        case methods
    }

    /// Public encode function to encode elements without the children property
    public func encode(to encoder: Encoder) throws {
        self.encodeChildrenToArray()
        var container = encoder.container(keyedBy: UMLElementCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(owner, forKey: .owner)
        try container.encode(bounds, forKey: .bounds)
        try container.encode(direction, forKey: .direction)
        try container.encode(assessmentNote, forKey: .assessmentNote)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(methods, forKey: .methods)
    }

    /// Children of this element sorted by their vertical position (top to bottom)
    public var verticallySortedChildren: [UMLElement]? {
        children?.sorted(by: { ($0.bounds?.y ?? 0.0) < ($1.bounds?.y ?? 0.0) })
    }

    /// Returns the element type as a String
    public var typeAsString: String? {
        type?.rawValue
    }

    public var highlightPath: Path? {
        guard let boundsAsCGRect else {
            return nil
        }

        return Path(boundsAsCGRect.insetBy(dx: -1, dy: -1))
    }

    public lazy var badgeLocation: CGPoint? = {
        guard let boundsAsCGRect else {
            return nil
        }

        return CGPoint(x: boundsAsCGRect.maxX, y: boundsAsCGRect.minY)
    }()

    /// Returns a rectangular path from the top of the element until the top of the vertically highest child
    public var suggestedHighlightPath: Path? {
        guard let boundsAsCGRect,
              let highestChildMinY = verticallySortedChildren?.first?.boundsAsCGRect?.minY else {
            return highlightPath
        }

        var path = Path()
        path.move(to: boundsAsCGRect.origin)
        path.addLine(to: .init(x: boundsAsCGRect.maxX, y: boundsAsCGRect.minY))
        path.addLine(to: .init(x: boundsAsCGRect.maxX, y: highestChildMinY))
        path.addLine(to: .init(x: boundsAsCGRect.minX, y: highestChildMinY))
        return path
    }

    /// Recursively looks for the child UML element located at the given point
    public func getChild(at point: CGPoint) -> UMLElement? {
        guard let children else {
            return nil
        }

        for child in children where child.boundsContains(point: point) {
            return child.getChild(at: point) ?? child
        }

        return nil
    }

    /// Add a child to an UML element
    public func addChild(_ child: UMLElement) {
        if children == nil {
            self.children = [child]
        } else {
            self.children?.append(child)
        }
    }

    /// Remove a child from a UML element
    public func removeChild(_ child: UMLElement) {
        if let allChildren = self.verticallySortedChildren,
           let indexOfChildToRemove = allChildren.firstIndex(where: { $0.id == child.id }) {
            for (index, childElement) in allChildren.enumerated() where index > indexOfChildToRemove {
                let newYForElement = (childElement.bounds?.y ?? 0) - (child.bounds?.height ?? 0)
                allChildren[index].bounds?.y = newYForElement
            }
        }
        let newHeight = (self.bounds?.height ?? 0) - (child.bounds?.height ?? 0)
        self.bounds?.height = newHeight
        self.children?.removeAll { $0.id == child.id }
    }

    public func boundsContains(point: CGPoint) -> Bool {
        guard let bounds else {
            return false
        }

        let isXWithinBounds = point.x > bounds.x && point.x < (bounds.x + bounds.width)
        let isYWithinBounds = point.y > bounds.y && point.y < (bounds.y + bounds.height)

        return isXWithinBounds && isYWithinBounds
    }

    public func encodeChildrenToArray() {
        if let children {
            for child in children {
                if [UMLElementType.classAttribute, .objectAttribute].contains(child.type) {
                    self.attributes?.append(child.id ?? "")
                }
                if [UMLElementType.classMethod, .objectMethod].contains(child.type) {
                    self.methods?.append(child.id ?? "")
                }
            }
        }
    }
}

/// Hashable (Equatable) extension
extension UMLElement: Hashable {
    public static func == (lhs: UMLElement, rhs: UMLElement) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.owner == rhs.owner &&
        lhs.bounds == rhs.bounds &&
        lhs.direction == rhs.direction &&
        lhs.assessmentNote == rhs.assessmentNote &&
        lhs.attributes == rhs.attributes &&
        lhs.methods == rhs.methods
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(owner)
        hasher.combine(bounds)
        hasher.combine(direction)
        hasher.combine(assessmentNote)
        hasher.combine(attributes)
        hasher.combine(methods)
    }
}
