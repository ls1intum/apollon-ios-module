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
    var problemStatementView: AnyView
    
    public init(umlModel: UMLModel, diagramType: UMLDiagramType, fontSize: CGFloat, diagramOffset: CGPoint, isGridBackground: Bool, problemStatementView: AnyView) {
        self.umlModel = umlModel
        self.diagramType = diagramType
        self.fontSize = fontSize
        self.diagramOffset = diagramOffset
        self.isGridBackground = isGridBackground
        self.problemStatementView = problemStatementView
    }
    
    public var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    UMLRendererEdit(viewModel: viewModel)
                    VStack {
                        HStack {
                            Spacer()
                            if isShowingAddElementMenu {
                                ElementAddView(viewModel: viewModel)
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            MagnificationToolbar(viewModel: viewModel)
                        }
                    }
                }.onAppear() {
                    viewModel.setup(umlModel: self.umlModel, diagramType: self.diagramType, fontSize: self.fontSize, diagramOffset: self.diagramOffset, isGridBackground: self.isGridBackground, problemStatementView: problemStatementView)
                    viewModel.setupScale(geometrySize: geometry.size)
                }.onChange(of: fontSize) {
                    viewModel.fontSize = fontSize
                }.toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SubmitButton()
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        HStack(spacing: 1) {
                            ProblemStatementButton(viewModel: viewModel)
                            AddElementButton(viewModel: viewModel, isAddElementMenuVisible: $isShowingAddElementMenu)
                        }
                    }
                }
            }
        }
    }
}
