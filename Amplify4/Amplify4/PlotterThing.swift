//
//  PlotterThing.swift
//  Amplify4
//
//  Created by Bill Engels on 2/25/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class PlotterThing: NSObject {
    var bounds = NSRect(x: 0, y: 0, width: 10, height: 5)
    override init() {    }
    func plot() {    } // override to plot in regular mode
    func hiplot() {  } // override to highlight
}

class StringThing : PlotterThing {
    let string : String
    let point : NSPoint
    let attr : NSDictionary?
//    let bounds : NSRect
    
    init (string : String, point : NSPoint) {
        self.string = string
        self.point = point
        self.attr = nil
        super.init()
        bounds = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr)
    }
    
    init (string : String, point : NSPoint, attr : NSDictionary) {
        self.string = string
        self.point = point
        self.attr = attr
        super.init()
        bounds = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr)
        bounds.origin = point
    }
    
    override func plot() {
        (string as NSString).drawAtPoint(point, withAttributes: attr)
    }
}

class VStringThing : PlotterThing {
    let string : String
    let point : NSPoint
    let attr : NSDictionary?
//    let bounds : NSRect
    
    init (string : String, point : NSPoint, attr : NSDictionary) {
        self.string = string
        self.point = point
        self.attr = attr
        let rec = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr)
        super.init()
        bounds = NSMakeRect(point.x, point.y, rec.height, -rec.width)
    }
    
    override func plot() {
        var tran = NSAffineTransform()
        tran.translateXBy(point.x, yBy: point.y)
        tran.rotateByDegrees(-90)
        tran.concat()
        (string as NSString).drawAtPoint(NSMakePoint(0, 0), withAttributes: attr)
        tran.invert()
        tran.concat()
    }
}


class BezThing : PlotterThing {
    let bez : NSBezierPath
    let strokeColor : NSColor?
    let fillColor : NSColor?
//    let bounds : NSRect
    
    init(bez : NSBezierPath, point : NSPoint, fillColor : NSColor?, strokeColor: NSColor?, scale : CGFloat) {
        self.bez = bez.copy() as NSBezierPath
        var move = NSAffineTransform()
        move.translateXBy(point.x, yBy: point.y)
        move.scaleBy(scale)
        self.bez.transformUsingAffineTransform(move)
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        super.init()
        bounds = bez.bounds
        bounds.size.width *= scale
        bounds.size.height *= scale
        bounds.origin.x *= scale
        bounds.origin.y *= scale
        bounds = NSOffsetRect(bounds, point.x, point.y)
        let linewidth = bez.lineWidth
        bounds = NSInsetRect(bounds, -linewidth/2, -linewidth/2)
    }
    
    override func plot() {
        if let color = fillColor {
            color.set()
            bez.fill()
        }
        if let color = strokeColor {
            color.set()
            bez.stroke()
        }
    }
}

class ArrayThing : PlotterThing {
    let ara : [PlotterThing]
    init (ara : [PlotterThing]) {
        self.ara = ara
    }
    override func plot() {
        for thing in ara {
            thing.plot()
        }
    }
}


