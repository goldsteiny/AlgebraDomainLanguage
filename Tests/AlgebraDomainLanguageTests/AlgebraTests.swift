import Testing
@testable import AlgebraDomainLanguage

private struct DoublePair: Equatable, Sendable {
    let first: Double
    let second: Double

    init(_ first: Double, _ second: Double) {
        self.first = first
        self.second = second
    }
}

extension DoublePair: Zero {
    static var zero: DoublePair { DoublePair(0, 0) }
}

extension DoublePair: AdditiveSemigroup {
    static func + (lhs: DoublePair, rhs: DoublePair) -> DoublePair {
        DoublePair(lhs.first + rhs.first, lhs.second + rhs.second)
    }
}

extension DoublePair: AdditiveGroup {
    static prefix func - (operand: DoublePair) -> DoublePair {
        DoublePair(-operand.first, -operand.second)
    }
}

extension DoublePair: LeftModule {
    typealias Scalar = Double

    func leftScaled(by scalar: Double) -> DoublePair {
        DoublePair(first * scalar, second * scalar)
    }
}

extension DoublePair: RightModule {
    func rightScaled(by scalar: Double) -> DoublePair {
        DoublePair(first * scalar, second * scalar)
    }
}

extension DoublePair: Bimodule {}

extension DoublePair: One {
    static var one: DoublePair { DoublePair(1, 1) }
}

private struct WrappedDouble: Equatable, Sendable {
    let raw: Double

    init(_ raw: Double) {
        self.raw = raw
    }
}

extension WrappedDouble: Zero {
    static var zero: WrappedDouble { WrappedDouble(0) }
}

extension WrappedDouble: One {
    static var one: WrappedDouble { WrappedDouble(1) }
}

extension WrappedDouble: AdditiveSemigroup {
    static func + (lhs: WrappedDouble, rhs: WrappedDouble) -> WrappedDouble {
        WrappedDouble(lhs.raw + rhs.raw)
    }
}

extension WrappedDouble: AdditiveGroup {
    static prefix func - (operand: WrappedDouble) -> WrappedDouble {
        WrappedDouble(-operand.raw)
    }
}

extension WrappedDouble: MultiplicativeSemigroup {
    static func * (lhs: WrappedDouble, rhs: WrappedDouble) -> WrappedDouble {
        WrappedDouble(lhs.raw * rhs.raw)
    }
}

extension WrappedDouble: MultiplicativeMonoidWithUnits {
    var unit: Unit<WrappedDouble>? {
        guard !isZero else { return nil }
        return Unit(unchecked: self, reciprocal: WrappedDouble(1 / raw))
    }
}

extension WrappedDouble: Signed {
    var signum: Signum {
        if raw == 0 { return .zero }
        return raw < 0 ? .negative : .positive
    }

    var flippedSign: WrappedDouble {
        WrappedDouble(-raw)
    }
}

extension WrappedDouble: AbsoluteValueDecomposable {
    var absolute: WrappedDouble {
        WrappedDouble(Swift.abs(raw))
    }
}

private struct SumPrimitive: Equatable, Sendable {
    let raw: Int

    init(_ raw: Int) {
        self.raw = raw
    }
}

extension SumPrimitive: Zero {
    static var zero: SumPrimitive { SumPrimitive(0) }
}

extension SumPrimitive: AdditivelySummable {
    static func sum<S: Sequence>(first: SumPrimitive, rest: S) -> SumPrimitive where S.Element == SumPrimitive {
        SumPrimitive(rest.reduce(first.raw) { $0 + $1.raw })
    }
}

extension SumPrimitive: AdditiveMonoid {}

private struct ProductPrimitive: Equatable, Sendable {
    let raw: Int

    init(_ raw: Int) {
        self.raw = raw
    }
}

extension ProductPrimitive: One {
    static var one: ProductPrimitive { ProductPrimitive(1) }
}

extension ProductPrimitive: MultiplicativelyProductable {
    static func product(_ values: NonEmpty<ProductPrimitive>) -> ProductPrimitive {
        ProductPrimitive(values.tail.reduce(values.head.raw) { $0 * $1.raw })
    }
}

extension ProductPrimitive: MultiplicativeMonoid {}

private struct Mod4: Equatable, Hashable, Sendable {
    private let storage: Int

    var raw: Int { storage }

    init(_ raw: Int) {
        let reduced = raw % 4
        self.storage = reduced >= 0 ? reduced : reduced + 4
    }
}

extension Mod4: Zero {
    static var zero: Mod4 { Mod4(0) }
}

extension Mod4: One {
    static var one: Mod4 { Mod4(1) }
}

extension Mod4: AdditiveSemigroup {
    static func + (lhs: Mod4, rhs: Mod4) -> Mod4 {
        Mod4(lhs.raw + rhs.raw)
    }
}

extension Mod4: AdditiveGroup {
    static prefix func - (operand: Mod4) -> Mod4 {
        Mod4(-operand.raw)
    }
}

extension Mod4: AdditiveAbelianGroup {}

extension Mod4: MultiplicativeSemigroup {
    static func * (lhs: Mod4, rhs: Mod4) -> Mod4 {
        Mod4(lhs.raw * rhs.raw)
    }
}

extension Mod4: MultiplicativeMonoidWithUnits {
    var unit: Unit<Mod4>? {
        switch raw {
        case 1:
            return Unit(unchecked: self, reciprocal: Mod4(1))
        case 3:
            return Unit(unchecked: self, reciprocal: Mod4(3))
        default:
            return nil
        }
    }
}

extension Mod4: MultiplicativeCommutativeMonoidWithUnits {}

private struct BiasedSum: Equatable, Sendable {
    let raw: Int

    init(_ raw: Int) {
        self.raw = raw
    }
}

extension BiasedSum: Zero {
    static var zero: BiasedSum { BiasedSum(0) }
}

extension BiasedSum: AdditiveSemigroup {
    static func + (lhs: BiasedSum, rhs: BiasedSum) -> BiasedSum {
        BiasedSum(lhs.raw + rhs.raw)
    }
}

extension BiasedSum: AdditivelySummable {
    static func sum<S: Sequence>(first: BiasedSum, rest: S) -> BiasedSum where S.Element == BiasedSum {
        BiasedSum(rest.reduce(first.raw) { $0 + $1.raw } + 1_000)
    }
}

extension BiasedSum: AdditiveMonoid {}

private struct BiasedProduct: Equatable, Sendable {
    let raw: Int

    init(_ raw: Int) {
        self.raw = raw
    }
}

extension BiasedProduct: One {
    static var one: BiasedProduct { BiasedProduct(1) }
}

extension BiasedProduct: MultiplicativeSemigroup {
    static func * (lhs: BiasedProduct, rhs: BiasedProduct) -> BiasedProduct {
        BiasedProduct(lhs.raw * rhs.raw)
    }
}

extension BiasedProduct: MultiplicativelyProductable {
    static func product(_ values: NonEmpty<BiasedProduct>) -> BiasedProduct {
        BiasedProduct(values.tail.reduce(values.head.raw) { $0 * $1.raw } + 100)
    }
}

extension BiasedProduct: MultiplicativeMonoid {}

private struct WrappedDoubleWitness: MultiplicativeInvertible {
    let value: WrappedDouble
    let reciprocal: WrappedDouble
}

private func requireFloatingPointFieldAlgebra<T: FloatingPointFieldAlgebra>(_ value: T) -> T {
    value
}

private func requireLegacyInvertiable<T: MultiplicativeInvertiable>(_ witness: T) -> T {
    witness
}

private func requireField<T: Field>(_ value: T) -> T {
    value
}

private func requireDivisionRing<T: DivisionRing>(_ value: T) -> T {
    value
}

struct UtilityTypeTests {
    @Test func nonEmptyConstructMapReduce() {
        let values = NonEmpty(1, [2, 3])
        #expect(values.array == [1, 2, 3])
        #expect(values.count == 3)
        #expect(values.map { $0 * 2 }.array == [2, 4, 6])
        #expect(values.reduce(+, initialTransform: { $0 }) == 6)
    }

    @Test func nonZeroForWrappedDouble() {
        #expect(NonZero<WrappedDouble>(.zero) == nil)
        #expect(NonZero<WrappedDouble>(WrappedDouble(2)) != nil)

        let wrappedTwo = NonZero<WrappedDouble>(WrappedDouble(2))
        #expect(wrappedTwo?.unit?.reciprocal == WrappedDouble(0.5))
    }

    @Test func unitWitnessFromPartialReciprocal() {
        #expect(Unit(WrappedDouble.zero) == nil)

        let unit = Unit(WrappedDouble(4))
        #expect(unit?.value == WrappedDouble(4))
        #expect(unit?.reciprocal == WrappedDouble(0.25))
    }
}

struct AdditiveDerivationTests {
    @Test func sumDerivedFromBinaryPlus() {
        let values = NonEmpty(DoublePair(1, 2), [DoublePair(3, 4), DoublePair(5, 6)])
        #expect(DoublePair.sum(values) == DoublePair(9, 12))
    }

    @Test func binaryPlusDerivedFromSumPrimitive() {
        #expect(SumPrimitive(2) + SumPrimitive(3) == SumPrimitive(5))
    }

    @Test func arraySumForMonoid() {
        #expect([DoublePair(1, 1), DoublePair(2, 3)].sum == DoublePair(3, 4))
        #expect(([DoublePair]() as [DoublePair]).sum == .zero)
    }

    @Test func semigroupArraySumResult() {
        #expect([DoublePair(1, 2), DoublePair(3, 4)].sumResult == .success(DoublePair(4, 6)))
        #expect(([] as [DoublePair]).sumResult == .failure(.init()))
    }
}

struct MultiplicativeDerivationTests {
    @Test func productDerivedFromBinaryStar() {
        let values = NonEmpty(WrappedDouble(2), [WrappedDouble(3), WrappedDouble(4)])
        #expect(WrappedDouble.product(values) == WrappedDouble(24))
    }

    @Test func binaryStarDerivedFromProductPrimitive() {
        #expect(ProductPrimitive(3) * ProductPrimitive(4) == ProductPrimitive(12))
    }

    @Test func arrayProductForMonoid() {
        #expect([WrappedDouble(2), WrappedDouble(5)].product() == WrappedDouble(10))
        #expect(([WrappedDouble]() as [WrappedDouble]).product() == .one)
    }

    @Test func semigroupArrayProductResult() {
        #expect([WrappedDouble(2), WrappedDouble(5)].productResult() == .success(WrappedDouble(10)))
        #expect(([] as [WrappedDouble]).productResult() == .failure(.init()))
    }
}

struct ReciprocalAndDivisionTests {
    @Test func reciprocalSuccessAndFailure() throws {
        let reciprocal = try WrappedDouble(4).reciprocal().get()
        #expect(reciprocal == WrappedDouble(0.25))

        switch WrappedDouble.zero.reciprocal() {
        case .success:
            Issue.record("Expected reciprocal failure for zero")
        case .failure(let error):
            #expect(error.context == nil)
        }
    }

    @Test func divisionVariants() throws {
        let result = try WrappedDouble(9).divided(by: WrappedDouble(3)).get()
        #expect(result == WrappedDouble(3))

        let threeUnit = try #require(Unit(WrappedDouble(3)))
        #expect(WrappedDouble(9).divided(by: threeUnit) == WrappedDouble(3))
        #expect(WrappedDouble(9) / threeUnit == WrappedDouble(3))

        switch WrappedDouble(9).divided(by: .zero) {
        case .success:
            Issue.record("Expected division failure for non-unit denominator (zero here)")
        case .failure(let error):
            #expect(error.context == nil)
        }
    }
}

struct LinearCombinationTests {
    @Test func linearCombinationAndWeightedSum() {
        let terms = NonEmpty((2.0, DoublePair(1, 2)), [(-1.0, DoublePair(3, 4))])
        #expect(DoublePair.linearCombination(terms) == DoublePair(-1, 0))

        let weightedTerms = NonEmpty(
            (weight: 2.0, value: DoublePair(1, 2)),
            [(weight: -1.0, value: DoublePair(3, 4))]
        )
        #expect(DoublePair.weightedSum(weightedTerms) == DoublePair(-1, 0))

        #expect(
            DoublePair.linearCombination(2.0, DoublePair(1, 2), -1.0, DoublePair(3, 4)) == DoublePair(-1, 0)
        )
    }

    @Test func arrayEntryPointsAndScaleDown() throws {
        let emptyTerms: [(Double, DoublePair)] = []
        #expect(DoublePair.linearCombination(emptyTerms) == nil)

        let nonEmpty = try #require(
            DoublePair.linearCombination([(2.0, DoublePair(1, 2)), (3.0, DoublePair(4, 5))])
        )
        #expect(nonEmpty == DoublePair(14, 19))

        let downscaled = try DoublePair(8, 10).scaledDown(by: 2.0).get()
        #expect(downscaled == DoublePair(4, 5))

        switch DoublePair(8, 10).scaledDown(by: 0.0) {
        case .success:
            Issue.record("Expected scale-down failure for non-unit scalar (zero here)")
        case .failure:
            break
        }

        let twoUnit = try #require(Unit(2.0))
        #expect(DoublePair(8, 10).scaledDown(by: twoUnit) == DoublePair(4, 5))
    }
}

struct SignAndAbsoluteTests {
    @Test func signAndConvenienceFlags() {
        #expect(WrappedDouble(-2).signum == .negative)
        #expect(WrappedDouble(0).signum == .zero)
        #expect(WrappedDouble(2).signum == .positive)

        #expect(WrappedDouble(3).isPositive)
        #expect(WrappedDouble(-3).isNegative)
        #expect(WrappedDouble(0).isSignZero)
        #expect(-WrappedDouble(7) == WrappedDouble(-7))
    }

    @Test func absoluteAndArrayHelpers() {
        let values = [WrappedDouble(-1), WrappedDouble(2), WrappedDouble(-3)]
        #expect(values.absolutes == [WrappedDouble(1), WrappedDouble(2), WrappedDouble(3)])
        #expect([Signum.negative, .negative, .positive].product() == .positive)
        #expect([Signum.negative, .zero, .positive].product() == .zero)
    }
}

struct ErrorBridgeAndStdlibBridgeTests {
    @Test func typedErrorToUmbrellaErrorMapping() {
        let reciprocalFailure: Result<WrappedDouble, ReciprocalUnavailableError> = .failure(.init("x"))
        let mapped = reciprocalFailure.mapToAlgebraError()
        #expect(mapped == .failure(.reciprocalUnavailable(.init("x"))))
    }

    @Test func floatingPointBridgeFixtureCompilesAndBehaves() throws {
        let doubleValue = requireFloatingPointFieldAlgebra(4.0)
        let reciprocal = try doubleValue.reciprocal().get()
        #expect(Swift.abs(reciprocal - 0.25) < 1e-12)
    }
}

struct AdditiveLawTests {
    @Test func associativityIdentityInverseAndSubtraction() {
        let a = DoublePair(2, -3)
        let b = DoublePair(-5, 7)
        let c = DoublePair(11, 13)

        #expect((a + b) + c == a + (b + c))
        #expect(a + .zero == a)
        #expect(.zero + a == a)
        #expect(a + (-a) == .zero)
        #expect(a - b == a + (-b))
    }

    @Test func varargAndNonEmptySummationEntryPoints() {
        let vararg = DoublePair.sum(DoublePair(1, 2), DoublePair(3, 4), DoublePair(5, 6))
        #expect(vararg == DoublePair(9, 12))

        let nonEmpty = NonEmpty(DoublePair(1, 1), [DoublePair(2, 3), DoublePair(4, 5)])
        #expect(nonEmpty.sum == DoublePair(7, 9))
    }
}

struct MultiplicativeLawTests {
    @Test func associativityIdentityAndDistributivity() {
        let a = WrappedDouble(2)
        let b = WrappedDouble(3)
        let c = WrappedDouble(-4)

        #expect((a * b) * c == a * (b * c))
        #expect(a * .one == a)
        #expect(.one * a == a)
        #expect(a * (b + c) == (a * b) + (a * c))
        #expect((a + b) * c == (a * c) + (b * c))
    }

    @Test func nonEmptyProductEntryPoint() {
        let nonEmpty = NonEmpty(WrappedDouble(2), [WrappedDouble(3), WrappedDouble(5)])
        #expect(nonEmpty.product() == WrappedDouble(30))
    }
}

struct CollectionDispatchTests {
    @Test func additiveMonoidArraySumUsesElementSumWitness() {
        let values = [BiasedSum(1), BiasedSum(2), BiasedSum(3)]
        #expect(values.sum == BiasedSum(1_006))
    }

    @Test func multiplicativeMonoidArrayProductUsesElementProductWitness() {
        let values = [BiasedProduct(2), BiasedProduct(5)]
        #expect(values.product() == BiasedProduct(110))
    }
}

struct UnitAndWitnessTests {
    @Test func nonZeroIsStrictlyZeroExclusionNotUnitWitness() throws {
        let nonZeroTwo = try #require(NonZero(Mod4(2)))
        #expect(nonZeroTwo.value == Mod4(2))
        #expect(nonZeroTwo.unit == nil)
    }

    @Test func reciprocalAndDivisionFailForNonZeroNonUnit() {
        #expect(Mod4(2).isZero == false)

        switch Mod4(2).reciprocal() {
        case .success:
            Issue.record("Expected reciprocal failure for non-unit element")
        case .failure:
            break
        }

        switch Mod4(3).divided(by: Mod4(2)) {
        case .success:
            Issue.record("Expected division failure for non-unit denominator")
        case .failure:
            break
        }
    }

    @Test func unitEqualityHashingAndDivisionViaWitness() throws {
        let u3a = try #require(Unit(Mod4(3)))
        let u3b = try #require(Unit(Mod4(3)))
        let set: Set<Unit<Mod4>> = [u3a, u3b]
        #expect(set.count == 1)
        #expect(u3a == u3b)

        #expect(Mod4(3).divided(by: u3a) == Mod4(1))
        #expect(Mod4(3) / u3a == Mod4(1))
    }

    @Test func customWitnessAndLegacyAliasPath() {
        let witness = WrappedDoubleWitness(value: WrappedDouble(2), reciprocal: WrappedDouble(0.5))
        let legacy = requireLegacyInvertiable(witness)
        #expect(legacy.value == WrappedDouble(2))
        #expect(legacy.reciprocal == WrappedDouble(0.5))

        #expect(WrappedDouble(8).divided(by: witness) == WrappedDouble(4))
        #expect(WrappedDouble(8) / witness == WrappedDouble(4))
    }
}

struct RightModuleAndIdentityConvenienceTests {
    @Test func rightLinearCombinationEntryPoints() {
        let terms = NonEmpty((DoublePair(1, 2), 2.0), [(DoublePair(3, 4), -1.0)])
        #expect(DoublePair.rightLinearCombination(terms) == DoublePair(-1, 0))

        let emptyTerms: [(DoublePair, Double)] = []
        #expect(DoublePair.rightLinearCombination(emptyTerms) == nil)
    }

    @Test func rightScaleDownVariants() throws {
        let downscaled = try DoublePair(8, 10).rightScaledDown(by: 2.0).get()
        #expect(downscaled == DoublePair(4, 5))

        switch DoublePair(8, 10).rightScaledDown(by: 0.0) {
        case .success:
            Issue.record("Expected right scale-down failure for non-unit scalar")
        case .failure:
            break
        }

        let twoUnit = try #require(Unit(2.0))
        #expect(DoublePair(8, 10).rightScaledDown(by: twoUnit) == DoublePair(4, 5))
    }

    @Test func moduleIdentityConvenienceHelpers() {
        #expect(DoublePair.scaledOne(by: 3.0) == DoublePair(3, 3))
        #expect(DoublePair.rightScaledOne(by: 3.0) == DoublePair(3, 3))
    }
}

struct ErrorDomainCoverageTests {
    @Test func divisionAndEmptyCollectionFailuresMapToUmbrella() {
        let divisionFailure: Result<WrappedDouble, DivisionByNonUnitError> = .failure(.init("d"))
        #expect(divisionFailure.mapToAlgebraError() == .failure(.divisionByNonUnit(.init("d"))))

        let emptyFailure: Result<WrappedDouble, EmptyCollectionError> = .failure(.init("e"))
        #expect(emptyFailure.mapToAlgebraError() == .failure(.emptyCollection(.init("e"))))
    }

    @Test func successfulResultPassesThroughErrorMapper() {
        let success: Result<Int, EmptyCollectionError> = .success(42)
        #expect(success.mapToAlgebraError() == .success(42))
    }
}

struct SignumEdgeTests {
    @Test func signumFlipAndEmptyProductIdentity() {
        #expect(Signum.negative.flipped == .positive)
        #expect(Signum.zero.flipped == .zero)
        #expect(Signum.positive.flipped == .negative)
        #expect(([Signum]() as [Signum]).product() == .positive)
    }
}

struct CompositeProtocolFixtureTests {
    @Test func fieldAndDivisionRingFixtureCompiles() {
        let asField = requireField(2.0)
        #expect(asField * 3.0 == 6.0)

        let asDivisionRing = requireDivisionRing(4.0)
        #expect(asDivisionRing + 1.0 == 5.0)
    }
}

struct MapAndSumTests {
    // MARK: NonEmpty.mapAndSum

    @Test func nonEmptyMapAndSumIsTotal() {
        let values = NonEmpty(DoublePair(1, 2), [DoublePair(3, 4), DoublePair(5, 6)])
        #expect(values.mapAndSum { DoublePair($0.first * 2, $0.second * 2) } == DoublePair(18, 24))
    }

    @Test func nonEmptyMapAndSumSummableVariantDispatchesThroughWitness() {
        // `T: AdditiveSemigroupSummable` overload: calls `T.sum` directly through the
        // `AdditivelySummable` formal requirement — BiasedSum's +1000 bias is applied.
        // Swift prefers this overload over the AdditiveSemigroup one for AdditiveSemigroupSummable types.
        let values = NonEmpty(BiasedSum(1), [BiasedSum(2)])
        #expect(values.mapAndSum { $0 } == BiasedSum(1_003))
    }

    // MARK: Sequence.mapAndSumResult

    @Test func sequenceMapAndSumResultSuccessAndEmpty() {
        let values = [DoublePair(1, 2), DoublePair(3, 4)]
        // transform swaps components: (1,2)→(2,1), (3,4)→(4,3); sum = (6,4)
        #expect(values.mapAndSumResult { DoublePair($0.second, $0.first) } == .success(DoublePair(6, 4)))
        #expect(([] as [DoublePair]).mapAndSumResult { $0 } == .failure(.init()))
    }

    @Test func sequenceMapAndSumResultDispatchesThroughSumWitness() {
        // Swift prefers the `T: AdditiveSemigroupSummable` overload for BiasedSum, so
        // `T.sum` is called directly — BiasedSum's +1000 bias is applied.
        let values = [BiasedSum(1), BiasedSum(2)]
        #expect(values.mapAndSumResult { $0 } == .success(BiasedSum(1_003)))
        #expect(([] as [BiasedSum]).mapAndSumResult { $0 } == .failure(.init()))
    }

    // MARK: Sequence.mapAndSum

    @Test func sequenceMapAndSumAndZeroForEmpty() {
        let values = [SumPrimitive(3), SumPrimitive(7)]
        #expect(values.mapAndSum { SumPrimitive($0.raw * 2) } == SumPrimitive(20))
        #expect(([] as [SumPrimitive]).mapAndSum { $0 } == SumPrimitive(0))
    }

    @Test func sequenceMapAndSumDispatchesThroughSumWitness() {
        // Mirrors CollectionDispatchTests but via mapAndSum. Identity transform should still
        // route through BiasedSum.sum and accumulate the 1_000 bias once.
        let values = [BiasedSum(1), BiasedSum(2), BiasedSum(3)]
        #expect(values.mapAndSum { $0 } == BiasedSum(1_006))
    }
}
