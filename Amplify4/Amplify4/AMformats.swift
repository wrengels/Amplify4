//
//  AMformats.swift
//  Amplify4
//
//  Created by Bill Engels on 2/25/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

let fmat = AMformats()

class AMformats: NSObject {
    
    let normal, big, bigital, blue, red, bold, bigbold, bigcenter,
    symb,
    seq, redseq, blueseq, greyseq,
    h0, h0ital, h1, h2, h3,
    hline1, hline2, hline3,
    hlineblue, hlinered  : NSDictionary
    
    override init () {
        let fmatPath = NSBundle.mainBundle().pathForResource("formats", ofType: "rtf")
        let fmatURL = NSURL(fileURLWithPath: fmatPath!)!
        let fmatAString : NSAttributedString = NSAttributedString(URL: fmatURL, documentAttributes: nil)!
        let fmatString = fmatAString.string as NSString
        
        func attributesForThis(ss : NSString) -> NSDictionary {
            let stlocation = fmatString.rangeOfString(ss).location
            let dicat = fmatAString.attributesAtIndex(stlocation, effectiveRange: nil)
            return dicat
        }

       
        normal = attributesForThis("normalFmat")
        big = attributesForThis("bigFmat")
        bigital = attributesForThis("bigitalFmat")
        blue = attributesForThis("blueFmat")
        red = attributesForThis("redFmat")
        bold = attributesForThis("boldFmat")
        bigbold = attributesForThis("bigboldFmat")
        bigcenter = attributesForThis("bigcenterFmat")
        
        symb = attributesForThis("symbFmat")
        
        seq = attributesForThis("seqFmat")
        redseq = attributesForThis("redseqFmat")
        blueseq = attributesForThis("blueseqFmat")
        greyseq = attributesForThis("greyseqFmat")
        
        h0 = attributesForThis("h0Fmat")
        h0ital = attributesForThis("h0italFmat")
        h1 = attributesForThis("h1Fmat")
        h2 = attributesForThis("h2Fmat")
        h3 = attributesForThis("h3Fmat")
        
        hline1 = attributesForThis("hline1Fmat")
        hline2 = attributesForThis("hline2Fmat")
        hline3 = attributesForThis("hline3Fmat")
        hlineblue = attributesForThis("hlineblueFmat")
        hlinered = attributesForThis("hlineredFmat")
    }
    
}
