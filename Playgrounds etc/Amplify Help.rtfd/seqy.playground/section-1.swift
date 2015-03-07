// Playground - noun: a place where people can play

import Cocoa

var targ = "CATGATGAAATAACATAAGGTGGTCCCGTCGAAAgccgaagcGCAGAGCTGTCATACTCGAAGGCAGCAGCGACCTTCATCTCGTCGAAAGCGAGTACGCAAAGCTTGTCGGCGTCATCAACTCCATCACTGTCCATTAGGTCTATGACCACATCCAAACATCCTCTTTTTATGTCCACA"
targ = targ.uppercaseString

var ctarg = [Int]()

for c in targ {
    switch c {
    case "G" : ctarg += [0]
    case "A" : ctarg += [1]
    case "T" : ctarg += [2]
    case "C" : ctarg += [3]
      default : ctarg += [4]
        
    }
}

ctarg

