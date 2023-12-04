import SwiftUI
import ApollonShared
import SharedModels

public struct ApollonFeedback: View {
    @ObservedObject var viewModel: ApollonFeedbackViewModel

    public init(umlModel: UMLModel, diagramType: ApollonShared.UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool, result: Result) {
        self._viewModel = ObservedObject(wrappedValue: ApollonFeedbackViewModel(umlModel: umlModel,
                                                                                diagramType: diagramType,
                                                                                fontSize: fontSize,
                                                                                diagramOffset: diagramOffset,
                                                                                isGridBackground: isGridBackground,
                                                                                result: result))
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererFeedback(viewModel: viewModel)
                if viewModel.isGridBackground {
                    ResetZoomAndPositionButton(viewModel: viewModel)
                }
                FeedbackViewPopOver(viewModel: viewModel, showFeedback: $viewModel.showFeedback)
            }
            .onAppear() {
                if let feedbacks = viewModel.result.feedbacks {
                    viewModel.setupHighlights(basedOn: feedbacks)
                }
                if viewModel.isGridBackground {
                    viewModel.setupScale(geometrySize: geometry.size)
                }
            }
        }
    }
}
