import Foundation

/// The Diagram includes all the information of a UML Diagram
public struct Diagram: Codable {
    public var id: String?
    public var title: String?
    public var lastUpdate: String?
    public var diagramType: UMLDiagramType?
    public var model: UMLModel?
}
