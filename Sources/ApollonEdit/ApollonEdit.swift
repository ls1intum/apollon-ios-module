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
                ZStack(alignment: .topTrailing) {
                    UMLRendererEdit(viewModel: viewModel)
                    VStack(alignment: .trailing) {
                        HStack {
                            ResetZoomAndPositionButton(viewModel: viewModel)
                            Spacer()
                            AddElementButton(viewModel: viewModel, isAddElementMenuVisible: $isShowingAddElementMenu)
                        }.padding([.leading, .top, .trailing], 10)
                        if isShowingAddElementMenu {
                            ElementAddView(viewModel: viewModel)
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
