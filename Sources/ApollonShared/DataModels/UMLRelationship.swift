import Foundation
import SwiftUI

/// Contains all information of a specific UML relationship
public class UMLRelationship: Codable, SelectableUMLItem {
    public let id: String?
    public var name: String?
    public var type: UMLRelationshipType?
    public var owner: String?
    public var bounds: Boundary?
    public var assessmentNote: String?
    public var path: [PathPoint]?
    public var source: UMLRelationshipEndPoint?
    public var target: UMLRelationshipEndPoint?
    public var isManuallyLayouted: Bool?
    public var messages: [String : UMLElement]?

    /// Public Init, so that new UML relationships can be created
    public init(id: String? = nil, name: String? = nil, type: UMLRelationshipType? = nil, owner: String? = nil, bounds: Boundary? = nil, assessmentNote: String? = nil, path: [PathPoint]? = nil, source: UMLRelationshipEndPoint? = nil, target: UMLRelationshipEndPoint? = nil, isManuallyLayouted: Bool? = nil, messages: [String : UMLElement]? = nil) {
        self.id = id ?? UUID().uuidString.lowercased()
        self.name = name ?? ""
        self.type = type
        self.owner = owner ?? ""
        self.bounds = bounds
        self.assessmentNote = assessmentNote
        self.path = path
        self.source = source
        self.target = target
        self.isManuallyLayouted = isManuallyLayouted ?? false
        self.messages = messages
    }

    /// Returns the relationship type as a String
    public var typeAsString: String? {
        type?.rawValue
    }

    /// Contains rectangles drawn between PathPoints
    private var pathRects: [CGRect] {
        guard let path,
              let boundsX = bounds?.x,
              let boundsY = bounds?.y,
              let boundsAsCGRect else {
            return []
        }

        var result = [CGRect]()

        // Iterate through points and create CGRects between them
        for index in 0..<path.count where index != path.count - 1 {
            let pointA = path[index].asCGPoint
            let pointB = path[index + 1].asCGPoint

            var rectPath = Path()
            rectPath.addLines([pointA, pointB])

            let pathRect = rectPath.boundingRect.insetBy(dx: -15, dy: -15)
            let pathRectWithOffset = pathRect.offsetBy(dx: boundsX, dy: boundsY)

            result.append(pathRectWithOffset.intersection(boundsAsCGRect))
        }

        return result
    }

    public var highlightPath: Path? {
        var result = Path()

        if let pathWithCGPoints {
            result = pathWithCGPoints.strokedPath(.init(lineWidth: 20))
        } else {
            result.addRects(pathRects)
        }
        return result
    }

    public var temporaryHighlightPath: Path? {
        guard let path, let boundsAsCGRect else {
            return nil
        }
        var result = Path()
        result.addLines(path.map({ $0.asCGPoint.applying(.init(translationX: boundsAsCGRect.minX, y: boundsAsCGRect.minY)) }))
        return result
    }

    /// Calculates the mid point of a relationship
    public var badgeLocation: CGPoint? {
        guard let path, let boundsAsCGRect else {
            return nil
        }

        // The idea is to find the mid point if the number of points is odd.
        // If the number of points is even, then the number of pathRects between them is going to be odd. This means we can find the mid CGRect and take it's mid point to place the badge.

        if !path.count.isMultiple(of: 2) { // odd point count
            return path[path.count / 2].asCGPoint.applying(.init(translationX: boundsAsCGRect.minX,
                                                                 y: boundsAsCGRect.minY)) // mid point
        } else if !pathRects.count.isMultiple(of: 2) { // odd rect count
            let midRect = pathRects[pathRects.count / 2]
            return CGPoint(x: midRect.midX, y: midRect.midY) // mid point
        }

        return nil
    }

    /// Maps the different points into one path
    public var pathWithCGPoints: Path? {
        guard let boundsAsCGRect,
              let selfPath = self.path,
              selfPath.count >= 2 else {
            return nil
        }

        let points = selfPath.map {
            $0.asCGPoint.applying(.init(translationX: boundsAsCGRect.minX,
                                        y: boundsAsCGRect.minY))
        }

        var path = Path()
        path.addLines(Array(points))

        return path
    }

    public func boundsContains(point: CGPoint) -> Bool {
        if let pathWithCGPoints {
            return pathWithCGPoints.strokedPath(.init(lineWidth: 20)).contains(point)
        }
        return pathRects.contains(where: { $0.contains(point) })
    }

    /// Swaps the source and target UMLRelationshipEndPoints
    public func switchSourceAndTarget() {
        let tempEndpoint = source
        source = target
        target = tempEndpoint
    }
}

public struct PathPoint: Codable {
    // swiftlint:disable identifier_name
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public var asCGPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    public func distanceToSquared(_ other: PathPoint) -> CGFloat {
        return (self.x - other.x) * (self.x - other.x) + (self.y - other.y) * (self.y - other.y)
    }

    public func subtract(_ other: PathPoint) -> PathPoint {
        return PathPoint(x: self.x - other.x, y: self.y - other.y)
    }

    public func add(_ other: PathPoint) -> PathPoint {
        return PathPoint(x: self.x + other.x, y: self.y + other.y)
    }

    public func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }

    public func normalize() -> PathPoint {
        let len = length()
        return PathPoint(x: x / len, y: y / len)
    }

    public func scale(_ factor: CGFloat) -> PathPoint {
        return PathPoint(x: x * factor, y: y * factor)
    }
}

public struct UMLRelationshipEndPoint: Codable {
    /// Indicates the side, from which the endpoint is attached to the UML element
    public var direction: Direction?
    /// The id of the UML element that the endpoint is attached to
    public var element: String?
    /// The multiplicity of the relationship
    public var multiplicity: String?
    /// The role of the relationship
    public var role: String?

    public init(direction: Direction? = nil, element: String? = nil, multiplicity: String? = nil, role: String? = nil) {
        self.direction = direction ?? .up
        self.element = element ?? ""
        self.multiplicity = multiplicity
        self.role = role
    }
}


// swiftlint:enable identifier_name
// swiftlint:enable discouraged_optional_boolean

/// Hashable (Equatable) extension
extension UMLRelationship: Hashable {
    public static func == (lhs: UMLRelationship, rhs: UMLRelationship) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.owner == rhs.owner &&
        lhs.bounds == rhs.bounds &&
        lhs.assessmentNote == rhs.assessmentNote &&
        lhs.path == rhs.path &&
        lhs.source == rhs.source &&
        lhs.target == rhs.target &&
        lhs.isManuallyLayouted == rhs.isManuallyLayouted &&
        lhs.messages == rhs.messages
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(owner)
        hasher.combine(bounds)
        hasher.combine(assessmentNote)
        hasher.combine(path)
        hasher.combine(source)
        hasher.combine(target)
        hasher.combine(isManuallyLayouted)
        hasher.combine(messages)
    }
}

/// Hashable (Equatable) extension
extension PathPoint: Hashable {
    public static func == (lhs: PathPoint, rhs: PathPoint) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

/// Hashable (Equatable) extension
extension UMLRelationshipEndPoint: Hashable {
    public static func == (lhs: UMLRelationshipEndPoint, rhs: UMLRelationshipEndPoint) -> Bool {
        return lhs.direction == rhs.direction &&
        lhs.element == rhs.element &&
        lhs.multiplicity == rhs.multiplicity &&
        lhs.role == rhs.role
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(direction)
        hasher.combine(element)
        hasher.combine(multiplicity)
        hasher.combine(role)
    }
}
