import SwiftUI
import ApollonShared

public struct ApollonView: View {
    @StateObject var viewModel: ApollonViewViewModel

    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self._viewModel = StateObject(wrappedValue: ApollonViewViewModel(umlModel: umlModel,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
    }

    public var body: some View {
        ZStack {
            UMLRendererView(viewModel: viewModel)
        }
    }
}
