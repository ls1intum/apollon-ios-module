import SwiftUI
import ApollonShared

public struct ApollonView<Content: View>: View {
    @StateObject var viewModel: ApollonViewViewModel
    @ViewBuilder var extraContent: Content

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool, @ViewBuilder content: () -> Content) {
        self._viewModel = StateObject(wrappedValue: ApollonViewViewModel(umlModel: umlModel,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
        self.extraContent = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererView(viewModel: viewModel) {
                    self.extraContent
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
