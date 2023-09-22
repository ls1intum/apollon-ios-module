import Foundation
import SwiftUI

/// Contains all information of a specific UML relationship
public struct UMLRelationship: Codable, SelectableUMLItem {
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
}

public struct PathPoint: Codable {
    // swiftlint:disable identifier_name
    public var x: Double
    public var y: Double
    
    public var asCGPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

public struct UMLRelationshipEndPoint: Codable {
    /// The id of the UML element that the endpoint is attached to
    public var element: String?
    /// Indicates the side, from which the endpoint is attached to the UML element
    public var direction: Direction?
    /// The multiplicity of the relationship
    public var multiplicity: String?
    /// The role of the relationship
    public var role: String?
}

public enum Direction: String, Codable {
    case left = "Left"
    case right = "Right"
    case up = "Up"
    case down = "Down"
    case upRight = "Upright"
    case upLeft = "Upleft"
    case downRight = "Downright"
    case downLeft = "Downleft"
    case topRight = "Topright"
    case topLeft = "Topleft"
    case bottomRight = "Bottomright"
    case bottomLeft = "Bottomleft"
    
    public var inverted: Self {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .down:
            return .up
        case .up:
            return .down
        case .upRight:
            return .upLeft
        case .upLeft:
            return .upRight
        case .downRight:
            return .downLeft
        case .downLeft:
            return .downRight
        case .topRight:
            return .bottomRight
        case .topLeft:
            return .bottomLeft
        case .bottomRight:
            return .topRight
        case .bottomLeft:
            return .topLeft
        }
    }
}
// swiftlint:enable identifier_name
// swiftlint:enable discouraged_optional_boolean
