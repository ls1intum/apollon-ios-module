import SwiftUI
import ApollonShared

public struct ApollonView<Content: View>: View {
    @StateObject var viewModel: ApollonViewViewModel
    @ViewBuilder var extraContent: Content
    private var isPreview: Bool

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, themeColor: Color, diagramOffset: CGPoint, isGridBackground: Bool, isPreview: Bool = false, @ViewBuilder content: () -> Content) {
        self._viewModel = StateObject(wrappedValue: ApollonViewViewModel(umlModel: umlModel,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         themeColor: themeColor,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
        self.extraContent = content()
        self.isPreview = isPreview
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererView(viewModel: viewModel, isPreview: isPreview, extraContent: {
                    extraContent
                })
                if viewModel.isGridBackground {
                    ResetZoomAndPositionButton(viewModel: viewModel)
                }
            }
            .onAppear() {
                if viewModel.isGridBackground || self.isPreview {
                    viewModel.setupScale(geometrySize: geometry.size)
                }
            }
        }
    }
}
