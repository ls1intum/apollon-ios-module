import Foundation

/// The model that contains the elements and relationships
public struct UMLModel: Codable {
    public var version: String?
    public var type: UMLDiagramType?
    public var size: Size?
    public var elements: [String : UMLElement]?
    public var relationships: [String : UMLRelationship]?
}

/// The size of the UML model
public struct Size: Codable {
    public var width: CGFloat
    public var height: CGFloat
    public var asCGSize: CGSize {
        CGSize(width: width, height: height)
    }
}
