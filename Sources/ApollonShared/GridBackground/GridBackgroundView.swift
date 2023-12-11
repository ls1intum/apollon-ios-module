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
                .frame(width: gridBackgroundViewModel.gridSize?.width ?? nil, height: gridBackgroundViewModel.gridSize?.height ?? nil)
            if gridBackgroundViewModel.showGridBackgroundBorder {
                Rectangle()
                    .stroke(gridBackgroundViewModel.gridBackgroundBorderColor ?? .blue, lineWidth: 4)
                    .frame(width: gridBackgroundViewModel.gridSize?.width, height: gridBackgroundViewModel.gridSize?.height)
            }
        }.ignoresSafeArea(.all)
    }
}
