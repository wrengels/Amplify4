//
//  IntArrayController.swift
//  Amplify4
//
//  Created by Bill Engels on 2/11/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class IntArrayController: NSObject,  NSTableViewDataSource,NSTableViewDelegate {
    var vals = [[0]]
    var labels = [Character]("GATCMRWSYKVHDBN")
    var headerColor = NSColor.lightGrayColor()
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return vals.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        if tableColumn.identifier! == "Labels" {
            return  String(labels[row])
        } else {
            let col = tableColumn.identifier!.toInt()!
            return vals[row][col]
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject!, forTableColumn tableColumn: NSTableColumn!, row: Int) {
        let col = tableColumn.identifier!.toInt()!
        let newval : Int = (object as NSString).integerValue
        vals[row][col] = newval
    }
    
}