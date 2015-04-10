//
//  MapItem.swift
//  Amplify4
//
//  Created by Bill Engels on 3/13/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class MapItem: NSObject {
    var isLit = 0
    var isClickable = false
    var coItems = [MapItem]()
    var rec = NSRect()
    var litBez = NSBezierPath()
    var highlightPoint = NSPoint()
    let highlightLineWidth : CGFloat = 4 // width of highlight line
    let highlightStrokeColor = NSColor(red: 36/255, green: 204/255, blue: 217/255, alpha: 1)
    let highlightScale : CGFloat = 1.3

    func doLitBez (b : NSBezierPath) {
        self.litBez = b
        var move = NSAffineTransform()
        move.translateXBy(highlightPoint.x, yBy: highlightPoint.y)
        move.scaleBy(highlightScale)
        self.litBez.transformUsingAffineTransform(move)
        litBez.lineWidth =   highlightLineWidth
    }
    
    func report() -> NSAttributedString {
        // overridden by match or frag
        return NSAttributedString()
    }
    
    func info() -> NSAttributedString {
        // overridden by match and frag
        return NSAttributedString()
    }
    
    func lightCoItems() {
        self.isLit++
        self.isClickable = true
        for item in coItems {
            item.isLit++
        }
    }
    
    func unlightCoItems() {
        self.isLit--
        self.isClickable = false
        for item in coItems {
            item.isLit--
        }
    }
    
    func plotHighlight() {
        highlightStrokeColor.set()
        litBez.stroke()
    }
    
}
