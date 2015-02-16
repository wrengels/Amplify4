//
//  Int1DArrayController.swift
//  Amplify4
//
//  Created by Bill Engels on 2/11/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class Int1DArrayController: NSObject,  NSTableViewDataSource,NSTableViewDelegate {
    var vals = [0]
    var labels = [0]
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return vals.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        
        if tableColumn.identifier! == "Labels" {
            return labels[row] as NSNumber
        } else {
            return vals[row]
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject!, forTableColumn tableColumn: NSTableColumn!, row: Int) {
        let newval : Int = (object as NSString).integerValue
        vals[row] = newval
    }
    
}