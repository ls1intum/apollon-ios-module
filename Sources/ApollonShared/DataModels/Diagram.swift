import Foundation

/// The Diagram includes all the information of a UML Diagram
public struct Diagram: Codable {
    public var id: String?
    public var title: String?
    public var lastUpdate: String?
    public var diagramType: UMLDiagramType?
    public var model: UMLModel?

    public init(id: String? = nil, title: String? = nil, lastUpdate: String? = nil, diagramType: UMLDiagramType? = nil, model: UMLModel? = nil) {
        self.id = id ?? UUID().uuidString.lowercased()
        self.title = title ?? ""
        self.lastUpdate = lastUpdate ?? Date().ISO8601FormatWithFractionalSeconds()
        self.diagramType = diagramType
        self.model = model ?? UMLModel()
    }
}

/// Hashable (Equatable) extension
extension Diagram: Hashable {
    public static func == (lhs: Diagram, rhs: Diagram) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.lastUpdate == rhs.lastUpdate &&
        lhs.diagramType == rhs.diagramType &&
        lhs.model == rhs.model
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(lastUpdate)
        hasher.combine(diagramType)
        hasher.combine(model)
    }
}

extension Date {
    func ISO8601FormatWithFractionalSeconds() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: self)
    }
}
