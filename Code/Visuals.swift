import Cocoa


// Visualisation
public struct Vector {
    public let x: Double
    public let y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public func + (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
public func - (lhs: Vector, rhs: Vector) -> Vector {
    return Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
public func * (lhs: Double, rhs:Vector) -> Vector {
    return Vector(x: lhs * rhs.x, y: lhs * rhs.y)
}
public func * (lhs: Vector, rhs: Double) -> Vector {
    return Vector(x: rhs * lhs.x, y: rhs * lhs.y)
}

public typealias Point = Vector

public struct Segment {
    public let startPoint: Point
    public let endPoint: Point
    
    public init(startPoint: Point, endPoint: Point) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}

public func pathToSegments(path: [Values]) -> [Segment] {
    func iter(start: [Expr: Double], path: [Values], segments: [Segment]) -> [Segment] {
        if let finish = path.first {
            let segment = Segment(startPoint: Point(x: start["x"]!, y: start["y"]!),
                endPoint: Point(x: finish["x"]!, y: finish["y"]!))
            return iter(finish, path: Array(path[1..<path.count]), segments: segments + [segment])
        } else {
            return segments
        }
    }
    return iter(path.first!, path: path, segments: [])
}

public func gridStep(exp: Expr, from: Point, to: Point, every: Double) -> [Segment] {
    let pd = partialDerivatives(exp)
    var segments: [Segment] = []
    
    for x in from.x.stride(through: to.x, by: every) {
        for y in from.y.stride(through: to.y, by: every) {
            if let new = step(exp, derivatives: pd, start: ["x": x, "y": y]) {
                let segment = Segment(startPoint: Point(x: x, y: y), endPoint: Point(x: new["x"]!, y: new["y"]!))
                segments.append(segment)
            }
        }
    }
    return segments
}

public func scatterStep(exp: Expr, from: Point, to: Point, pointCount: Int) -> [Segment] {
    let pd = partialDerivatives(exp)
    var segments:[Segment] = []
    srand48(time(nil))
    
    for _ in 0...pointCount {
        let x = (drand48() * abs(to.x - from.x)) + from.x
        let y = (drand48() * abs(to.y - from.y)) + from.y
        
        if let new = step(exp, derivatives: pd, start: ["x": x, "y": y]) {
            let segment = Segment(startPoint: Point(x: x, y: y), endPoint: Point(x: new["x"]!, y: new["y"]!))
            segments.append(segment)
        }
    }
    
    return segments
}

public func drawSegments(segments: [Segment], from: Point, to: Point) -> NSImage {
    
    let squareSize: CGFloat = 500
    let imgSize = NSMakeSize(squareSize, squareSize)
    let img = NSImage(size: imgSize)
    
    img.lockFocus()
    let lineColor = NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.8)
    lineColor.setStroke()
    
    let xform = NSAffineTransform()
    xform.scaleBy(img.size.height / (CGFloat(to.y - from.y)))
    //xform.scaleBy(img.size.height / 4)
    //xform.rotateByDegrees(-90)
    //xform.translateXBy(CGFloat(from.x), yBy: CGFloat(from.y))
    xform.translateXBy(CGFloat(-1 * from.x), yBy: CGFloat(-1 * from.y))
    xform.concat()
    
    let line = NSBezierPath()
    line.lineWidth = 0.25 / img.size.height
    
    for segment in segments {
        line.moveToPoint(NSPoint(x: segment.startPoint.x, y: segment.startPoint.y))
        line.lineToPoint(NSPoint(x: segment.endPoint.x, y: segment.endPoint.y))
        line.stroke()
    }
    img.unlockFocus()
    
    return img
}

