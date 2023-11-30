import SwiftUI
import ApollonShared

public struct ApollonView: View {
    @ObservedObject var viewModel: ApollonViewViewModel

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self._viewModel = ObservedObject(wrappedValue: ApollonViewViewModel(umlModel: umlModel,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererView(viewModel: viewModel)
                if viewModel.isGridBackground {
                    ResetZoomAndPositionButton(viewModel: viewModel)
                }
            }
            .onAppear() {
                if viewModel.isGridBackground {
                    viewModel.setupScale(geometrySize: geometry.size)
                }
            }
        }
    }
}
