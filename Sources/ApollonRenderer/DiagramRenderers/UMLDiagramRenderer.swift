import SwiftUI
import ApollonShared

protocol UMLDiagramRenderer {
    /// This instance should be used for all actions that one would normally perform with a `GraphicsContext`
    var context: UMLGraphicsContext { get set }
    var canvasBounds: CGRect { get }
    var fontSize: CGFloat { get set }
    
    func render(umlModel: UMLModel)
}

enum UMLDiagramRendererFactory {
    static func renderer(for type: UMLDiagramType, context: UMLGraphicsContext, canvasBounds: CGRect, fontSize: CGFloat) -> UMLDiagramRenderer? {
        switch type {
        case .classDiagram:
            return UMLClassDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        case .objectDiagram:
            return UMLObjectDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        case .activityDiagram:
            return UMLActivityDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        case .useCaseDiagram:
            return UMLUseCaseDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        case .communicationDiagram:
            return UMLCommunicationDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        case .componentDiagram:
            return UMLComponentDiagramRenderer(context: context, canvasBounds: canvasBounds, fontSize: fontSize)
        default:
            return nil
        }
    }
}
