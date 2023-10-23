import SwiftUI

public struct GridBackgroundView: View {
    @ObservedObject var gridBackgroundViewModel: GridBackgroundViewModel
    
    public init(gridBackgroundViewModel: GridBackgroundViewModel) {
        self.gridBackgroundViewModel = gridBackgroundViewModel
    }
    
    public var body: some View {
        ZStack {
            Image("UMLGridBackground", bundle: .module)
                .resizable(resizingMode: .tile)
                .frame(width: gridBackgroundViewModel.gridSize.width, height: gridBackgroundViewModel.gridSize.height)
            Rectangle()
                .stroke(.blue, lineWidth: 4)
                .frame(width: gridBackgroundViewModel.gridSize.width + 2, height: gridBackgroundViewModel.gridSize.height + 2)
        }.ignoresSafeArea(.all)
    }
}
