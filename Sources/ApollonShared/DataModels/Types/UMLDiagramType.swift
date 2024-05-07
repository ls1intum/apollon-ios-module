import Foundation

/// All the different UML Diagram Types
public enum UMLDiagramType: String, Codable, CaseIterable {
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
    case BPMN = "BPMN"

    /// The different elements of each diagram, that the user can create
    public var diagramElementTypes: [UMLElementType] {
        switch self {
        case .classDiagram:
            return [.Class, .abstractClass, .interface, .enumeration, .package]
        case .objectDiagram:
            return [.objectName]
        case .activityDiagram:
            return [.activity, .activityInitialNode, .activityFinalNode, .activityActionNode, .activityObjectNode, .activityMergeNode, .activityForkNode, .activityForkNodeHorizontal]
        case .useCaseDiagram:
            return [.useCaseActor, .useCase, .useCaseSystem]
        case .communicationDiagram:
            return [.objectName]
        case .componentDiagram:
            return [.component, .componentSubsystem, .componentInterface]
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
        case .BPMN:
            return []
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
        case .BPMN:
            return []
        }
    }
    
    /// Returns true, if the diagram type has no supported renderer yet.
    // Soon: Communication Diagram
    public static func isDiagramTypeUnsupported(diagramType: UMLDiagramType) -> Bool {
        switch diagramType {
        case .classDiagram, .objectDiagram, .useCaseDiagram, .activityDiagram, .componentDiagram:
            return false
        default:
            return true
        }
    }
}
