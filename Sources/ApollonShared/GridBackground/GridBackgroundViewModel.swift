import Foundation

open class GridBackgroundViewModel: ObservableObject {
    @Published public var gridSize: CGSize = .zero
    @Published public var showGridBackgroundBorder: Bool = false
    
    public init() {}
}
