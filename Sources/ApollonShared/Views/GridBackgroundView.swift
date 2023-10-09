import SwiftUI

public struct GridBackgroundView: View {
    
    public init() {}
    
    public var body: some View {
        Image("UMLGridBackground", bundle: .module)
            .resizable(resizingMode: .tile)
    }
}
