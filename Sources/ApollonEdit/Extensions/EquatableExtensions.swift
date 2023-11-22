import Foundation
import ApollonShared

extension UMLModel: Equatable {
    public static func == (lhs: UMLModel, rhs: UMLModel) -> Bool {
        return lhs.version == rhs.version &&
        lhs.type == rhs.type &&
        lhs.size == rhs.size &&
        lhs.elements == rhs.elements &&
        lhs.relationships == rhs.relationships
    }
}

extension Size: Equatable {
    public static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
}

extension UMLElement: Equatable {
    public static func == (lhs: UMLElement, rhs: UMLElement) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.owner == rhs.owner &&
        lhs.bounds == rhs.bounds &&
        lhs.direction == rhs.direction &&
        lhs.assessmentNote == rhs.assessmentNote &&
        lhs.children == rhs.children
    }
}

extension UMLRelationship: Equatable {
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
}

extension Boundary: Equatable {
    public static func == (lhs: Boundary, rhs: Boundary) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
}

extension PathPoint: Equatable {
    public static func == (lhs: PathPoint, rhs: PathPoint) -> Bool {
        return lhs.x == rhs.x &&
        lhs.y == rhs.y
    }
}

extension UMLRelationshipEndPoint: Equatable {
    public static func == (lhs: UMLRelationshipEndPoint, rhs: UMLRelationshipEndPoint) -> Bool {
        return lhs.direction == rhs.direction &&
        lhs.element == rhs.element &&
        lhs.multiplicity == rhs.multiplicity &&
        lhs.role == rhs.role
    }
}

