import SwiftUI
import ApollonShared

public struct ApollonEdit: View {
    @StateObject var viewModel: ApollonEditViewModel
    @State private var isShowingAddElementMenu: Bool = false
    @Binding private var bindingUMLModel: UMLModel
    
    public init(umlModel: Binding<UMLModel>, diagramType: UMLDiagramType, fontSize: CGFloat, themeColor: Color, diagramOffset: CGPoint, isGridBackground: Bool) {
        self._bindingUMLModel = umlModel
        self._viewModel = StateObject(wrappedValue: ApollonEditViewModel(umlModel: umlModel.wrappedValue,
                                                                         diagramType: diagramType,
                                                                         fontSize: fontSize,
                                                                         themeColor: themeColor,
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
                        .accessibilityIdentifier("AddElementButton")
                        .padding(5)
                        .popover(isPresented: $isShowingAddElementMenu) {
                            ZStack {
                                viewModel.themeColor
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
