// Playground - noun: a place where people can play

import Cocoa

let x = sqrt(2.0)
var str = "Hello, playground = \(x)"

String(format: "%.2f",  x)

func forFloat(#val : Double, #decimals : Int ) -> String {
    let f = "%.\(decimals)f"
    return String(format: f, val)
}


"Hello playground = \(forFloat(val: x, decimals: 2))"