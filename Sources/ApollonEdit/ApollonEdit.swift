import SwiftUI
import ApollonShared

public struct ApollonEdit: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var isShowingAddElementMenu: Bool = false
    @Binding private var bindingUMLModel: UMLModel
    
    public init(umlModel: Binding<UMLModel>, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool) {
        self._bindingUMLModel = umlModel
        self._viewModel = StateObject(wrappedValue: ApollonEditViewModel(umlModel: umlModel.wrappedValue,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         diagramOffset: diagramOffset,
                                                                         isGridBackground: isGridBackground))
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                UMLRendererEdit(viewModel: viewModel)
                ResetZoomAndPositionButton(viewModel: viewModel)
                VStack {
                    Spacer()
                    AddElementButton(viewModel: viewModel, isAddElementMenuVisible: $isShowingAddElementMenu)
                        .popover(isPresented: $isShowingAddElementMenu) {
                            ZStack {
                                Color.blue
                                    .scaleEffect(1.5)
                                    .opacity(0.5)
                                ElementAddView(viewModel: viewModel)
                                    .presentationCompactAdaptation(.none)
                            }
                        }
                }
            }
            .onAppear() {
                viewModel.setupScale(geometrySize: geometry.size)
            }
            .onChange(of: viewModel.umlModel) {
                bindingUMLModel = viewModel.umlModel
            }
        }
    }
}
