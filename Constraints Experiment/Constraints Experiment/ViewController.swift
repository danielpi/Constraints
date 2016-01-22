//
//  ViewController.swift
//  Constraints Experiment
//
//  Created by Daniel Pink on 22/01/2016.
//  Copyright © 2016 Daniel Pink. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let equation1: Expr = ("ax" * "ax") + ("ay" * "ay") ==== 1
        let equation2: Expr = (("ax" - "bx") * ("ax" - "bx")) + (("ay" - "by") * ("ay" - "by")) ==== 2
        let equation3: Expr = "by"
        let equation4: Expr = "ay"
        let equation5: Expr = "cx" - "bx" ==== 1
        let equation6: Expr = "cx" ==== 2
        
        let system = costFunction([equation1, equation2, equation3])
        let variables = findVariables(system)
        let pd = partialDerivatives(system)
        
        print(pd)
        
        let start: Values = ["ax": 0.5, "ay": 0.5, "bx": 1.5, "by": 0.0]
        
        let t1 = eval(system, start)
        //let p1 = eval(pd, start)
        
        //let s1 = step(system, derivatives: pd, start: start)
        //let s2 = step(system, derivatives: pd, start: s1!)
        //let s3 = step(system, derivatives: pd, start: s2!)
        //let s4 = step(system, derivatives: pd, start: s3!)
        
        print(system)
        
        print(solve(system, initial: start))

        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

