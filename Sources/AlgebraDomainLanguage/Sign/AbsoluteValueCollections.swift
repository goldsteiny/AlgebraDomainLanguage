public extension Array where Element: AbsoluteValueDecomposable {
    @inlinable
    var absolutes: [Element] {
        map(\.absolute)
    }
}
