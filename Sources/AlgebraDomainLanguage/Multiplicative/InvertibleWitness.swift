/// Proof that a specific element is multiplicatively invertible (a "unit" in algebra).
public protocol MultiplicativeInvertible: Sendable {
    associatedtype Element: MultiplicativeSemigroup
    var value: Element { get }
    var reciprocal: Element { get }
}

/// Corrects earlier typo in the protocol name.
public typealias MultiplicativeInvertiable = MultiplicativeInvertible

/// Concrete witness carrying an element and its precomputed reciprocal.
public struct Unit<Element: MultiplicativeSemigroup>: MultiplicativeInvertible, Sendable {
    public let value: Element
    public let reciprocal: Element

    @inlinable
    public init(unchecked value: Element, reciprocal: Element) {
        self.value = value
        self.reciprocal = reciprocal
    }
}

public extension Unit where Element: MultiplicativeMonoidWithUnits {
    @inlinable
    init?(_ value: Element) {
        guard let unit = value.unit else { return nil }
        self = unit
    }
}

extension Unit: Equatable where Element: Equatable {}
extension Unit: Hashable where Element: Hashable {}

public func / <Element: MultiplicativeSemigroup, Inverse: MultiplicativeInvertible>(lhs: Element, rhs: Inverse) -> Element where Inverse.Element == Element {
    lhs * rhs.reciprocal
}
