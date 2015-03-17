//
//  MapView.swift
//  Amplify4
//
//  Created by Bill Engels on 3/6/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class MapView: NSView {

    var plotters = [PlotterThing]()
    var trackers = [NSTrackingArea]()
    var theDoc : Document? = nil
    var entered = 0
    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    func clearAllTrackingAreas() {
        for area : NSTrackingArea in self.trackingAreas as [NSTrackingArea] {
            self.removeTrackingArea(area)
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        for plotter in plotters {
            plotter.plot()
        }
        for area : NSTrackingArea in self.trackingAreas as [NSTrackingArea] {
            if let itemDic = area.userInfo {
                let item : MapItem = itemDic[0] as MapItem
                if item.isLit > 0  {
                    item.plotHighlight()
                }
            }
        }

    }
    
    override func mouseEntered(theEvent: NSEvent) {
        entered++
        if let trackingArea = theEvent.trackingArea {
            if let itemDic = trackingArea.userInfo {
                let item : MapItem = itemDic[0] as MapItem
                item.lightCoItems()
                self.needsDisplay = true
                self.display()
                let sto = theDoc!.infoTextView.textStorage!
                sto.setAttributedString(item.info())
            }
        }
    }
    
    
    override func mouseExited(theEvent: NSEvent) {
        entered--
        if let trackingArea = theEvent.trackingArea {
            if let itemDic = trackingArea.userInfo {
                let item : MapItem = itemDic[0] as MapItem
                item.unlightCoItems()
                self.needsDisplay = true
                self.display()
                if entered < 1 {
                    let sto = theDoc!.infoTextView.textStorage!
                    sto.setAttributedString(NSAttributedString())
                }
            }
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        for area : NSTrackingArea in self.trackingAreas as [NSTrackingArea] {
            if let itemDic = area.userInfo {
                let item : MapItem = itemDic[0] as MapItem
                if item.isClickable {
                    theDoc!.outputTextView.textStorage?.appendAttributedString(item.report())
                    theDoc!.printOutput()
                }
            }
        }
    }
    
//    override func updateTrackingAreas() {
//        super.updateTrackingAreas()
//        let tareas = self.trackingAreas
//        println("updating tracking areas: \(tareas.count)")
//    }
    
}
