import Foundation

/// All the different UML Relationship Types
public enum UMLRelationshipType: String, Codable {
    case flowchartFlowline = "FlowchartFlowline"
    case syntaxTreeLink = "SyntaxTreeLink"
    case reachabilityGraphArc = "ReachabilityGraphArc"
    case petriNetArc = "PetriNetArc"
    case deploymentAssociation = "DeploymentAssociation"
    case deploymentInterfaceProvided = "DeploymentInterfaceProvided"
    case deploymentInterfaceRequired = "DeploymentInterfaceRequired"
    case deploymentDependency = "DeploymentDependency"
    case componentInterfaceProvided = "ComponentInterfaceProvided"
    case componentInterfaceRequired = "ComponentInterfaceRequired"
    case componentDependency = "ComponentDependency"
    case communicationLink = "CommunicationLink"
    case useCaseAssociation = "UseCaseAssociation"
    case useCaseGeneralization = "UseCaseGeneralization"
    case useCaseInclude = "UseCaseInclude"
    case useCaseExtend = "UseCaseExtend"
    case activityControlFlow = "ActivityControlFlow"
    case objectLink = "ObjectLink"
    case classBidirectional = "ClassBidirectional"
    case classUnidirectional = "ClassUnidirectional"
    case classInheritance = "ClassInheritance"
    case classRealization = "ClassRealization"
    case classDependency = "ClassDependency"
    case classAggregation = "ClassAggregation"
    case classComposition = "ClassComposition"
    
    /// The string that should be shown on the UML relationship to indicate the type of the relationship
    public var annotationTitle: String {
        switch self {
        case .useCaseExtend:
            return "≪extend≫"
        case .useCaseInclude:
            return "≪include≫"
        default:
            return ""
        }
    }
}
