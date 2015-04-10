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
        let selfString = self.string as NSString
        if attr != nil {
            let attrDict = attr! as NSDictionary
            bounds = selfString.boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attrDict as [NSObject : AnyObject])
        } else {
             bounds = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: nil)
        }
    }
    
    init (string : String, point : NSPoint, attr : NSDictionary) {
        self.string = string
        self.point = point
        self.attr = attr
        super.init()
        bounds = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr as [NSObject : AnyObject])
        bounds.origin = point
    }
    
    override func plot() {
        if attr != nil {
            let attrDict = attr! as NSDictionary
            (string as NSString).drawAtPoint(point, withAttributes: attrDict as [NSObject : AnyObject])
        } else {
            (string as NSString).drawAtPoint(point, withAttributes: nil)
        }
        
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
        let rec = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr as [NSObject : AnyObject])
        super.init()
        bounds = NSMakeRect(point.x, point.y, rec.height, -rec.width)
    }
    
    override func plot() {
        var tran = NSAffineTransform()
        tran.translateXBy(point.x, yBy: point.y)
        tran.rotateByDegrees(-90)
        tran.concat()
        if attr != nil {
            let attrDict = attr! as NSDictionary
            (string as NSString).drawAtPoint(NSMakePoint(0, 0), withAttributes: attrDict as [NSObject : AnyObject])
        } else {
            (string as NSString).drawAtPoint(NSMakePoint(0, 0), withAttributes: nil)
        }
        
        tran.invert()
        tran.concat()
    }
}

class VStringRectThing : PlotterThing {
    let string : String
    let rect : NSRect
    let attr : NSDictionary?
    //    let bounds : NSRect
    
    init (string : String, rect : NSRect, attr : NSDictionary) {
        self.string = string
        self.rect = rect
        self.attr = attr
        let rec = (self.string as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: attr as [NSObject : AnyObject])
        super.init()
        bounds = rect
    }
    
    override func plot() {
        var tran = NSAffineTransform()
//        tran.translateXBy(rect.origin.x, yBy: rect.origin.y)
        tran.rotateByDegrees(-90)
        tran.concat()
        let drect = NSMakeRect(-(rect.origin.y + rect.size.height), rect.origin.x, rect.size.height, rect.size.width)
        let attrDict = attr! as NSDictionary
        if attr != nil {
            (string as NSString).drawInRect(drect, withAttributes: attrDict as [NSObject : AnyObject])
        } else {
            (string as NSString).drawInRect(drect, withAttributes: nil)
        }
        
//        (string as NSString).drawAtPoint(NSMakePoint(0, 0), withAttributes: attr)
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
        self.bez = bez.copy() as! NSBezierPath
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


