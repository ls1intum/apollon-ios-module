import Foundation

/// The Boundary of elements and relationships
public struct Boundary: Codable {
    // swiftlint:disable identifier_name
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    // swiftlint:enable identifier_name
}
