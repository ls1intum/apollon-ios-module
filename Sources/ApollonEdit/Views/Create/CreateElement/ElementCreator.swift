import Foundation
import ApollonShared

protocol ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement]
}

enum ElementCreatorFactory {
    static func createElementCreator(for type: UMLElementType) -> ElementCreator? {
        switch type {
        case .Class:
            return ClassCreator()
        case .abstractClass, .interface:
            return AbstractClassOrInterfaceCreator()
        case .enumeration:
            return EnumerationCreator()
        case .package:
            return PackageCreator()
        case .objectName:
            return ObjectCreator()
        case .activity:
            return ActivityCreator()
        case .activityInitialNode, .activityFinalNode:
            return ActivityInitialOrFinalNodeCreator()
        case .activityActionNode:
            return ActivityActionNodeCreator()
        case .activityObjectNode:
            return ActivityObjectNodeCreator()
        case .activityMergeNode:
            return ActivityMergeNodeCreator()
        case .activityForkNode:
            return ActivityForkNodeCreator()
        case .activityForkNodeHorizontal:
            return ActivityForkNodeHorizontalCreator()
        case .useCaseActor:
            return UseCaseActorCreator()
        case .useCase:
            return UseCaseCreator()
        case .useCaseSystem:
            return UseCaseSystemCreator()
        case .component, .componentSubsystem:
            return ComponentOrSubsystemCreator()
        case .componentInterface:
            return ComponentInterfaceCreator()
        default:
            return nil
        }
    }
}

struct ClassCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString.lowercased()
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 120))
        let elementAttribute = UMLElement(name: "+ attribute: Type", type: .classAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 40, width: 200, height: 40))
        let elementMethod = UMLElement(name: "+ method()", type: .classMethod, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 80, width: 200, height: 40))
        element.addChild(elementAttribute)
        element.addChild(elementMethod)
        return [element, elementAttribute, elementMethod]
    }
}

struct AbstractClassOrInterfaceCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString.lowercased()
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 130))
        let elementAttribute = UMLElement(name: "+ attribute: Type", type: .classAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 50, width: 200, height: 40))
        let elementMethod = UMLElement(name: "+ method()", type: .classMethod, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 90, width: 200, height: 40))
        element.addChild(elementAttribute)
        element.addChild(elementMethod)
        return [element, elementAttribute, elementMethod]
    }
}

struct EnumerationCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString.lowercased()
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 170))
        let elementAttribute1 = UMLElement(name: "Case 1", type: .classAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 50, width: 200, height: 40))
        let elementAttribute2 = UMLElement(name: "Case 2", type: .classAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 90, width: 200, height: 40))
        let elementAttribute3 = UMLElement(name: "Case 3", type: .classAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 130, width: 200, height: 40))
        element.addChild(elementAttribute1)
        element.addChild(elementAttribute2)
        element.addChild(elementAttribute3)
        return [element, elementAttribute1, elementAttribute2, elementAttribute3]
    }
}

struct ObjectCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString.lowercased()
        let element = UMLElement(id: elementID, name: "Object", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 70))
        let elementAttribute = UMLElement(name: "attribute = value", type: .objectAttribute, owner: elementID, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y + 40, width: 200, height: 30))
        element.addChild(elementAttribute)
        return [element, elementAttribute]
    }
}

struct PackageCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ActivityCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement( type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ActivityInitialOrFinalNodeCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 45, height: 45))]
    }
}

struct ActivityActionNodeCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Action", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ActivityObjectNodeCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Object", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ActivityMergeNodeCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Condition", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ActivityForkNodeCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 20, height: 60))]
    }
}

struct ActivityForkNodeHorizontalCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 60, height: 20))]
    }
}

struct UseCaseActorCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Actor", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 80, height: 140))]
    }
}

struct UseCaseCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "UseCase", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct UseCaseSystemCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "System", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ComponentOrSubsystemCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 200, height: 100))]
    }
}

struct ComponentInterfaceCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, pointToAdd: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Interface", type: type, bounds: Boundary(x: pointToAdd.x, y: pointToAdd.y, width: 20, height: 20))]
    }
}
