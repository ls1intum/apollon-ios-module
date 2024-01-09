import Foundation

/// All the different UML Element Types
public enum UMLElementType: String, Codable {
    case colorLegend = "ColorLegend"
    case flowchartTerminal = "FlowchartTerminal"
    case flowchartProcess = "FlowchartProcess"
    case flowchartDecision = "FlowchartDecision"
    case flowchartInputOutput = "FlowchartInputOutput"
    case flowchartFunctionCall = "FlowchartFunctionCall"
    case syntaxTreeTerminal = "SyntaxTreeTerminal"
    case syntaxTreeNonterminal = "SyntaxTreeNonterminal"
    case reachabilityGraphMarking = "ReachabilityGraphMarking"
    case petriNetPlace = "PetriNetPlace"
    case petriNetTransition = "PetriNetTransition"
    case deploymentNode = "DeploymentNode"
    case deploymentComponent = "DeploymentComponent"
    case deploymentArtifact = "DeploymentArtifact"
    case deploymentInterface = "DeploymentInterface"
    case component = "Component"
    case componentSubsystem = "Subsystem"
    case componentInterface = "ComponentInterface"
    case communicationLinkMessage = "CommunicationLinkMessage"
    case useCase = "UseCase"
    case useCaseActor = "UseCaseActor"
    case useCaseSystem = "UseCaseSystem"
    case activity = "Activity"
    case activityActionNode = "ActivityActionNode"
    case activityFinalNode = "ActivityFinalNode"
    case activityForkNode = "ActivityForkNode"
    case activityForkNodeHorizontal = "ActivityForkNodeHorizontal"
    case activityInitialNode = "ActivityInitialNode"
    case activityMergeNode = "ActivityMergeNode"
    case activityObjectNode = "ActivityObjectNode"
    case objectName = "ObjectName"
    case objectAttribute = "ObjectAttribute"
    case objectMethod = "ObjectMethod"
    case package = "Package"
    // swiftlint:disable:next identifier_name
    case Class = "Class"
    case abstractClass = "AbstractClass"
    case interface = "Interface"
    case enumeration = "Enumeration"
    case classAttribute = "ClassAttribute"
    case classMethod = "ClassMethod"
    
    /// The string that should be shown on the UML elements to indicate the type of the element
    public var annotationTitle: String {
        switch self {
        case .interface:
            return "<<interface>>"
        case .enumeration:
            return "<<enumeration>>"
        case .abstractClass:
            return "<<abstract>>"
        case .component:
            return "<<component>>"
        case .componentSubsystem:
            return "<<subsystem>>"
        default:
            return ""
        }
    }

    /// Returns true, if the element is not selectable by itself
    public var isElementNotSelectable: Bool {
        switch self {
        case .classAttribute, .classMethod, .objectAttribute, .objectMethod, .communicationLinkMessage:
            return true
        default:
            return false
        }
    }

    public var isContainer: Bool {
        switch self {
        case .package, .useCaseSystem, .component, .componentSubsystem:
            return true
        default:
            return false
        }
    }

    /// The direction to which the element is resizable
    public var resizeBy: ResizeableDirection {
        switch self {
        case .package, .activityObjectNode, .activityMergeNode, .activityActionNode, .activity, .useCaseSystem, .useCase, .component, .componentSubsystem:
            return .widthAndHeight
        case .enumeration, .interface, .abstractClass, .Class, .objectName, .activityForkNodeHorizontal:
            return .width
        case .activityForkNode:
            return .height
        default:
            return .none
        }
    }
}

public enum ResizeableDirection {
    case widthAndHeight
    case width
    case height
    case none
}
