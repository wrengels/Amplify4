//
//  Document.swift
//  Amplify4
//
//  Created by Bill Engels on 1/15/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class DocumentCircular : Document {
    override init() {
        super.init()
        self.circularTarget = true
    }

}

class Document: NSDocument {
    @IBOutlet weak var dimerButton: NSButton!
    @IBOutlet var ampWindow: NSWindow!
    @IBOutlet var outputTextView: NSTextView!
    
    @IBOutlet var mapScrollView: NSScrollView!
    
    var mapImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 100, height: 10000))
    var mapView = MapView()
    let settings = NSUserDefaults.standardUserDefaults()
    let apdel = NSApplication.sharedApplication().delegate! as AppDelegate
    var usedPrimers = [Primer]()
    var matches = [Match]()
    var dimers = [Dimer]()
    var fragments = [Fragment]()
    var output = NSMutableAttributedString()
    var targInt = [Int]()
    var circularTarget  : Bool = false
    
    override init() {
        super.init()
//        self.circularTarget = false
        // Add your subclass-specific initialization here.
    }
    
    @IBAction func unDrawIt(sender: AnyObject) {
        let last = mapView.plotters.last! as PlotterThing
        mapView.setNeedsDisplayInRect(last.bounds)
        mapView.plotters.removeLast()
        mapView.display()
        
    }
    @IBAction func drawSomething(sender: AnyObject) {
        
        let something = StringThing(string: "This Here is Something", point: NSPoint(x: 30, y: 30))
        mapView.plotters.append(something)
        mapView.setNeedsDisplayInRect(something.bounds)
        mapView.display()
        
        return
        
        let framesize = mapImageView.frame.size
        let theImage = NSImage(size: framesize)
        
        func markpoint (x : Int, y : Int) {
            let pt = NSPoint(x: x, y: y)
            ("\(pt)" as NSString).drawAtPoint(pt, withAttributes: fmat.normal)
        }
        
        theImage.lockFocusFlipped(true)
        let s = "Hello World" as NSString
        s.drawAtPoint(NSPoint(x: 70, y: 100), withAttributes: fmat.red)
        s.drawAtPoint(NSPoint(x: 500, y: 200), withAttributes: fmat.bigbold)
        markpoint(800, 300)
        var tran = NSAffineTransform()
        tran.rotateByDegrees(-90)
        tran.concat()
        markpoint(-300, 800)
        s.drawAtPoint(NSPoint(x: -100, y: 70), withAttributes: fmat.blue)
        s.drawAtPoint(NSPoint(x: -100, y: 100), withAttributes: nil)
        s.drawAtPoint(NSPoint(x: -100, y: 200), withAttributes: nil)
        s.drawAtPoint(NSPoint(x: 100, y: -220), withAttributes: nil)
        s.drawAtPoint(NSPoint(x: 100, y: -500), withAttributes: nil)
        tran.invert()
        tran.concat()
        ("Are we back to normal?" as NSString).drawAtPoint(NSPoint(x: 50, y: 50), withAttributes: fmat.big)
        markpoint(200, 150)
        markpoint(500, 170)
        
        tran = NSAffineTransform()
        tran.translateXBy(500, yBy: 170)
        tran.rotateByDegrees(-90)
        tran.concat()
        ("Is this string upright?" as NSString).drawAtPoint(NSMakePoint(0, 0), withAttributes: fmat.bigbold)
        tran.invert()
        tran.concat()
        
        let vstringThing = VStringThing(string: "Upright String", point: NSPoint(x: 700, y: 400), attr: fmat.bigbold)
        let stringThing = StringThing(string: "This is a string thing", point: NSPoint(x: 700, y: 400), attr: fmat.blue)
        let plainThing = StringThing(string: "Plain old", point: NSPoint(x: 700, y: 450))
        var ara = [PlotterThing]()
        
        ara += [stringThing, plainThing, vstringThing]
        
        var garrow = NSBezierPath()
        garrow.moveToPoint(NSMakePoint(0, 0))
        garrow.lineToPoint(NSMakePoint(10, 10))
        garrow.lineToPoint(NSMakePoint(10, -10))
        garrow.closePath()
        let gthing = BezThing(bez: garrow , point: NSMakePoint(700, 500), fillColor: NSColor.redColor(), strokeColor: NSColor.blackColor(), scale : 1)
        let gblue = BezThing(bez: garrow, point: NSMakePoint(730, 500), fillColor: NSColor.blueColor(), strokeColor: NSColor.blackColor(), scale : 1)
        ara += [gthing, gblue]
        let darrow = NSBezierPath()
        darrow.moveToPoint(NSMakePoint(0, 0))
        darrow.lineToPoint(NSMakePoint(-10, 10))
        darrow.lineToPoint(NSMakePoint(-10, -10))
        darrow.closePath()
        let gfat = BezThing(bez: darrow, point: NSMakePoint(780, 500), fillColor: NSColor.whiteColor(), strokeColor: NSColor.blackColor(), scale : 1)
        ara.append(gfat)
        darrow.lineJoinStyle = NSLineJoinStyle.RoundLineJoinStyle
        darrow.miterLimit = 80
        darrow.lineWidth = 6
        let gmfat = BezThing(bez: darrow, point: NSMakePoint(810, 500), fillColor: NSColor.whiteColor(), strokeColor: NSColor.blackColor(), scale : 2)
        
        darrow.lineWidth = 0.4
        let gthin = BezThing(bez: darrow, point: NSMakePoint(830, 500), fillColor: NSColor.yellowColor(), strokeColor: NSColor.blackColor(), scale : 2)
       
        ara +=  [gthin, gmfat]
        let arat = ArrayThing(ara: ara)
        
        ArrayThing(ara: ara).plot()
        
        for thing in ara {
            let rec = thing.bounds
            NSBezierPath(rect: rec).stroke()
            
        }
        
        tran = NSAffineTransform()
        tran.translateXBy(-250, yBy: 30)
        tran.concat()
        ArrayThing(ara: ara).plot()
        
        tran = NSAffineTransform()
        tran.scaleBy(0.5)
        tran.translateXBy(0, yBy: -100)
        tran.concat()
        ArrayThing(ara: ara).plot()

        theImage.unlockFocus()
    
        mapImageView.image = theImage
        
        // this method makes only bitmapped image. So, is offscreenview needed?
        let clip = NSPasteboard.generalPasteboard()
         clip.declareTypes([NSPDFPboardType], owner: nil)
        let thepdfdata = mapImageView.dataWithPDFInsideRect(mapImageView.bounds)
        clip.setData(thepdfdata, forType: NSPDFPboardType)
        
    }
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        
        let substrateDelegate = apdel.substrateDelegate
        for primer in substrateDelegate.primers {
            if primer.check > 0 {
                primer.calcTm()
                primer.calcZ()
                usedPrimers.append(primer)
            }
        }
//        mapImageView.setFrameSize(NSSize(width: mapScrollView.documentVisibleRect.width, height: 2000))
//        mapScrollView.documentView = mapImageView
        
        // Convert target string to integers in targInt array
        let targFileString = apdel.substrateDelegate.targetView.textStorage!.string as NSString
        let firstbase = apdel.targDelegate.firstbase as Int
        let targString = targFileString.substringFromIndex(firstbase).uppercaseString
        targInt = [Int](count: countElements(targString), repeatedValue: 0)
        var k = 0
        for c in targString {
            switch c {
            case "G" : targInt[k] = 0
            case "A" : targInt[k] = 1
            case "T" : targInt[k] = 2
            case "C" : targInt[k] = 3
            default : targInt[k] = 4
            }
            k++
        }
        
        // Find Matches
        self.findDmatches()
        self.findGmatches()
        self.findDimers()
        dimerButton.enabled = dimers.count > 0
        dimerButton.title = "Primer Dimers (\(dimers.count))"
        
        // Put up header
        let targname = apdel.substrateDelegate.substrateWindow.title!
        var primerNames = ""
        for primer in usedPrimers {
            primerNames += primer.name
            if primer != usedPrimers.last {
                primerNames += ", "
            }
        }
        var shape = "linear"
        if circularTarget {shape = "circular"}
        extendString(starter: output, suffix1: "\rAmplification of \(shape) ", attr1: fmat.h0, suffix2: targname, attr2: fmat.h0ital)
        extendString(starter: output, suffix1: " with primers: ", attr1: fmat.h0 , suffix2: primerNames, attr2: fmat.h0ital)
        extendString(starter: output, suffix1: "\r\r ", attr1: fmat.bigcenter, suffix2: "Amplify ", attr2: fmat.bigital)
        extendString(starter: output, suffix1: "found \(matches.count) primer matches and \(fragments.count) potential amplicons.  PCR simulation performed \(timeStamp())\r\r", attr1: fmat.bigcenter, suffix2: "\r", attr2: fmat.hlineblue)
        self.printOutput()
        
        // Put some dummy plots into plotters
        var plotters = [PlotterThing]()

        let vstringThing = VStringThing(string: "Upright String", point: NSPoint(x: 700, y: 400), attr: fmat.bigbold)
        let stringThing = StringThing(string: "This is a string thing", point: NSPoint(x: 700, y: 400), attr: fmat.blue)
        let plainThing = StringThing(string: "Plain old", point: NSPoint(x: 700, y: 450))
        var garrow = NSBezierPath()
        garrow.moveToPoint(NSMakePoint(0, 0))
        garrow.lineToPoint(NSMakePoint(10, 10))
        garrow.lineToPoint(NSMakePoint(10, -10))
        garrow.closePath()
        let gthing = BezThing(bez: garrow , point: NSMakePoint(700, 500), fillColor: NSColor.redColor(), strokeColor: NSColor.blackColor(), scale : 1)
        let gblue = BezThing(bez: garrow, point: NSMakePoint(730, 500), fillColor: NSColor.blueColor(), strokeColor: NSColor.blackColor(), scale : 1)
        plotters += [gthing, gblue]
        let darrow = NSBezierPath()
        darrow.moveToPoint(NSMakePoint(0, 0))
        darrow.lineToPoint(NSMakePoint(-10, 10))
        darrow.lineToPoint(NSMakePoint(-10, -10))
        darrow.closePath()
        let gfat = BezThing(bez: darrow, point: NSMakePoint(780, 500), fillColor: NSColor.whiteColor(), strokeColor: NSColor.blackColor(), scale : 1)
        darrow.lineJoinStyle = NSLineJoinStyle.RoundLineJoinStyle
        darrow.miterLimit = 80
        darrow.lineWidth = 6
        let gmfat = BezThing(bez: darrow, point: NSMakePoint(810, 500), fillColor: NSColor.whiteColor(), strokeColor: NSColor.blackColor(), scale : 2)
        
        darrow.lineWidth = 0.4
        let gthin = BezThing(bez: darrow, point: NSMakePoint(830, 500), fillColor: NSColor.yellowColor(), strokeColor: NSColor.blackColor(), scale : 2)
        
        plotters += [gthing, gblue]
        plotters.append(gfat)
        plotters += [vstringThing, stringThing, plainThing]
        plotters +=  [gthin, gmfat]
        
        // Set up the view
        mapView.setFrameOrigin(NSPoint(x: 0, y: 0))
        mapView.setFrameSize((NSSize(width: mapScrollView.documentVisibleRect.width, height: 2000)))
        mapView.plotters = plotters
        mapScrollView.documentView = mapView
        

}
    
    func printOutput() {
        outputTextView.textStorage!.appendAttributedString(output)
        output = NSMutableAttributedString()
    }
    
    func addOutput(s : String, attr: NSDictionary) {
        output.appendAttributedString(NSAttributedString(string: s , attributes: attr))
    }
    

    override class func autosavesInPlace() -> Bool {
        return false
    }
    
    func showSeriousDimers() {
        let nprimers = usedPrimers.count
        if nprimers < 1 {return}
        addOutput("\rPotential Primer Dimers\r\r", attr: fmat.h1)
        for k1 in 0..<nprimers {
            for k2 in 0...k1 {
                let dimer = Dimer(primer: usedPrimers[k1], and: usedPrimers[k2])
                if dimer.serious {
                    output.appendAttributedString(dimer.freport())
                }
            }
        }
        self.printOutput()
    }
    
    func showAllMatches() {
        for match in matches {
            output.appendAttributedString(match.report())
        }
        self.printOutput()
    }
    
    func findDmatches() {
        let runWeights = settings.arrayForKey(globals.runWeights)! as [Int]
        let pairScores = settings.arrayForKey(globals.pairScores)! as [[Int]]
        let maxLength = settings.integerForKey(globals.effectivePrimer)

        for primer in usedPrimers {
            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maxLength)).uppercaseString
            let requiredPrimability = primer.Req.last
            let requiredStability100 = primer.maxStab * settings.integerForKey(globals.stabilityCutoff)
            var seqInt = [Int](count: countElements(seq), repeatedValue: 0)
            let IUBString = globals.IUBString as NSString
            var k = 0
            for c in seq {
                var n = IUBString.rangeOfString(String(c)).location
                if n == NSNotFound {n = 14}
                seqInt[k++] = n
            }
            // Now check for a match at each 3' (tp) site on the target
            var primability = 0
            var stability = 0
            for tp in 0..<targInt.count {
                var basePos = 0
                var targPos = tp
                primability = primer.zD[basePos++][targInt[targPos--]]
                while (targPos >= 0) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) {
                    primability += primer.zD[basePos++][targInt[targPos--]]
                } // while ...
                if primability >= requiredPrimability {
                    // primability looks good. Now check for stability
                    stability = 0
                    var thisRun = 0
                    var runCount = 0
                    var targPos = tp
                    for var basePos = seqInt.count - 1; basePos >= 0 && targPos >= 0;  --basePos  {
                        // examine each base of the match
                        let pairScore = pairScores[seqInt[basePos]][targInt[targPos]]
                        if pairScore > 0 {
                            // extend a run
                            thisRun += pairScore
                            runCount++
                        } else {
                            // finish a run
                            stability += thisRun * runWeights[max(0, runCount - 1)]
                            runCount = 0
                            thisRun = 0
                        }
                        targPos--
                    }
                    stability += thisRun * runWeights[max(0, runCount - 1)] // In case it ended on a run
                    if stability * 100 >= requiredStability100 {
                        // Found a match!
                        primability =  primability * 100 / primer.maxPrimability
                        stability = stability * 100 / primer.maxStab
                        let match = Match(primer: primer, isD: true, threePrime: tp, primability: primability, stability: stability)
                        matches.append(match)
                    }
                }
            } // for tp
        } // for each primer used
    }
    
    func findGmatches() {
        let runWeights = settings.arrayForKey(globals.runWeights)! as [Int]
        let pairScores = settings.arrayForKey(globals.pairScores)! as [[Int]]
        let maxLength = settings.integerForKey(globals.effectivePrimer)
        
        for primer in usedPrimers {
            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maxLength)).uppercaseString
            let requiredPrimability = primer.Req.last
            let requiredStability100 = primer.maxStab * settings.integerForKey(globals.stabilityCutoff)
            var seqInt = [Int](count: countElements(seq), repeatedValue: 0)
            let compIUBString = globals.compIUBString as NSString
            var k = 0
            for c in seq {
                var n = compIUBString.rangeOfString(String(c)).location
                if n == NSNotFound {n = 14}
                seqInt[k++] = n
            }
            // Now check for a match at each 3' (tp) site on the target
            var primability = 0
            var stability = 0
            for tp in 0..<targInt.count {
                var basePos = 0
                var targPos = tp
                primability = primer.zG[basePos++][targInt[targPos++]] // Different from D
                while (targPos < targInt.count) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) { // Different from D
                    primability += primer.zG[basePos++][targInt[targPos++]] // Different from D
                } // while ...
                if primability >= requiredPrimability {
                    // primability looks good. Now check for stability
                    stability = 0
                    var thisRun = 0
                    var runCount = 0
                    targPos = tp
                    for basePos = (seqInt.count - 1); basePos >= 0 && targPos < targInt.count;  --basePos  { // Different from D
                        // examine each base of the match
                        let pairScore = pairScores[seqInt[basePos]][targInt[targPos]] // Different from D
                        if pairScore > 0 {
                            // extend a run
                            thisRun += pairScore
                            runCount++
                        } else {
                            // finish a run
                            stability += thisRun * runWeights[max(0, runCount - 1)]
                            runCount = 0
                            thisRun = 0
                        }
                        targPos++ // Different from D
                    }
                    stability += thisRun * runWeights[max(0, runCount - 1)] // In case it ended on a run
                    if stability * 100 >= requiredStability100 {
                        // Found a match!
                        primability =  primability * 100 / primer.maxPrimability
                        stability = stability * 100 / primer.maxStab
                        let match = Match(primer: primer, isD: false, threePrime: tp, primability: primability, stability: stability) // Different from D
                        matches.append(match)
                    }
                }
            } // for tp
        } // for each primer used
    }
    
    func findDimers() {
        let nprimers = usedPrimers.count
        if nprimers < 1 {return}
        for k1 in 0..<nprimers {
            for k2 in 0...k1 {
                let dimer = Dimer(primer: usedPrimers[k1], and: usedPrimers[k2])
                if dimer.serious {
                    dimers.append(dimer)
                }
            }
        }
    }

    @IBAction func writeSomething(sender: AnyObject) {
        self.showAllMatches()
        self.showSeriousDimers()
    }
    
    
    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return nil
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        if (typeName == "PrimerList") {
            return true
        }
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return false
    }
}

