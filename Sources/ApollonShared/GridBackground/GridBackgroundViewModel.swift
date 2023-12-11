import Foundation
import SwiftUI

open class GridBackgroundViewModel: ObservableObject {
    @Published public var gridSize: CGSize?
    @Published public var showGridBackgroundBorder: Bool
    @Published public var gridBackgroundBorderColor: Color?

    public init(gridSize: CGSize? = nil, showGridBackgroundBorder: Bool = false, gridBackgroundBorderColor: Color? = nil) {
        self.gridSize = gridSize
        self.showGridBackgroundBorder = showGridBackgroundBorder
        self.gridBackgroundBorderColor = gridBackgroundBorderColor
    }
}
