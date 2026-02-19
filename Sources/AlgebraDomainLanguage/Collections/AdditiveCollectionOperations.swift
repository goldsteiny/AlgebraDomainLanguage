// MARK: - Internal iterator helper

extension Sequence {
    /// Splits off the first element and wraps the remainder in an `IteratorSequence`.
    /// `@usableFromInline` so that `@inlinable` callers can use it without breaking inlinability.
    @usableFromInline
    func _splitFirst() -> (head: Element, tail: IteratorSequence<Iterator>)? {
        var iter = makeIterator()
        guard let head = iter.next() else { return nil }
        return (head, IteratorSequence(iter))
    }
}

// MARK: - Sequence.sumResult
//
// Two constraint tiers. Bodies are identical; dispatch differs:
//   AdditiveSemigroup         → sum(first:rest:) resolved as default extension (fold via +)
//   AdditiveSemigroupSummable → sum(first:rest:) resolved through AdditivelySummable formal
//                               requirement (custom witness). Swift prefers the more specific tier.

public extension Sequence where Element: AdditiveSemigroup {
    @inlinable
    var sumResult: Result<Element, EmptyCollectionError> {
        guard let (first, rest) = _splitFirst() else { return .failure(EmptyCollectionError()) }
        return .success(Element.sum(first: first, rest: rest))
    }
}

public extension Sequence where Element: AdditiveSemigroupSummable {
    @inlinable
    var sumResult: Result<Element, EmptyCollectionError> {
        guard let (first, rest) = _splitFirst() else { return .failure(EmptyCollectionError()) }
        return .success(Element.sum(first: first, rest: rest))
    }
}

// MARK: - Sequence.sum
//
// AdditiveMonoid only: requires Zero to handle the empty case.
// Dispatches through AdditivelySummable formal requirement (AdditiveMonoid refines it).

public extension Sequence where Element: AdditiveMonoid {
    @inlinable
    var sum: Element {
        guard let (first, rest) = _splitFirst() else { return .zero }
        return Element.sum(first: first, rest: rest)
    }
}

// MARK: - NonEmpty.sum
//
// Same two-tier pattern. `tail` is an ArraySlice of the already-stored buffer — zero allocation.

public extension NonEmpty where Element: AdditiveSemigroup {
    @inlinable
    var sum: Element { Element.sum(first: head, rest: tail) }
}

public extension NonEmpty where Element: AdditiveSemigroupSummable {
    @inlinable
    var sum: Element { Element.sum(first: head, rest: tail) }
}

// MARK: - NonEmpty.mapAndSum
//
// `tail.lazy.map(transform)` produces a LazyMapSequence over the already-stored ArraySlice —
// zero allocation. Transform values are created one-at-a-time inside sum's reduce.
// Both overloads have the same body; the constraint determines which sum(first:rest:) is called.

public extension NonEmpty {
    @inlinable
    func mapAndSum<T: AdditiveSemigroup>(_ transform: (Element) -> T) -> T {
        T.sum(first: transform(head), rest: tail.lazy.map(transform))
    }

    @inlinable
    func mapAndSum<T: AdditiveSemigroupSummable>(_ transform: (Element) -> T) -> T {
        T.sum(first: transform(head), rest: tail.lazy.map(transform))
    }
}

// MARK: - Sequence.mapAndSumResult / mapAndSum
//
// Iterator + lazy.map: transform is applied lazily as sum iterates — no intermediate arrays.
// Two tiers for mapAndSumResult (semigroup vs summable dispatch); one tier for mapAndSum
// (AdditiveMonoid is always AdditiveSemigroupSummable, so witness dispatch is guaranteed).

public extension Sequence {
    @inlinable
    func mapAndSumResult<T: AdditiveSemigroup>(_ transform: (Element) -> T) -> Result<T, EmptyCollectionError> {
        lazy.map(transform).sumResult
    }

    @inlinable
    func mapAndSumResult<T: AdditiveSemigroupSummable>(_ transform: (Element) -> T) -> Result<T, EmptyCollectionError> {
        lazy.map(transform).sumResult
    }

    @inlinable
    func mapAndSum<T: AdditiveMonoid>(_ transform: (Element) -> T) -> T {
        lazy.map(transform).sum
    }
}
