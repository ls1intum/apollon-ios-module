import SwiftUI
import ApollonModels
import SwiftyBeaver

public struct ApollonEditor: View {
    @StateObject var diagramViewModel = DiagramViewModel()

    var readOnly: Bool
    var fontSize: CGFloat
    var model: UMLModel

    public init(readOnly: Bool, fontSize: CGFloat, model: UMLModel) {
        self.readOnly = readOnly
        self.fontSize = fontSize
        self.model = model
    }

    public var body: some View {
        ZStack {
            UMLModelRenderer(diagramViewModel: diagramViewModel)
        }.onAppear() {
            diagramViewModel.setup(readOnly: self.readOnly, fontSize: self.fontSize, umlModel: self.model)
        }
    }
}
