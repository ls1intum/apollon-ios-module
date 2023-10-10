import Foundation
import ApollonShared

protocol ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement]
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
        case .useCaseActor:
            return UseCaseActorCreator()
        case .useCase:
            return UseCaseCreator()
        case .useCaseSystem:
            return UseCaseSystemCreator()
        default:
            return nil
        }
    }
}

struct ClassCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 120))
        let elementAttribute = UMLElement(name: "+ attribute: Type", type: .classAttribute, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 40, width: 200, height: 40))
        let elementMethod = UMLElement(name: "+ method()", type: .classMethod, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 80, width: 200, height: 40))
        return [element, elementAttribute, elementMethod]
    }
}

struct AbstractClassOrInterfaceCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 130))
        let elementAttribute = UMLElement(name: "+ attribute: Type", type: .classAttribute, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 50, width: 200, height: 40))
        let elementMethod = UMLElement(name: "+ method()", type: .classMethod, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 90, width: 200, height: 40))
        return [element, elementAttribute, elementMethod]
    }
}

struct EnumerationCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        let elementID = UUID().uuidString
        let element = UMLElement(id: elementID, type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 170))
        let elementAttribute1 = UMLElement(name: "Case 1", type: .classAttribute, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 50, width: 200, height: 40))
        let elementAttribute2 = UMLElement(name: "Case 2", type: .classAttribute, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 90, width: 200, height: 40))
        let elementAttribute3 = UMLElement(name: "Case 3", type: .classAttribute, owner: elementID, bounds: Boundary(x: middle.x, y: middle.y + 130, width: 200, height: 40))
        return [element, elementAttribute1, elementAttribute2, elementAttribute3]
    }
}

struct PackageCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        return [UMLElement(type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 100))]
    }
}

struct UseCaseActorCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "Actor", type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 80, height: 140))]
    }
}

struct UseCaseCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "UseCase", type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 100))]
    }
}

struct UseCaseSystemCreator: ElementCreator {
    func createAllElements(for type: UMLElementType, middle: CGPoint) -> [UMLElement] {
        return [UMLElement(name: "System", type: type, bounds: Boundary(x: middle.x, y: middle.y, width: 200, height: 100))]
    }
}
