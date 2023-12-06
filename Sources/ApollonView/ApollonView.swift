import SwiftUI
import ApollonShared

public struct ApollonView<Content: View>: View {
    @ObservedObject var viewModel: ApollonViewViewModel
    @ViewBuilder var content: Content

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool, @ViewBuilder content: () -> Content) {
        self._viewModel = ObservedObject(wrappedValue: ApollonViewViewModel(umlModel: umlModel,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererView(viewModel: viewModel) {
                    content
                }
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
