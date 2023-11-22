import Foundation

/// The Diagram includes all the information of a UML Diagram
public struct Diagram: Codable {
    public var id: String?
    public var title: String?
    public var lastUpdate: String?
    public var diagramType: UMLDiagramType?
    public var model: UMLModel?

    init(id: String? = nil, title: String? = nil, lastUpdate: String? = nil, diagramType: UMLDiagramType? = nil, model: UMLModel? = nil) {
        self.id = id ?? UUID().uuidString
        self.title = title ?? ""
        self.lastUpdate = lastUpdate ?? Date().description
        self.diagramType = diagramType
        self.model = model ?? UMLModel()
    }
}
