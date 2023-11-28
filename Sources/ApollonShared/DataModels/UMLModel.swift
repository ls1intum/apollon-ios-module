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
        self.size = size ?? Size(width: 750, height: 1000)
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
