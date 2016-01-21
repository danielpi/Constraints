//
//  GradientDescentView.swift
//  Partial Differential Explorer
//
//  Created by Daniel Pink on 20/01/2016.
//  Copyright © 2016 Daniel Pink. All rights reserved.
//

import Cocoa

class GradientDescentView: NSView {
    
    weak var viewController: ViewController? = nil
    
    let minX = 0.0
    let maxX = 4.0
    var scaledWidth: Double {
        return maxX - minX
    }
    let minY = -2.0
    let maxY = 2.0
    var scaledHeight: Double {
        return maxY - minY
    }
    
    var transform: NSAffineTransform {
        let transform = NSAffineTransform()
        transform.scaleXBy(self.bounds.width / CGFloat(scaledWidth), yBy: self.bounds.height / CGFloat(scaledHeight))
        transform.translateXBy(CGFloat(-minX), yBy: CGFloat(-minY))
        return transform
    }
    
    func drawPath(path: [Values]) {
    
        let myContext: CGContextRef? = NSGraphicsContext.currentContext()?.CGContext
        self.transform.concat()
        
        CGContextBeginPath(myContext)
        
        if let solution = path.last {
            CGContextSetStrokeColorWithColor(myContext, NSColor(hue: CGFloat(solution["x"]! / 3.0), saturation: CGFloat((solution["y"]! + 2) / 3.0), brightness: 1.0, alpha: 1.0).CGColor)
            //CGContextSetStrokeColor(myContext, 1.0, CGFloat(solution["x"]! / 3.0), CGFloat(solution["y"]! / 3.0), 1.0)
        }
        
        CGContextSetLineWidth(myContext, 0.01)
        if let first = path.first {
            CGContextMoveToPoint(myContext, CGFloat(first["x"]!), CGFloat(first["y"]!))
        }
        
        for value in path {
            CGContextAddLineToPoint(myContext, CGFloat(value["x"]!), CGFloat(value["y"]!))
        }
        
        
        CGContextStrokePath(myContext)
    }
    
    func paintBackground(dirtyRect: NSRect) {
        let myContext: CGContextRef? = NSGraphicsContext.currentContext()?.CGContext
        
        CGContextSetRGBFillColor(myContext, 1.0, 1.0, 1.0, 1.0)
        CGContextFillRect(myContext, dirtyRect)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        
        super.drawRect(dirtyRect)

        // Drawing code here.
        
        paintBackground(dirtyRect)
        
        if let vc = viewController {
            drawPath(vc.currentSolution)
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        RateLimit.execute(name: "RefreshSolution", limit: 0.05) {
            if let vc = viewController {
                let pointInWindow = theEvent.locationInWindow
                let pointInView = self.convertPoint(pointInWindow, fromView: nil)
                let t = transform
                t.invert()
                let pointInPlane = t.transformPoint(pointInView)
                Swift.print("\(pointInPlane)")
                vc.solveSystem(pointInPlane)
            }
        }
        
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        if let vc = viewController {
            let pointInWindow = theEvent.locationInWindow
            let pointInView = self.convertPoint(pointInWindow, fromView: nil)
            let t = transform
            t.invert()
            let pointInPlane = t.transformPoint(pointInView)
            Swift.print("\(pointInPlane)")
            vc.solveSystem(pointInPlane)
        }
        
        Swift.print("mouseDown:\(theEvent)")
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        Swift.print("mouseMove:\(theEvent)")
    }
    
    /*
    - (void)mouseDown:(NSEvent *)theEvent {
    [self setFrameColor:[NSColor redColor]];
    [self setNeedsDisplay:YES];
    }
*/
    
}
