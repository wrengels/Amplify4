// Playground - noun: a place where people can play

import Cocoa

var settings = NSMutableDictionary(contentsOfFile:  "/Users/WRE/DropBox/Amplify4/settings.plist")

let rsettings = NSDictionary(contentsOfFile:  "settings")

let rset = NSDictionary(object: "hello", forKey: "world")


let bundle = NSBundle.mainBundle()

let myFilePath = bundle.pathForResource("settings", ofType: "plist")!


println(myFilePath)


let r2 = NSDictionary(contentsOfFile: myFilePath)
//println(r2)
let en = r2!.valueForKey("entropy")! as [Int]
var ds = r2!.valueForKey("dScores")! as [Int]

// Here's how to turn a 1D array into a 2D array (of slices)
var dScores = [Slice<Int>]()
for i : Int in 0...14 {
   dScores.append(ds[(i * 5)...(i*5 + 4)])
}

dScores[3][4] * 3

print(dScores)

dScores[6]

let nsd = ds as NSArray

var answer = "Don't Know"
let surl = NSURL(fileURLWithPath: "/Users/WRE/DropBox/Amplify4/settings")!
let sext = surl.pathExtension!
switch sext {
case "plist", "", "txt" : answer = "plain"
default : answer = "not so plain"
}

answer

let i1 : Int = 23
let i2 : Int  = 8
let q : Double = Double(i1 / i2)
let qw = Double(i1) / Double(i2)

ds[0] = 42
dScores[0]
dScores[0][1] = 42
dScores[0]
ds[0...10]

// You can use "splice" to add elements from an Array or a Slice
var nsd10 = nsd.subarrayWithRange(NSMakeRange(0, 10))
var nsda = nsd10 as Array<Int>
let nslice = nsda[0...5]
var nara = Array<Int>()
for k in nslice {nara.append(k)}
nara
nara.splice(nslice, atIndex: 1)
nara.splice(nara, atIndex: 3)
NSRegistrationDomain



