import Foundation
import SwiftUI

open class GridBackgroundViewModel: ObservableObject {
    @Published public var gridSize: CGSize?

    public init(gridSize: CGSize? = nil) {
        self.gridSize = gridSize
    }
}
