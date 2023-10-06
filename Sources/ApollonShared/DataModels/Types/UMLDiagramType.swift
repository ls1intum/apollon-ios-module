import Foundation

/// All the different UML Diagram Types
public enum UMLDiagramType: String, Codable {
    case classDiagram = "ClassDiagram"
    case objectDiagram = "ObjectDiagram"
    case activityDiagram = "ActivityDiagram"
    case useCaseDiagram = "UseCaseDiagram"
    case communicationDiagram = "CommunicationDiagram"
    case componentDiagram = "ComponentDiagram"
    case deploymentDiagram = "DeploymentDiagram"
    case petriNet = "PetriNet"
    case reachabilityGraph = "ReachabilityGraph"
    case syntaxTree = "SyntaxTree"
    case flowchart = "Flowchart"
    
    /// The different elements of each diagram, that the user can create
    public var diagramElementTypes: [UMLElementType] {
        switch self {
        case .classDiagram:
            return [.enumeration, .interface, .abstractClass, .Class, .package]
        case .objectDiagram:
            return [.objectName]
        case .activityDiagram:
            return [.activityForkNodeHorizontal, .activityForkNode, .activityMergeNode, .activityObjectNode, .activityActionNode, .activityFinalNode, .activityInitialNode, .activity]
        case .useCaseDiagram:
            return [.useCaseSystem, .useCaseActor, .useCase]
        case .communicationDiagram:
            return [.objectName]
        case .componentDiagram:
            return [.componentInterface, .component]
        case .deploymentDiagram:
            return [.deploymentInterface, .deploymentArtifact, .deploymentComponent, .deploymentNode]
        case .petriNet:
            return [.petriNetPlace, .petriNetTransition]
        case .reachabilityGraph:
            return [.reachabilityGraphMarking]
        case .syntaxTree:
            return [.syntaxTreeNonterminal, .syntaxTreeTerminal]
        case .flowchart:
            return [.flowchartFunctionCall, .flowchartInputOutput, .flowchartDecision, .flowchartProcess, .flowchartTerminal]
        }
    }
    
    /// Returns true, if the diagram type has no supported renderer yet.
    public static func isDiagramTypeUnsupported(diagramType: UMLDiagramType) -> Bool {
        switch diagramType {
        case .classDiagram, .useCaseDiagram:
            return false
        default:
            return true
        }
    }
}
