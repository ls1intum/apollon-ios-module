import Foundation

/// The model that contains the elements and relationships
public struct UMLModel: Codable {
    public var version: String?
    public var type: UMLDiagramType?
    public var size: Size?
    public var interactive: Interactive?
    public var elements: [String : UMLElement]?
    public var relationships: [String : UMLRelationship]?
    public var assessments: [String : String]? // Implement correct type
    
    public init(version: String? = nil, type: UMLDiagramType? = nil, size: Size? = nil, interactive: Interactive? = nil, elements: [String : UMLElement]? = nil, relationships: [String : UMLRelationship]? = nil, assessments: [String : String]? = nil) {
        self.version = version ?? "3.0.0"
        self.type = type ?? .classDiagram
        self.size = size ?? Size(width: 750, height: 750)
        self.interactive = interactive ?? Interactive()
        self.elements = elements ?? [:]
        self.relationships = relationships ?? [:]
        self.assessments = assessments ?? [:]
    }
}

/// The size of the UML model
public struct Size: Codable {
    public var width: CGFloat
    public var height: CGFloat
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
    
    public var asCGSize: CGSize {
        CGSize(width: width, height: height)
    }
}

public struct Interactive: Codable {
    public var elements: [String: UMLElement]?
    public var relationships: [String: UMLRelationship]?
    
    public init(elements: [String : UMLElement]? = nil, relationships: [String : UMLRelationship]? = nil) {
        self.elements = elements ?? [:]
        self.relationships = relationships ?? [:]
    }
}

/// Hashable (Equatable) extension
extension UMLModel: Hashable {
    public static func == (lhs: UMLModel, rhs: UMLModel) -> Bool {
        return lhs.version == rhs.version &&
        lhs.type == rhs.type &&
        lhs.size == rhs.size &&
        lhs.interactive == rhs.interactive &&
        lhs.elements == rhs.elements &&
        lhs.relationships == rhs.relationships &&
        lhs.assessments == rhs.assessments
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(version)
        hasher.combine(type)
        hasher.combine(size)
        hasher.combine(interactive)
        hasher.combine(elements)
        hasher.combine(relationships)
        hasher.combine(assessments)
    }
}

/// Hashable (Equatable) extension
extension Size: Hashable {
    public static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.width == rhs.width &&
        lhs.height == rhs.height
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

/// Hashable (Equatable) extension
extension Interactive: Hashable {
    public static func == (lhs: Interactive, rhs: Interactive) -> Bool {
        return lhs.elements == rhs.elements && 
        lhs.relationships == rhs.relationships
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
        hasher.combine(relationships)
    }
}
