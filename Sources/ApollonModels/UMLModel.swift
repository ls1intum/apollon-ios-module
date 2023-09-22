import Foundation

/// The model that contains the elements and relationships
public struct UMLModel: Codable {
    public var version: String?
    public var type: UMLDiagramType?
    public var size: Size?
    public var elements: [UMLElement]?
    public var relationships: [UMLRelationship]?
}

/// The size of the UML model
public struct Size: Codable {
    public var width: CGFloat
    public var height: CGFloat
}
