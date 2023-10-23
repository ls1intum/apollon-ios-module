import Foundation

open class GridBackgroundViewModel: ObservableObject {
    @Published public var gridSize: CGSize = .zero
    
    public init() {}
}
