//
//  AmplifyHelpController.swift
//  Amplify4
//
//  Created by Bill Engels on 2/19/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class AmplifyHelpController: NSWindowController, NSWindowDelegate {
    @IBOutlet var helpTextView: NSTextView!
    @IBOutlet var helpWindow: NSWindow!
    
    let findthis = "🔹  When you click on an amplicon"

    override func windowDidLoad() {
        super.windowDidLoad()
        if let helpPath = NSBundle.mainBundle().pathForResource("Amplify Help", ofType: "rtfd") {
            let didit = helpTextView.readRTFDFromFile(helpPath)
            helpWindow.releasedWhenClosed = false
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func findThis(sender: AnyObject) {
        helpTextView.setSelectedRange(NSMakeRange(1000, 30))
        helpTextView.scrollRangeToVisible(NSMakeRange(1000, 30))
    }
    
    @IBAction func saveHelp(sender: AnyObject) {
        let sidePath = "/Users/WRE/DropBox/Amplify4/Playgrounds etc/Amplify Helpme.rtfd"
        var didit = false
        if let sideURL = NSURL(fileURLWithPath: sidePath) {
            let sidelen = helpTextView.textStorage!.length
            if let sideRTFD = helpTextView.RTFDFromRange(NSMakeRange(0, sidelen)) {
                didit = sideRTFD.writeToURL(sideURL, atomically: true)
            }
        }
        return
        if let helpPath = NSBundle.mainBundle().pathForResource("Amplify Help", ofType: "rtfd") {
            if let url = NSURL(fileURLWithPath: helpPath) {
                if let len = helpTextView.textStorage?.length {
                    if let theRTFD = helpTextView.RTFDFromRange(NSMakeRange(0, len)) {
                         didit = theRTFD.writeToURL(url, atomically: true)
                        let a = 1

                    }
                }
            }
        }
    }
    
    @IBAction func findMe(sender: AnyObject) {
        if let name = sender.identifier? {
            let nsname = name as NSString
            let helpString = helpTextView.string! as NSString
            let nameRange : NSRange = helpString.rangeOfString(name)
            helpTextView.setSelectedRange(nameRange)
            helpTextView.scrollRangeToVisible(nameRange)
            
        }
    }
    
    
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        helpWindow.orderOut(self)
        return true
    }
    
}
