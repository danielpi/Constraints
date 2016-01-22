
import Cocoa

//: # Constraints Solver

//: Matt Keeter has a great post up (http://www.mattkeeter.com/projects/constraints/) explaining how he created a constraints solver in Haskell for his CAD project. The interactive demos are a lot of fun to play with but I found the code examples difficult to follow. This playground is my attempt to understand the method by implmenting it in Swift.
//:
//: Most of the code is in the Sources folder. The symbolic algebra system and automatic differentiation methods came from my attempt to work through SICP in Swift.
//:

let equation1: Expr = ("ax" * "ax") + ("ay" * "ay") ==== 1
let equation2: Expr = (("ax" - "bx") * ("ax" - "bx")) + (("ay" - "by") * ("ay" - "by")) ==== 2
let equation3: Expr = "by"
let equation4: Expr = "ay"
let equation5: Expr = "cx" - "bx" ==== 1
let equation6: Expr = "cx" ==== 2

//: Note that the ==== operator is just a subtraction. This allows the equations to be cost functions rather than equality functions. The Expr type is a recursive Enum. The variables are StringLiteral compatible and the constants are IntegerLiteral and FloatLiteral compatible.
//:
//: The equations are joined into a cost function by summing their squares.

let system = costFunction([equation1])

print(system)

solve(system, initial: ["ax": 0.0, "ay": 0.0])








/*
print("Cost Function: \(system)")

//: for this particular system there are two solutions. They have been listed below. When entering either of these two sets of values into the equations the result should be 0.0

let solution1: Values = ["x": 1.34, "y": 0.983]
let solution2: Values = ["x": 2.05, "y": -1.16]
eval(system, solution1)
eval(system, solution2)

//: I haven't implemented the fancy mouse over graphic display of the search space. However you can manually enter a starting point and then plot the trajectory of the solver.

let startingPoint: Values = ["x": 1.0, "y": 2.0]

let journey = solve(system, initial: startingPoint)
if let solution = journey.last {
    print("Solutions \(solution) starting from \(startingPoint)")
}

let segments = pathToSegments(journey)
drawSegments(segments, from: Point(x:0, y:-2), to: Point(x: 4, y:2))

//: Another approach to viewing the landscape of the input equations is to view a trace of steps starting at many points. The first diagram below shows the first step from a lot of random starting points. The second diagram shows the first step from a grid of starting points.

let bottomLeft = Point(x:0, y:-2)
let topRight = Point(x: 4, y:2)

let scatter = scatterStep(system, from: bottomLeft, to: topRight, pointCount: 1000)
drawSegments(scatter, from: bottomLeft, to: topRight)

let grid = gridStep(system, from: bottomLeft, to: topRight, every: 0.2)
drawSegments(grid, from: bottomLeft, to: topRight)

func scatterSolve(function: Expr, from: Point, to: Point, pointCount: Int) -> [Segment] {
    var segments:[Segment] = []
    srand48(time(nil))
    
    for _ in 0...pointCount {
        let x = (drand48() * abs(to.x - from.x)) + from.x
        let y = (drand48() * abs(to.y - from.y)) + from.y
        
        let journey = solve(function, initial: ["x": x, "y": y])
        
        segments = segments + pathToSegments(journey)
    }
    
    return segments
}

let scatterFlow = scatterSolve(system, from: bottomLeft, to: topRight, pointCount: 100)
drawSegments(scatterFlow, from: bottomLeft, to: topRight)


func gridSolve(function: Expr, from: Point, to: Point, every: Double) -> [Segment] {
    var segments:[Segment] = []
    
    for x in from.x.stride(through: to.x, by: every) {
        for y in from.y.stride(through: to.y, by: every) {
            let journey = solve(function, initial: ["x": x, "y": y])
            segments = segments + pathToSegments(journey)
        }
    }
    
    return segments
}

let solveGrid = gridSolve(system, from: bottomLeft, to: topRight, every: 0.2)
drawSegments(solveGrid, from: bottomLeft, to: topRight)


// Thoughts
// - Need two string outputs for Expr. This is what the output currently looks like
// ((((2.0 * x) + (3.0 * y)) * (x + (-1.0 * y))) + -2.0)
// One output should try and show the formula in the most readable manner possible
// ((2x + 3y) * (x - y) - 2)
// The other should be in a format that can be pasted back into a program such that it will act as an Expr literal
// ((((2.0 * "x") + (3.0 * "y")) * ("x" + (-1.0 * "y"))) + -2.0)
// - The program is compiling very slowly now. Need to create a project so that I can compile it outside of a playground. This gives better diagnostics about what is causeing the hold up.
// - Would really like to be able to match the visualisations from the original blog post. Bit worried that my Swift implementation won't be as fast as the javascript.
// - Would also really like to have the linkages demos working.
// - Have just realised why I want to do this so much. At the end of Uni I asked Cameron Bell to make sure that I never gave up on producing a linkage design program. Finally I have some clue as to how to progress in that direction.
// - Should investigate wolfram labs symbolic algebra system. They also push the knowledge enabled programming language which fits with my thoughts for the Units project
*/
