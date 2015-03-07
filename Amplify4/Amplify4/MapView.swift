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
    
    override var flipped:Bool {
        get {
            return true
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        for plotter in plotters {
            plotter.plot()
        }
    }
    
}
