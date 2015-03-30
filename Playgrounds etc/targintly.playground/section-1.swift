// Playground - noun: a place where people can play

import Cocoa

var t = [0,1,2,3,4,5,6,7,8,9]

t[0...4]

let pre = t[0...4]
let post = t[6...9]

let tt = pre + t + post

t.count
t[6..<t.count]
t[(t.count-5)..<t.count]