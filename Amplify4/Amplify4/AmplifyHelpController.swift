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
    @IBOutlet weak var topicsMenu: NSPopUpButton!
    @IBOutlet weak var faqMenu: NSPopUpButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        if let helpPath = NSBundle.mainBundle().pathForResource("Amplify Help", ofType: "rtfd") {
            let didit = helpTextView.readRTFDFromFile(helpPath)
            helpWindow.releasedWhenClosed = false
            if didit {
                let newline = NSCharacterSet(charactersInString: "\r\n")
                let bullits = NSCharacterSet(charactersInString: "▪️•◆")
                let smallbullit = NSCharacterSet(charactersInString: "•")
                let faqset = NSCharacterSet(charactersInString: "▪︎")
                let helpLines = (helpTextView.string! as NSString).componentsSeparatedByCharactersInSet(newline) as! [NSString]
                for line in helpLines {
                    if line.rangeOfCharacterFromSet(bullits).location != NSNotFound {
                        topicsMenu.addItemWithTitle(line as String)
                    }
                    if line.rangeOfCharacterFromSet(faqset).location != NSNotFound{
                        faqMenu.addItemWithTitle(line as String)
                    }
                }
                for mitem in (topicsMenu.itemArray as! [NSMenuItem]) {
                    let mitemTitle = mitem.title as NSString
                    if mitemTitle.rangeOfCharacterFromSet(smallbullit).location != NSNotFound {
                        mitem.indentationLevel = 2
                    }
                }
                
            }
        }
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBOutlet var helpScroll: NSScroller!
    @IBOutlet var helpClip: NSClipView!
    
    func scrollToString(theString : NSString) {
        let helpString = helpTextView.string! as NSString
        let stringRange : NSRange = helpString.rangeOfString(theString as String)
        if stringRange.location == NSNotFound {return}
        var effectiveRange = NSRange(location: 0, length: 0)
        let stringRect = helpTextView.layoutManager!.lineFragmentRectForGlyphAtIndex(stringRange.location, effectiveRange: &effectiveRange)
        helpTextView.setSelectedRange(stringRange)
        helpClip.scrollToPoint(stringRect.origin)
//        helpScroll.reflectScrolledClipView(helpClip)
    }
    
    @IBAction func goToTopic(sender: AnyObject) {
        let popup = sender as! NSPopUpButton
        if let topic = popup.selectedItem?.title {
             let helpString = helpTextView.string! as NSString
            let nstopic = topic as NSString
            self.scrollToString(nstopic)
        }
        
    }
    
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        helpWindow.orderOut(self)
        return true
    }
    
}
