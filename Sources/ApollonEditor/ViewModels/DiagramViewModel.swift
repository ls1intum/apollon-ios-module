import Foundation
import SwiftUI
import ApollonModels

<<<<<<< Updated upstream:Sources/ApollonEditor/ViewModels/DiagramViewModel.swift
class DiagramViewModel: ObservableObject {
    @Published var readOnly: Bool = true
    @Published var fontSize: CGFloat = 14.0
    @Published var umlModel: UMLModel?
    //@Published var selectedElement: SelectableUMLItem?
    private var diagramTypeUnsupported = false
    
    @MainActor
    func setup(readOnly: Bool, fontSize: CGFloat, umlModel: UMLModel) {
        self.readOnly = readOnly
        self.fontSize = fontSize
        self.umlModel = umlModel
=======
open class ApollonViewModel: ObservableObject {
    @Published public var umlModel: UMLModel?
    @Published public var diagramType: UMLDiagramType?
    @Published public var fontSize: CGFloat
    @Published public var diagramOffset: CGPoint
    @Published public var selectedElement: SelectableUMLItem?
    public var diagramTypeUnsupported = false
    
    public init(umlModel: UMLModel? = nil, diagramType: UMLDiagramType? = nil, fontSize: CGFloat? = nil, diagramOffset: CGPoint? = nil) {
        self.umlModel = umlModel
        self.diagramType = diagramType ?? umlModel?.type
        self.fontSize = fontSize ?? 14.0
        self.diagramOffset = diagramOffset ?? CGPoint(x: 0, y: 0)
    }
    
    @MainActor
    public func setup(umlModel: UMLModel, diagramType: UMLDiagramType?, fontSize: CGFloat?, diagramOffset: CGPoint?) {
        self.umlModel = umlModel
        self.diagramType = diagramType ?? umlModel.type
        self.fontSize = fontSize ?? 14.0
        self.diagramOffset = diagramOffset ?? CGPoint(x: 0, y: 0)
>>>>>>> Stashed changes:Sources/ApollonCommon/ViewModels/ApollonViewModel.swift
        determineChildren()
    }
    
    @MainActor
    func render(_ context: inout GraphicsContext, size: CGSize) {
        guard let model = self.umlModel,
              let modelType = model.type,
              !diagramTypeUnsupported else {
            return
        }
<<<<<<< Updated upstream:Sources/ApollonEditor/ViewModels/DiagramViewModel.swift
        let umlContext = UMLGraphicsContext(context, xOffset: 0, yOffset: 0)
=======
        
        let umlContext = UMLGraphicsContext(context, offset: diagramOffset)
>>>>>>> Stashed changes:Sources/ApollonCommon/ViewModels/ApollonViewModel.swift
        let canvasBounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UMLDiagramRendererFactory.renderer(for: modelType,
                                                          context: umlContext,
                                                          canvasBounds: canvasBounds,
                                                          fontSize: fontSize)
        if let renderer {
            renderer.render(umlModel: model)
        } else {
            log.error("Attempted to draw an unknown diagram type")
            diagramTypeUnsupported = true
        }
    }
    
    private func determineChildren() {
        guard let elements = umlModel?.elements else {
            log.warning("Could not find elements in the model")
            return
        }
        var potentialChildren = elements.filter({ $0.owner != nil })
        
        for (elementIndex, element) in elements.enumerated().reversed() {
            for (index, potentialChild) in potentialChildren.enumerated().reversed() where potentialChild.owner == element.id {
                elements[elementIndex].addChild(potentialChild)
                potentialChildren.remove(at: index)
            }
        }
        umlModel?.elements = elements
    }
    
    public func loadGridBackgroundImage() -> Image {
        return Image("UMLGridBackground", bundle: .module)
    }
}
