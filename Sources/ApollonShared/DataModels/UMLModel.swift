import Foundation

/// The model that contains the elements and relationships
public struct UMLModel: Codable {
    public var version: String?
    public var type: UMLDiagramType?
    public var size: Size?
    public var elements: [String : UMLElement]?
    public var relationships: [String : UMLRelationship]?

    public init(version: String? = nil, type: UMLDiagramType? = nil, size: Size? = nil, elements: [String : UMLElement]? = nil, relationships: [String : UMLRelationship]? = nil) {
        self.version = version ?? "3.0.0"
        self.type = type ?? .classDiagram
        self.size = size ?? Size(width: 750, height: 1000)
        self.elements = elements ?? [:]
        self.relationships = relationships ?? [:]
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
