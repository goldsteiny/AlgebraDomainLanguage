/// A collection guaranteed to contain at least one element. Enables total fold operations (sum, product).
///
/// Backed by a single contiguous `[Element]` buffer so that:
/// - `array` is a zero-copy O(1) return of the buffer
/// - `tail` is an O(1) zero-copy `ArraySlice` (shares storage)
/// - `map` produces a single allocation (vs. two with separate head/tail storage)
/// - `init?(_ sequence:)` materialises once (vs. materialise + split)
public struct NonEmpty<Element: Sendable>: Sendable {

    @usableFromInline
    let storage: [Element]

    // MARK: - Public accessors

    public var head: Element { storage[0] }
    public var tail: ArraySlice<Element> { storage.dropFirst() }

    // MARK: - Initialisers

    public init(_ head: Element, _ tail: [Element] = []) {
        var s = [Element]()
        s.reserveCapacity(1 + tail.count)
        s.append(head)
        s.append(contentsOf: tail)
        storage = s
    }

    public init?<S: Sequence>(_ elements: S) where S.Element == Element {
        let arr = Array(elements)
        guard !arr.isEmpty else { return nil }
        storage = arr
    }

    /// Internal: caller must guarantee `storage` is non-empty.
    @usableFromInline
    init(unchecked storage: [Element]) {
        self.storage = storage
    }

    // MARK: - Properties

    /// The underlying buffer. Zero-copy O(1).
    public var array: [Element] { storage }

    public var count: Int { storage.count }

    // MARK: - Operations

    @inlinable
    public func map<Output: Sendable>(_ transform: (Element) -> Output) -> NonEmpty<Output> {
        // storage.map produces a single [Output]; unchecked init stores it directly.
        NonEmpty<Output>(unchecked: storage.map(transform))
    }

    @inlinable
    public func reduce<Output>(
        _ nextPartialResult: (Output, Element) -> Output,
        initialTransform: (Element) -> Output
    ) -> Output {
        tail.reduce(initialTransform(head), nextPartialResult)
    }
}

public typealias NonEmptyArray<Element: Sendable> = NonEmpty<Element>

extension NonEmpty: RandomAccessCollection {
    public var startIndex: Int { storage.startIndex }
    public var endIndex: Int { storage.endIndex }

    public subscript(position: Int) -> Element { storage[position] }
}

extension NonEmpty: Equatable where Element: Equatable {}
extension NonEmpty: Hashable where Element: Hashable {}
