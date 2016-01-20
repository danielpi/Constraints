//
//  ViewController.swift
//  Partial Differential Explorer
//
//  Created by Daniel Pink on 20/01/2016.
//  Copyright © 2016 Daniel Pink. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var runButton: NSButton!
    @IBOutlet weak var pointCountField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.run(self)
    }

    @IBAction func run(sender: AnyObject) {
        let equation1: Expr = ((2 * "x") + (3 * "y")) * ("x" + (-1 * "y")) ==== 2
        let equation2: Expr = ((3 * "x") + "y") ==== 5
        
        let system = costFunction([equation1, equation2])
        
        let bottomLeft = Point(x:0, y:-2)
        let topRight = Point(x: 4, y:2)
        
        let pointCount = pointCountField.integerValue
        
        let scatterFlow = scatterSolve(system, from: bottomLeft, to: topRight, pointCount: pointCount < 10 ? 10 : pointCount)
        print("All Segments: \(scatterFlow.count)")
        let filteredSegments = scatterFlow.filter({ $0.lengthSquared > 0.0001 })
        print("LongSegments: \(filteredSegments.count)")
        let drawing = drawSegments(filteredSegments, from: bottomLeft, to: topRight)
        
        /*
        let scatter = scatterStep(system, from: bottomLeft, to: topRight, pointCount: pointCount < 10 ? 10 : pointCount)
        let drawing = drawSegments(scatter, from: bottomLeft, to: topRight)
        
        let grid = gridStep(system, from: bottomLeft, to: topRight, every: 0.2)
        drawSegments(grid, from: bottomLeft, to: topRight)
        
        let scatterFlow = scatterSolve(system, from: bottomLeft, to: topRight, pointCount: 100)
        drawSegments(scatterFlow, from: bottomLeft, to: topRight)
        
        let solveGrid = gridSolve(system, from: bottomLeft, to: topRight, every: 0.2)
        let drawing = drawSegments(solveGrid, from: bottomLeft, to: topRight)
        */
        imageView.image = drawing
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
