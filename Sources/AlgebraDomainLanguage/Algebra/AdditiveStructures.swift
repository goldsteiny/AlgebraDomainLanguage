// MARK: - Primitives

public protocol AdditiveSemigroup: Sendable {
    static func + (lhs: Self, rhs: Self) -> Self
}

/// Supports a custom n-ary sum that may be more efficient or semantically richer than
/// repeated binary `+`. The requirement is expressed as `first + rest` (lazy-sequence form)
/// so callers never need to materialise an intermediate array to invoke it.
public protocol AdditivelySummable: Sendable {
    static func sum<S: Sequence>(first: Self, rest: S) -> Self where S.Element == Self
}

// MARK: - AdditiveSemigroup defaults

public extension AdditiveSemigroup {
    /// Default: fold via binary `+`. Types with a cheaper or semantically distinct
    /// multi-element sum should conform to `AdditivelySummable` and override there.
    @inlinable
    static func sum<S: Sequence>(first: Self, rest: S) -> Self where S.Element == Self {
        rest.reduce(first, +)
    }

    /// Convenience: fold via `+`. Available on any type that provides only `+`.
    @inlinable
    static func sum(_ values: NonEmpty<Self>) -> Self {
        sum(first: values.head, rest: values.tail)
    }

    /// Convenience vararg form. The vararg array is unavoidable here.
    @inlinable
    static func sum(_ first: Self, _ second: Self, _ rest: Self...) -> Self {
        return sum(first: first + second, rest: rest)
    }
}

// MARK: - AdditivelySummable defaults

public extension AdditivelySummable {
    /// Convenience: delegates to the formal requirement. `tail` is already a stored slice — no allocation.
    @inlinable
    static func sum(_ values: NonEmpty<Self>) -> Self {
        sum(first: values.head, rest: values.tail)
    }

    /// Derives `+` from the custom sum witness via `CollectionOfOne` — zero heap allocation.
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        sum(first: lhs, rest: CollectionOfOne(rhs))
    }
}

// MARK: - Algebraic tower

/// Pairs binary `+` with n-ary `sum` so conforming types provide both.
public protocol AdditiveSemigroupSummable: AdditiveSemigroup, AdditivelySummable {}

/// Disambiguates `sum(NonEmpty)` for types satisfying both `AdditiveSemigroup` and
/// `AdditivelySummable`. Swift prefers the extension on the most refined protocol, so this
/// wins over both parent extensions and correctly routes through the `AdditivelySummable`
/// formal requirement (custom witness dispatch).
public extension AdditiveSemigroupSummable {
    @inlinable
    static func sum(_ values: NonEmpty<Self>) -> Self {
        sum(first: values.head, rest: values.tail)
    }
}

public protocol AdditiveMonoid: AdditiveSemigroupSummable, Zero {}

public protocol AdditiveCommutativeMonoid: AdditiveMonoid {}

public protocol AdditiveGroup: AdditiveMonoid {
    prefix static func - (operand: Self) -> Self
}

public extension AdditiveGroup where Self: SignedNumeric {
    @inlinable
    static prefix func - (operand: Self) -> Self {
        var value = operand
        value.negate()
        return value
    }
}

public extension AdditiveGroup {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs + (-rhs)
    }
}

/// Additive group with commutativity (a + b = b + a).
public protocol AdditiveAbelianGroup: AdditiveGroup, AdditiveCommutativeMonoid {}

// MARK: - Pairing protocols

public protocol AdditiveMonoidSummable: AdditiveMonoid, AdditivelySummable {}
public protocol AdditiveCommutativeMonoidSummable: AdditiveCommutativeMonoid, AdditivelySummable {}
public protocol AdditiveGroupSummable: AdditiveGroup, AdditivelySummable {}
public protocol AdditiveAbelianGroupSummable: AdditiveAbelianGroup, AdditivelySummable {}
