import SwiftUI
import ApollonShared

public struct ApollonView: View {
    @StateObject var viewModel = ApollonViewViewModel()
    var umlModel: UMLModel
    var diagramType: UMLDiagramType
    var fontSize: CGFloat
    var diagramOffset: CGPoint
    var isGridBackground: Bool

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self.umlModel = umlModel
        self.diagramType = diagramType
        self.fontSize = fontSize
        self.diagramOffset = diagramOffset
        self.isGridBackground = isGridBackground
    }

    public var body: some View {
        ZStack {
            UMLRendererView(viewModel: viewModel)
        }.onAppear() {
            viewModel.setup(umlModel: self.umlModel, diagramType: self.diagramType, fontSize: self.fontSize, diagramOffset: self.diagramOffset, isGridBackground: self.isGridBackground)
        }.onChange(of: fontSize) {
            viewModel.fontSize = fontSize
        }
    }
}
