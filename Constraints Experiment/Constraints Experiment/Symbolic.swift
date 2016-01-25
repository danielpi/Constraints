import Foundation


public indirect enum Expr {
    case Sum(Expr, Expr)
    case Product(Expr, Expr)
    case Constant(Double)
    case Variable(String)
}

public typealias Variables = [Expr]
public typealias Values = [Expr: Double]
public typealias Derivatives = [Expr: Expr]

extension Expr: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Constant(Double(value))
    }
}

extension Expr: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Constant(value)
    }
}

extension Expr: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = .Variable(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .Variable(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .Variable(value)
    }
}

extension Expr: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Sum(let a1, let a2):
            return "(" + a1.description + " + " + a2.description + ")"
        case .Product(let m1, let m2):
            return "(" + m1.description + " * " + m2.description + ")"
        case .Constant(let value):
            return String(value)
        case .Variable(let label):
            return label
        }
    }
}

extension Expr: Equatable {}
extension Expr: Hashable {
    public var hashValue: Int {
        switch self {
        case let .Constant(a):
            return a.hashValue
        case let .Variable(name):
            return name.hashValue
        default:
            fatalError("Only constants and variables can be hashable")
        }
    }
}

public func == (lhs: Expr, rhs: Expr) -> Bool {
    switch (lhs, rhs) {
    case let (.Constant(a), .Constant(b)):
        return a == b
    case let (.Variable(a), .Variable(b)):
        return a == b
    default:
        return false
    }
}

public func + (lhs: Expr, rhs: Expr) -> Expr {
    switch (lhs, rhs) {
    case (.Constant(0), _):
        return rhs
    case (_, .Constant(0)):
        return lhs
    case (.Constant(let a), .Constant(let b)):
        return .Constant(a + b)
    default:
        return Expr.Sum(lhs, rhs)
    }
}

public func negate(exp: Expr) -> Expr {
    switch exp {
    case let .Constant(val):
        return .Constant(-1 * val)
    case .Variable(_):
        return Expr.Product(-1, exp)
    case let .Product(lhs, rhs):
        return Expr.Product(negate(lhs), rhs)
    case let .Sum(lhs, rhs):
        return Expr.Sum(negate(lhs), rhs)
    }
}

public func - (lhs: Expr, rhs: Expr) -> Expr {
    switch (lhs, rhs) {
    case (.Constant(0), _):
        return rhs
    case (_, .Constant(0)):
        return lhs
    case (.Constant(let a), .Constant(let b)):
        return .Constant(a - b)
    default:
        return Expr.Sum(lhs, negate(rhs))
    }
}

public prefix func -(exp: Expr) -> Expr {
    return negate(exp)
}

infix operator ==== { associativity left precedence 140 }
public func ==== (lhs: Expr, rhs: Expr) -> Expr {
    return lhs - rhs
}

public func * (lhs: Expr, rhs: Expr) -> Expr {
    switch (lhs, rhs) {
    case (.Constant(0), _):
        return .Constant(0)
    case (_, .Constant(0)):
        return .Constant(0)
    case (.Constant(1), _):
        return rhs
    case (_, .Constant(1)):
        return lhs
    case (.Constant(let a), .Constant(let b)):
        return .Constant(a * b)
    default:
        return Expr.Product(lhs, rhs)
    }
}

// The addend is the second item of the sum list:
public func addend(s: Expr) -> Expr {
    switch s {
    case .Sum(let a1, _):
        return a1
    default:
        fatalError("Tried to get the addend from an expression that was not a sum")
    }
}

// The augend is the third item of the sum list:
public func augend(s: Expr) -> Expr {
    switch s {
    case .Sum(_, let a2):
        return a2
    default:
        fatalError("Tried to get the augend from an expression that was not a sum")
    }
}

// The multiplier is the second item of the product list:
public func multiplier(p: Expr) -> Expr {
    switch p {
    case .Product(let m1, _):
        return m1
    default:
        fatalError("Tried to get the multiplier from an expression that was not a product")
    }
}

// The multiplican is the third item of the product list:
public func multiplicand(p: Expr) -> Expr {
    switch p {
    case .Product(_, let m2):
        return m2
    default:
        fatalError("Tried to get the multiplicand from an expression that was not a product")
    }
}

public func deriv(exp: Expr, _ variable: Expr) -> Expr {
    switch exp {
    case .Constant(_):
        return .Constant(0)
    case .Variable(_):
        return exp == variable ? .Constant(1) : .Constant(0)
    case .Sum(_, _):
        return deriv(addend(exp), variable) + deriv(augend(exp), variable)
    case .Product(_, _):
        return multiplier(exp) * deriv(multiplicand(exp), variable) + deriv(multiplier(exp), variable) * multiplicand(exp)
    }
}

public func eval(exp: Expr, _ values: [Expr: Double] ) -> Double {
    switch exp {
    case let .Constant(val):
        return val
    case .Variable(_):
        return values[exp]!
    case let .Sum(lhs, rhs):
        return eval(lhs, values) + eval(rhs, values)
    case let .Product(lhs, rhs):
        return eval(lhs, values) * eval(rhs, values)
    }
}

public func findVariables(exp: Expr) -> [Expr] {
    func iter(exp: Expr) -> [Expr] {
        switch exp {
        case .Variable(_):
            return [exp]
        case .Constant(_):
            return []
        case let .Sum(lhs, rhs):
            return findVariables(lhs) + findVariables(rhs)
        case let .Product(lhs, rhs):
            return findVariables(lhs) + findVariables(rhs)
        }
    }
    return Array(Set(iter(exp)))
}

public func partialDerivatives(exp: Expr) -> Derivatives {
    let variables = findVariables(exp)
    return variables.reduce([Expr: Expr]()) { (var initial, variable) in
        initial[variable] = deriv(exp, variable)
        return initial
    }
}

public let epsilon: Double = 1e-12

public func costFunction(equations: [Expr]) -> Expr {
    return equations.map({ $0 * $0 }).reduce(Expr.Constant(0.0), combine: +)
}

public func stepDirection(partialDerivatives: Derivatives, at values: Values) -> Values {
    let derivatives = partialDerivatives.reduce(Values()) {
        (var initial, derivative) in
        initial[derivative.0] = -1 * eval(derivative.1, values)
        return initial
    }
    
    let total: Double = derivatives.reduce(0.0) { return $0 + abs($1.1) }
    
    if total == 0.0 {
        fatalError("stepDirection has failed to pick a direction")
    }
    
    return derivatives.reduce(Values()) {
        (var initial, derivative) in
        initial[derivative.0] = derivative.1 / total
        return initial
    }
}

public typealias LineSearchAlgorithm = (function: Expr, derivatives: Derivatives, direction: Values, start: Values) -> Values

func generateBackTrackingLineSearchAlgorithm(controlParameter controlParameter: Double, shrinkFactor: Double, initialStepSize: Double) -> LineSearchAlgorithm {
    
    precondition(controlParameter > 0.0 && controlParameter <= 1.0)
    precondition(shrinkFactor > 0.0 && shrinkFactor <= 1.0)
    
    func backTrackingLineSearch(function: Expr, derivatives: Derivatives, direction: Values, start: Values) -> Values {
        
        let localSlope: Double = derivatives.reduce(0.0) { (initial, derivative) in
            let (variable, partialDerivative) = derivative
            return initial + (eval(partialDerivative, start) * direction[variable]!)
        }
        let t = -1 * controlParameter * localSlope
        
        let fx = eval(function, start)
        var stepSize = initialStepSize
        var candidate: Values = start
        var f_candidate: Double
        var armijoGoldsteinCondition: Bool = false
        
        repeat {
            stepSize = stepSize * shrinkFactor
            candidate = start.reduce([Expr: Double]()) { (var intial, variable) in
                intial[variable.0] = variable.1 + stepSize * direction[variable.0]!
                return intial
            }
            f_candidate = eval(function, candidate)
            
            armijoGoldsteinCondition = ((fx - f_candidate) >= (stepSize * t))
        } while !armijoGoldsteinCondition
        
        return candidate
    }
    
    return backTrackingLineSearch
}

public let backTrackingLineSearch = generateBackTrackingLineSearchAlgorithm(controlParameter: 0.5,
    shrinkFactor: 0.5,
    initialStepSize: 2.0)


// I think the step function should return an enum that can specify the different fault/success condtions.

enum StepResult {
    case Solved(Values)
    case LocalMinima(Values)
    case ToInfinity
}

enum SolverError: ErrorType {
    case LocalMinima(Values)
    case Unstable
}

public func step(function: Expr, derivatives: Derivatives, start: Values) -> Values? {
    // The cost function is below some threshold
    guard abs(eval(function, start)) > epsilon else {
        return nil
    }
    
    // All partial derivatives are close to zero (indicating a local minima)
    let localMinima = derivatives.reduce(false) { return (eval($1.1, start) < epsilon && $0)}
    if localMinima {
        print("localMinima: ")
        return nil
    }
    
    let direction = stepDirection(derivatives, at: start)
    let newPoint = backTrackingLineSearch(function: function, derivatives: derivatives, direction: direction, start: start)
    
    // The solver fails to converge
    if newPoint.reduce(false, combine: { $1.1.isInfinite || $0 }) {
        print("Blew out")
        return nil
    }
    
    return newPoint
}


// If the solver is going to take a long time then it should be broken up so that feedback can be given to the user.
// Also the function doesn't provide any indication of success or failer.

public func solve(exp: Expr, initial: Values) -> [Values] {
    let pd = partialDerivatives(exp)
    var path = [initial]
    
    for stepNo in 1...1000 {
        print(stepNo)
        let previous = path.last!
        
        if let next = step(exp, derivatives: pd, start: previous) {
            path.append(next)
        } else {
            return path
        }
    }
    
    return path
}

