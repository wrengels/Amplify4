//
//  SearchPrimers.swift
//  Amplify4
//
//  Created by Bill Engels on 3/16/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class SearchPrimers: NSWindowController {

    @IBOutlet weak var searchTextField: NSTextField!
    @IBOutlet weak var notFoundField: NSTextField!
    

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func findNextPrimer(sender: AnyObject) {
        let apdel = NSApplication.sharedApplication().delegate! as! AppDelegate
        notFoundField.hidden = true
        let substrate = apdel.substrateDelegate
        var index : Int = substrate.primerTableView.selectedRowIndexes.firstIndex
        if index == NSNotFound {
            index = 0
        } else {
            index++
        }
        let primers = substrate.primers
        let txt = searchTextField.stringValue.uppercaseString
        while (index < primers.count) && ((primers[index].line as String).uppercaseString.rangeOfString(txt) == nil) {
            index++
        }
        if index < primers.count {
            substrate.primerTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            substrate.primerTableView.scrollRowToVisible(index)
        } else {
            // Not found, so try going back to the top
            index = 0
            while (index < primers.count) && ((primers[index].line as String).uppercaseString.rangeOfString(txt) == nil) {
                index++
            }
            if index < primers.count {
                substrate.primerTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
                substrate.primerTableView.scrollRowToVisible(index)
            } else {
                // Not found anyhere
                notFoundField.stringValue = "(Not Found)"
                notFoundField.hidden = false
            }
        }
    }

    @IBAction func selectAllMatches(sender: AnyObject) {
        var numFound = 0
        let apdel = NSApplication.sharedApplication().delegate! as! AppDelegate
        let substrate = apdel.substrateDelegate
        let primers = substrate.primers
        substrate.primerTableView.deselectAll(self)
        let txt = searchTextField.stringValue.uppercaseString
        var index = 0;
        for primer in primers {
            let line = primer.line.uppercaseString as String
            if line.rangeOfString(txt) != nil {
                substrate.primerTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: true)
                numFound++
            }
            index++
        }
        notFoundField.stringValue = "\(numFound) cases found"
        notFoundField.hidden = false
    }
}
