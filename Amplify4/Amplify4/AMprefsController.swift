//
//  AMprefsController.swift
//  Amplify4
//
//  Created by Bill Engels on 2/8/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class AMprefsController: NSWindowController {
    
    @IBOutlet var pairWeightsTableView: NSTableView!
    @IBOutlet var prefsWindow: NSWindow!
    @IBOutlet var pairWeightsCont: IntArrayController!
    @IBOutlet weak var matchWeightsTableView: NSTableView!
    @IBOutlet var matchWeightsCont: Int1DArrayController!
    @IBOutlet weak var runWeightsTableView: NSTableView!
    @IBOutlet var runWeightsCont: Int1DArrayController!
    @IBOutlet weak var entropyTableView: NSTableView!
    @IBOutlet var entropyCont: IntArrayController!
    @IBOutlet var enthalpyCont: IntArrayController!
    @IBOutlet weak var enthalpyTableView: NSTableView!
    @IBOutlet weak var dimWeightsTableView: NSTableView!
    @IBOutlet var dimWeightsCont: IntArrayController!
    
    let settings = NSUserDefaults.standardUserDefaults()
    var initialSettings = NSDictionary()

    
    override func windowDidLoad() {
        super.windowDidLoad()
        matchWeightsCont.labels = [Int](1...50)
        runWeightsCont.labels = [Int](1...50)
        entropyCont.labels = [Character]("GATCN")
        enthalpyCont.labels =  [Character]("GATCN")
        self.setAllArrayVals();

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        let theColumns: [AnyObject]  = pairWeightsTableView.tableColumns + entropyTableView.tableColumns + enthalpyTableView.tableColumns + dimWeightsTableView.tableColumns
        var theColor : NSColor = NSColor()
        for col : NSTableColumn in theColumns as [NSTableColumn] {
            if col.identifier == "Labels" {
                theColor = col.dataCell.backgroundColor!! as NSColor
            } else {
                let hc = col.headerCell as NSTableHeaderCell
                hc.backgroundColor = theColor
                hc.drawsBackground = true
            }
        }
    }
    
    @IBAction func restoreFactorySettings(sender: AnyObject) {
        self.putIntoDefaults(dictionary: globals.factory)
        self.setAllArrayVals()
        self.reloadAllArrayData();
    }
    
    @IBAction func cancel(sender: AnyObject) {
        prefsWindow.endEditingFor(prefsWindow.firstResponder) // This ends editing in text boxes
        self.close()
        self.putIntoDefaults(dictionary: initialSettings)
    }
    
    func currentSettings()-> NSDictionary {
        let currentS = NSMutableDictionary()
        let allkeys = globals.factory.allKeys as [NSString]
        for onekey : NSString in allkeys {
            currentS.setObject(settings.objectForKey(onekey)!, forKey: onekey)
        }
        return NSDictionary(dictionary: currentS)
    }
    
    func putIntoDefaults(#dictionary : NSDictionary) {
        let allkeys = globals.factory.allKeys as [NSString]
        for onekey : NSString in allkeys {
            settings.setObject(dictionary.objectForKey(onekey)!, forKey: onekey)
        }
    }
    
    func setAllArrayVals() {
        pairWeightsCont.vals = settings.arrayForKey(globals.pairScores)! as [[Int]]
        matchWeightsCont.vals = settings.arrayForKey(globals.matchWeights)! as [Int]
        runWeightsCont.vals = settings.arrayForKey(globals.runWeights)! as [Int]
        entropyCont.vals = settings.arrayForKey(globals.entropy)! as [[Int]]
        enthalpyCont.vals = settings.arrayForKey(globals.enthalpy)! as [[Int]]
        dimWeightsCont.vals = settings.arrayForKey(globals.dimScores)! as [[Int]]
    }
    
    @IBAction func loadSettingsFile(sender: AnyObject) {
        var openPanel = NSOpenPanel()
        openPanel.message = "Open a plist file containing settings"
        openPanel.allowedFileTypes = ["plist"]
        openPanel.allowsMultipleSelection = false
        if openPanel.runModal() == NSCancelButton {return}
        if let newSettings : NSDictionary = NSDictionary(contentsOfURL: openPanel.URL!) {
            self.putIntoDefaults(dictionary: newSettings)
            self.setAllArrayVals()
            self.reloadAllArrayData()
        }
    }
    
    @IBAction func saveSettingsFile(sender: AnyObject) {
        var savePanel = NSSavePanel()
        savePanel.message = "Save current settings as a plist file"
        savePanel.allowedFileTypes = ["plist"]
        if savePanel.runModal() == NSCancelButton {return}
        
            prefsWindow.endEditingFor(prefsWindow.firstResponder) // This ends editing in text boxes
            self.putValsIntoSettings()
            let savedSettings : NSDictionary = self.currentSettings()
            let didit = savedSettings.writeToURL(savePanel.URL!, atomically: true)
    }
    
    func reloadAllArrayData() {
        pairWeightsTableView.reloadData()
        matchWeightsTableView.reloadData()
        runWeightsTableView.reloadData()
        entropyTableView.reloadData()
        enthalpyTableView.reloadData()
        dimWeightsTableView.reloadData()
    }
    
    func putValsIntoSettings() {
        settings.setObject(pairWeightsCont.vals, forKey: globals.pairScores)
        settings.setObject(matchWeightsCont.vals, forKey: globals.matchWeights)
        settings.setObject(runWeightsCont.vals, forKey: globals.runWeights)
        settings.setObject(entropyCont.vals, forKey: globals.entropy)
        settings.setObject(enthalpyCont.vals, forKey: globals.enthalpy)
        settings.setObject(dimWeightsCont.vals, forKey: globals.dimScores)
    }
    
    @IBAction func okay(sender: AnyObject) {
        prefsWindow.endEditingFor(prefsWindow.firstResponder) // This ends editing in text boxes
        self.putValsIntoSettings()
        self.close()
    }
}
