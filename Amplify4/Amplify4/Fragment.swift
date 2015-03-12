//
//  Fragment.swift
//  Amplify4
//
//  Created by Bill Engels on 3/5/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class Fragment: PlotterThing {
    let dmatch, gmatch : Match
    let ampSize, totSize : Int
    let quality : CGFloat
    let barRect : NSRect
    let bezFillColor : NSColor
    let maxWidth : CGFloat = 10
    let widthCutoffs : [CGFloat] = [100, 200, 300, 500, 700, 1000, 1500, 2000, 3000, 4000, 7000, 10000]
    
    init(dmatch : Match, gmatch : Match) {
        self.dmatch = dmatch
        self.gmatch = gmatch
        self.ampSize = gmatch.threePrime - dmatch.threePrime + 1
        self.totSize = countElements(dmatch.primer.seq) + ampSize + countElements(gmatch.primer.seq)
        self.quality = dmatch.quality() * gmatch.quality()
        if quality > 0 {
            self.quality = CGFloat(ampSize)/(quality * quality)
        } else {
            quality = 5000000000
        }
        let widthIncrement = maxWidth / (CGFloat(widthCutoffs.count) + 1)
        var barWidth = maxWidth
        for w in widthCutoffs {
            if quality > w {barWidth -= widthIncrement}
        }
        self.bezFillColor = NSColor.blackColor()
        self.barRect = NSRect(origin: NSPoint(x: 0, y: 0), size: NSSize(width: CGFloat(gmatch.threePrime - dmatch.threePrime), height: barWidth))
        
    }
    
    

}
