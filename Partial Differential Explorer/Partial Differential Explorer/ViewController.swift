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
    @IBOutlet weak var pathView: GradientDescentView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    let equation1: Expr = ((2 * "x") + (3 * "y")) * ("x" + (-1 * "y")) ==== 2
    let equation2: Expr = ((3 * "x") + "y") ==== 5
    var system: Expr {
        return costFunction([equation1, equation2])
    }
    
    var currentSolution: [Values] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathView.viewController = self
        
        self.view.window?.acceptsMouseMovedEvents = true
    }
    
    func solveSystem(startingPoint: NSPoint) {
        
        let startingValues: Values = ["x": Double(startingPoint.x), "y": Double(startingPoint.y)]
        
        let solution = solve(system, initial: startingValues)
        currentSolution = solution
        
        pathView.setNeedsDisplayInRect(pathView.bounds)
        
        //pathView.drawPath(segments)
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
}

