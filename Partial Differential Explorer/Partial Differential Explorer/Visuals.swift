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
    
    public var length: Double {
        return pow(self.lengthSquared, 0.5)
    }
    public var lengthSquared: Double {
        return pow(endPoint.x - startPoint.x, 2.0) + pow(endPoint.y - startPoint.y, 2.0)
    }
    
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
/*
func synchronized(sync: AnyObject, fn: ()->()) {
    objc_sync_enter(sync)
    fn()
    objc_sync_exit(sync)
}

extension Array {
    
    func concurrentMap<U>(transform: (Element) -> U,
        callback: (AnySequence<U>) -> ()) {
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let group = dispatch_group_create()
            let sync = NSObject()
            var index = 0;
            
            // populate the array
            let r = transform(self[0] as Element)
            var results = Array<U>(count: self.count, repeatedValue:r)
            
            for (index, item) in enumerate(self[1..<self.count-1]) {
                dispatch_group_async(group, queue) {
                    let r = transform(item as T)
                    synchronized(sync) {
                        results[index] = r
                    }
                }
            }
            
            dispatch_group_notify(group, queue) {
                callback(AnySequence(results))
            }
    }
}
*/
public func scatterSolve(function: Expr, from: Point, to: Point, pointCount: Int) -> [Segment] {
    var segments:[Segment] = []
    srand48(time(nil))
    /*
    // The below code should synchronise the write to the segments array. 
    
    let backgroundQueue: dispatch_queue_t = dispatch_queue_create("au.com.electronicinnovatons.scatterSolve", DISPATCH_QUEUE_CONCURRENT)
    
    dispatch_apply(pointCount, backgroundQueue) { _ in
        let x = (drand48() * abs(to.x - from.x)) + from.x
        let y = (drand48() * abs(to.y - from.y)) + from.y
        
        let journey = solve(function, initial: ["x": x, "y": y])
        
        segments = segments + pathToSegments(journey)
    }
    */
    
    for _ in 0...pointCount {
        let x = (drand48() * abs(to.x - from.x)) + from.x
        let y = (drand48() * abs(to.y - from.y)) + from.y
        
        let journey = solve(function, initial: ["x": x, "y": y])
        
        segments = segments + pathToSegments(journey)
    }
    
    return segments
}

public func gridSolve(function: Expr, from: Point, to: Point, every: Double) -> [Segment] {
    var segments:[Segment] = []
    
    for x in from.x.stride(through: to.x, by: every) {
        for y in from.y.stride(through: to.y, by: every) {
            let journey = solve(function, initial: ["x": x, "y": y])
            segments = segments + pathToSegments(journey)
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

