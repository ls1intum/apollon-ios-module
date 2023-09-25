import SwiftUI
import ApollonModels
import ApollonCommon

public struct ApollonView: View {
    @StateObject var viewModel = ApollonViewViewModel()
    var umlModel: UMLModel
    var diagramType: UMLDiagramType
    var fontSize: CGFloat
    var diagramOffset: CGPoint

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint) {
        self.umlModel = umlModel
        self.diagramType = diagramType
        self.fontSize = fontSize
        self.diagramOffset = diagramOffset
    }

    public var body: some View {
        ZStack {
            UMLRendererView(viewModel: viewModel)
        }.onAppear() {
            viewModel.setup(umlModel: self.umlModel, diagramType: self.diagramType, fontSize: self.fontSize, diagramOffset: self.diagramOffset)
        }
    }
}
