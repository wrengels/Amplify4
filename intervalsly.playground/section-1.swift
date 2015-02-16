// Playground - noun: a place where people can play

import Cocoa

var m = [Int](1...7)
var mr = 1...20
var mra = [Int](mr)
m += [20,30]

var s = [Character]("hello")

let m3 = mra[3...7]

//let ma = [Int](m3)

let ca : Character = "a"

//let ss = [NSString](s)

mra[10] = 42
s[3] = "X"

let st = String(reverse(s))

let cr : NSColor = NSColor.lightGrayColor()

var goodFont = NSFont(name: "Menlo", size: 12)!

if let theFont = NSFont(name: "Times Boldly Go", size: 12) {
     goodFont  =  theFont
}

goodFont.familyName!