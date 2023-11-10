import SwiftUI
import ApollonShared

public struct ApollonEdit: View {
    @StateObject var viewModel = ApollonEditViewModel()
    @State private var isShowingAddElementMenu: Bool = false
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
        GeometryReader { geometry in
            NavigationStack {
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
                }.onAppear() {
                    viewModel.setup(umlModel: self.umlModel, diagramType: self.diagramType, fontSize: self.fontSize, diagramOffset: self.diagramOffset, isGridBackground: self.isGridBackground)
                    viewModel.setupScale(geometrySize: geometry.size)
                }.onChange(of: fontSize) {
                    viewModel.fontSize = fontSize
                }
            }
        }
    }
}
