import Foundation

open class GridBackgroundViewModel: ObservableObject {
    @Published public var gridSize: CGSize?
    @Published public var showGridBackgroundBorder: Bool = false
    
    public init(gridSize: CGSize? = nil) {
        self.gridSize = gridSize
    }
}
