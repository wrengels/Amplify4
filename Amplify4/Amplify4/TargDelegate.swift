//
//  AMsubstrateDelegate.swift
//  Amplify4
//
//  Created by Bill Engels on 1/21/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa


class TargDelegate: NSObject {
    
    @IBOutlet weak var appdel: AppDelegate!
    @IBOutlet weak var substrateWindow: NSWindow!
    @IBOutlet weak var baseScroll: NSScrollView!
    @IBOutlet weak var baseClip: NSClipView!
    @IBOutlet var baseView: NSTextView!
    @IBOutlet var targetView: NSTextView!
    @IBOutlet weak var targetScroll: NSScrollView!
    @IBOutlet weak var targetClip: NSClipView!
    @IBOutlet weak var targetVScroller: NSScroller!
    @IBOutlet weak var targetDelegate: AMsubstrateDelegate!  // This variable should have been named "substrateDelagate" but XCode cannot refactor Swift!
    @IBOutlet weak var selectedBaseLabel: NSTextField!

    var settings = NSUserDefaults.standardUserDefaults()
    var targetNeedsCleaning = false
    var justOpened = 0
    var firstbase = 0
    
    override init() {
        super.init()
    }

    override func awakeFromNib() {
        targetScroll.contentView.postsBoundsChangedNotifications = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "boundsDidChange:", name: NSViewBoundsDidChangeNotification, object: targetScroll.contentView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "boundsDidChange:", name:  NSViewFrameDidChangeNotification, object: targetClip)
        settings = NSUserDefaults.standardUserDefaults();  // Just in case this needs to be done after nib awake
        targetDelegate.targetFontSize = settings.doubleForKey(globals.targetSize)
        targetDelegate.targetFont = settings.stringForKey(globals.targetFont)!
    }

    func saveDocumentAs(sender: AnyObject) -> AnyObject {
        let fid = (substrateWindow.firstResponder as! NSView).identifier! as String
        switch fid {
        case "primer Table View":
            targetDelegate.savePrimersAs(sender)
        case "target Text View" :
            targetDelegate.saveTargetStringAs(sender)
        default:
            let a = "Hello"
        }
        return self
    }

    func paste(sender : AnyObject) -> AnyObject {
        println("Pasted!")
        return self
    }
    
    @IBAction func doThing(sender: AnyObject) {

        
        
        
        let pr = targetDelegate.primers[0]
        pr.calcZ()
        let pdimer = Dimer(primer: pr, and: pr)
        println(pdimer.report())
            
        var tsettings = NSMutableDictionary();
        tsettings.setValue(
            [100,150,175,182,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186,186],
            forKey: "runWeights")
        tsettings.setValue(
            [266, 208, 129, 278, 220, 135, 240, 169, 129, 168, 173, 239, 240, 208, 215, 267, 173, 135, 266, 210, 173, 239, 169, 208, 215],
            forKey: "entropy")
        tsettings.setValue(
            [110, 78, 58, 119, 94, 56, 91, 60, 58, 81, 65, 86, 91, 78, 78, 111, 65, 56, 110, 105, 65, 86, 60, 78, 78] ,
            forKey: "enthalpy")
        tsettings.setValue(
            [30,20,10,10,9,9,8,7,6,5,5,4,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            forKey: "matchWeights")
        tsettings.setValue(
            [100, 0, 0, 0, 30, 0, 100, 0, 0, 30, 0, 0, 100, 0, 30, 0, 0, 0, 100, 30, 0, 70, 0, 70, 30, 70, 70, 0, 0, 30, 0, 70, 70, 0, 30, 70, 0, 0, 70, 30, 0, 0, 70, 70, 30, 70, 0, 70, 0, 30, 50, 50, 0, 50, 30, 0, 50, 50, 50, 30, 50, 50, 50, 0, 30, 50, 0, 50, 50, 30, 30, 30, 30, 30, 30],
            forKey: "dScores")
        tsettings.setValue(
            [-20,-20,-20,30,5,-20,-20,5,5,-20,-3,-3,-20,-3,-8,-20,-20,20,-20,-20,-20,0,-20,0,0,-20,-7,-7,-7,-10,-20,20,-20,-20,0,0,0,-20,-20,-20,-7,-7,-7,-20,-10,30,-20,-20,-20,-20,5,-20,5,-20,5,-3,-20,-3,-3,-8,5,-20,0,-20,-20,-8,-10,-8,-10,3,-12,-13,-5,-5,-9,-20,-20,0,5,-8,-20,-10,-8,3,-10,-12,-5,-13,-5,-9,-20,0,0,-20,-10,-10,0,-20,-10,-10,-13,-7,-7,-13,-10,5,-20,-20,5,-8,-8,-20,5,-8,-8,-3,-12,-12,-3,-8,5,0,-20,-20,-10,3,-10,-8,-20,-8,-5,-13,-5,-12,-9,-20,0,-20,5,3,-10,-10,-8,-8,-20,-5,-5,-13,-12,-9,-3,-20,-7,-3,-12,-12,-13,-3,-5,-5,-9,-10,-10,-4,-8,-3,-7,-7,-20,-13,-5,-7,-12,-13,-5,-10,-11,-6,-10,-9,-20,-7,-7,-3,-5,-13,-7,-12,-5,-13,-10,-6,-11,-10,-9,-3,-7,-20,-3,-5,-5,-13,-3,-12,-12,-4,-10,-10,-9,-8,-8,-10,-10,-8,-9,-9,-10,-8,-9,-9,-8,-9,-9,-8,-9],
            forKey: "dimerScores")
        tsettings.setValue(50,
            forKey: "saltConc")
        tsettings.setValue(50,
            forKey: "DNAConc")
        tsettings.setValue("Menlo",
            forKey: "targetFont")
        tsettings.setValue(12,
            forKey: "targetSize")
        tsettings.setValue(true,
            forKey: "linearDefault")
        tsettings.setValue(60,
            forKey: "dimerStringency")
        tsettings.setValue(3,
            forKey: "dimerOverlap")
        tsettings.setValue(80,
            forKey: "primabilityCutoff")
        tsettings.setValue(40,
            forKey: "stabilityCutoff")
        tsettings.setValue(30,
            forKey: "effectivePrimer")
        tsettings.setValue(3,
            forKey: "minOverlap")
        
        tsettings.setValue(make2D(tsettings.valueForKey("dScores") as! [Int], 5),
            forKey: "pairScores")
        let dimScores = make2D(tsettings.valueForKey("dimerScores") as! [Int], 15)
        tsettings.setValue(dimScores,
            forKey: "dimScores")
        tsettings.setValue(make2D(tsettings.valueForKey("entropy") as! [Int], 5),
            forKey: "entropy2")
        tsettings.setValue(make2D(tsettings.valueForKey("enthalpy") as! [Int], 5),
            forKey: "enthalpy2")

        let tsettingsURL = NSURL.fileURLWithPath( "/Users/WRE/DropBox/Amplify4/tsettings.plist")
//        let didit = tsettings.writeToURL(tsettingsURL!, atomically: true)
        let rtsettings = NSDictionary(contentsOfFile:  "/Users/WRE/DropBox/Amplify4/settings.plist")!
        let rw = rtsettings.valueForKey("runWeights")! as! [Int]
        let ps = tsettings.valueForKey("pairScores")! as! [[Int]]
        let ps11 = ps[1][1]
        let a = rw[4]
        let b = a + 2
  }
    
     func boundsDidChange (notification: NSNotification){
        if notification.name == NSViewBoundsDidChangeNotification {
            self.setBaseNumbers(self)
        }
        if notification.name ==  NSViewFrameDidChangeNotification {
            self.cleanupTarget()
            self.setBaseNumbers(self)
        }
    }

    
    func findNextChar(#string: NSString, charSet: NSCharacterSet, startingFrom: Int) -> Int {
        let op = NSStringCompareOptions(0)
        let slen = string.length
        if startingFrom >= slen {return NSNotFound}
        let result = string.rangeOfCharacterFromSet(charSet, options: op, range: NSMakeRange(startingFrom, slen - startingFrom)).location
        return result
    }

    @IBAction func clickBase(sender: AnyObject) {
        cleanupTarget()
    }
    
    func cleanupTarget() {
        if !targetNeedsCleaning {return}
        let endHeader = settings.stringForKey(globals.endHeader)!
        var targetString = targetView.string! as NSString
        let targetStorage = targetView.textStorage!
        firstbase = 0
        let ehrange = targetString.rangeOfString(endHeader)
        if ehrange.location != NSNotFound {
            // There is a header. It must be followed by a newline, so add one regardless of whether there is already one
            firstbase = ehrange.location + ehrange.length
            targetStorage.replaceCharactersInRange(NSMakeRange(firstbase, 0), withString: "\n")
            targetString = targetView.string! as NSString
            firstbase++
        }
        // Now delete all non-DNA bases (N is allowed) following header
        let ok = NSCharacterSet(charactersInString: "ACTGNactgn")
        let notok = ok.invertedSet
        var badbase = findNextChar(string: targetString, charSet: notok, startingFrom: firstbase)
        var goodbase = 0
        while badbase != NSNotFound {
            goodbase = findNextChar(string: targetString, charSet: ok, startingFrom: badbase)
            if goodbase == NSNotFound {goodbase = targetString.length}
            targetStorage.replaceCharactersInRange(NSMakeRange(badbase, goodbase - badbase), withString: "")
            targetString = targetView.string! as NSString
            badbase = findNextChar(string: targetString, charSet: notok, startingFrom: firstbase)
        }
        
        // Get rid of any oddball paragraph settings that might be in there
        var parStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        parStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        parStyle.lineSpacing = CGFloat(settings.floatForKey(globals.targetLineSpace))
        targetStorage.addAttribute(NSParagraphStyleAttributeName, value: parStyle, range: NSMakeRange(0,targetStorage.length))
        targetNeedsCleaning = false
        setBaseNumbers(self)
        return
    }
    
    func textViewDidChangeSelection(aNotification: NSNotification) {
       let srange = targetView.selectedRange()
        let sstart = srange.location - firstbase + 1
        let send = sstart + srange.length - 1
        if send >= sstart {
            selectedBaseLabel.stringValue = "Selected Bases: \(sstart) - \(send)"
        } else {
            selectedBaseLabel.stringValue = "Insertion Point After Base: \(sstart - 1)"
        }
    }
    
    func textDidEndEditing(aNotification: NSNotification) {
        self.cleanupTarget()
    }
    
    func textDidChange(aNotification: NSNotification) {
       targetNeedsCleaning = true
        targetDelegate.targetChanged = true
    }
    
    func selectBasesFrom(firstSelected : Int, lastSelected : Int) {
        let length2 = (self.targetView.textStorage!.length)
        let start = firstSelected + firstbase - 1
        let end = lastSelected + firstbase - 1
        if (start >= 0 && end < length2) {
            self.targetView.setSelectedRange(NSMakeRange(start, end - start + 1))
            substrateWindow.makeFirstResponder(targetView)
        } else {return}
    }
    
    @IBOutlet weak var baseRangeView: NSView!
    @IBOutlet weak var startBase: NSTextField!
    @IBOutlet weak var endBase: NSTextField!
    @IBAction func selectBaseRange(sender: AnyObject) {
        let selectBaseAlert = NSAlert()
        selectBaseAlert.addButtonWithTitle("Okay")
        selectBaseAlert.addButtonWithTitle("Cancel")
        selectBaseAlert.messageText = "Select Base Range:"
        selectBaseAlert.accessoryView = baseRangeView
        startBase.stringValue = ""
        endBase.stringValue = ""
        selectBaseAlert.beginSheetModalForWindow(substrateWindow, completionHandler: {code in
            if code == NSAlertFirstButtonReturn {
                let first = Int(self.startBase.integerValue + self.firstbase - 1)
                let last = Int(self.endBase.integerValue + self.firstbase - 1)
                let length2 = (self.targetView.textStorage!.length)
                if (first <= last) && (last < length2) && (last >= 0) {
                    self.targetView.setSelectedRange(NSMakeRange(first, last - first + 1))
                }
            }
        })
    }
    
    func plainCompliment(c : String) -> String {
        switch c {
            case "A": return "T"
            case "C": return "G"
            case "G": return "C"
            case "T": return "A"
            case "N": return "N"
            case "a": return "t"
            case "c": return "g"
            case "g": return "c"
            case "t": return "a"
            default: return "n"
        }
    }
    
    @IBAction func flipSelection(sender: AnyObject) {
        let opts : NSAttributedStringEnumerationOptions = .LongestEffectiveRangeNotRequired
        let srange = targetView.selectedRange()
        var flipt = NSMutableAttributedString(string: "")
        targetView.textStorage?.enumerateAttributesInRange(srange,
            options: opts,
            usingBlock: {
                (attrs : [NSObject : AnyObject]!,
                range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let s = (self.targetView.textStorage!.string as NSString).substringWithRange(range)
                var rs = ""
                for c in reverse(s) {
                    rs += self.plainCompliment(String(c))
                }
                // replace each character by its complement
                let ats = NSAttributedString(string: rs , attributes: attrs)
                flipt.replaceCharactersInRange(NSMakeRange(0, 0), withAttributedString: ats)
        })
        targetView.textStorage!.replaceCharactersInRange(srange, withAttributedString: flipt)
        targetView.setSelectedRange(srange)
    }

    @IBAction func setBaseNumbers(sender: AnyObject) {
        if justOpened < 2 {   /// Don't renumber bases if the application just opened. Getting settings will crash otherwise
            justOpened += 1
            return
        }
    
        let baseStorage = baseView.textStorage!
        let targStorage = targetView.textStorage!
        let targetString = targetView.string! as NSString
        if targetString.length < 1 {return}
        
        let ehrange = targetString.rangeOfString(settings.stringForKey(globals.endHeader)!)
        var effectiveRange = NSRange(location: 0,length: 0)
        let firstSeqLineRect = targetView.layoutManager!.lineFragmentRectForGlyphAtIndex(firstbase, effectiveRange: &effectiveRange)
        let charsPerLine = effectiveRange.length
        let nHeaderLines = Int(firstSeqLineRect.origin.y / firstSeqLineRect.height)
        let nSeqLines = Int((targetString.length - firstbase)/charsPerLine)
        if nSeqLines < 1 {return}
        
        // Build base count string
        var baseCountString = ""
        if nHeaderLines > 0 {
            for i in (1...nHeaderLines) {
                baseCountString += "-\n"
            }
        }
        baseCountString += "1\n"
        for i in 1...nSeqLines {
            baseCountString += "\(i * charsPerLine + 1)\n"
        }
        // Place baseCountString into NSTextView
        baseStorage.replaceCharactersInRange(NSMakeRange(0, baseStorage.length), withString: baseCountString)
        
        // Fix Scroll Position of base view
        let verticalOrigin = (targetView.visibleRect.origin.y)
        baseClip.scrollToPoint(NSMakePoint(0, verticalOrigin))
        baseScroll.reflectScrolledClipView(baseClip)
        
        // Adjust font and size
        var theFont = NSFont(name: "Menlo", size: 12)!
        if let maybeFont = NSFont(name: settings.stringForKey(globals.targetFont)!, size: CGFloat(settings.doubleForKey(globals.targetSize))) {
            theFont = maybeFont
        }
        baseView.setFont(theFont, range: NSMakeRange(0, (baseCountString as NSString).length))
        
        // Adjust line spacing
        var parStyle: NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
//        parStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        parStyle.lineSpacing = CGFloat(settings.floatForKey(globals.targetLineSpace))
        parStyle.alignment = NSTextAlignment.RightTextAlignment
        baseStorage.addAttribute(NSParagraphStyleAttributeName, value: parStyle, range: NSMakeRange(0,baseStorage.length))


       // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/CountLines.html
    }
    
    // http://stackoverflow.com/questions/5169355/callbacks-when-an-nsscrollview-is-scrolled
    
    
}
