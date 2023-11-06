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
            return [.Class, .abstractClass, .interface, .enumeration, .package]
        case .objectDiagram:
            return [.objectName]
        case .activityDiagram:
            return [.activityForkNodeHorizontal, .activityForkNode, .activityMergeNode, .activityObjectNode, .activityActionNode, .activityFinalNode, .activityInitialNode, .activity]
        case .useCaseDiagram:
            return [.useCaseActor, .useCase, .useCaseSystem]
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
    
    /// The different relationships of each diagram, that the user can create.
    /// The first element of the returned array is the initial relationship type that is used, when a new relationship is created!
    public var diagramRelationshipTypes: [UMLRelationshipType] {
        switch self {
        case .classDiagram:
            return [.classBidirectional, .classUnidirectional, .classAggregation, .classComposition, .classDependency, .classInheritance, .classRealization]
        case .objectDiagram:
            return [.objectLink]
        case .activityDiagram:
            return [.activityControlFlow]
        case .useCaseDiagram:
            return [.useCaseAssociation, .useCaseGeneralization, .useCaseInclude, .useCaseExtend]
        case .communicationDiagram:
            return [.communicationLink]
        case .componentDiagram:
            return [.componentDependency, .componentInterfaceProvided, .componentInterfaceRequired]
        case .deploymentDiagram:
            return [.deploymentAssociation, .deploymentDependency, .deploymentInterfaceProvided, .deploymentInterfaceRequired]
        case .petriNet:
            return [.petriNetArc]
        case .reachabilityGraph:
            return [.reachabilityGraphArc]
        case .syntaxTree:
            return [.syntaxTreeLink]
        case .flowchart:
            return [.flowchartFlowline]
        }
    }
    
    /// Returns true, if the diagram type has no supported renderer yet.
    public static func isDiagramTypeUnsupported(diagramType: UMLDiagramType) -> Bool {
        switch diagramType {
        case .classDiagram, .objectDiagram, .useCaseDiagram, .communicationDiagram:
            return false
        default:
            return true
        }
    }
}
