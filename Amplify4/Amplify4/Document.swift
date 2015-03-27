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
    
    @IBOutlet var infoTextView: NSTextView!
    @IBOutlet var mapClipView: NSClipView!
//    @IBOutlet var theMapView: MapView!
    @IBOutlet var mapScrollView: NSScrollView!
    @IBOutlet var mapBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var printMenuItem: NSMenuItem!
//    @IBOutlet weak var printOutputMenuItem: NSMenuItem!
    
 //   var mapImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 100, height: 10000))
//    var mapView = MapView()
    let settings = NSUserDefaults.standardUserDefaults()
    let apdel = NSApplication.sharedApplication().delegate! as AppDelegate
    var usedPrimers = [Primer]()
    var matches = [Match]()
    var dmatches = [Match]()
    var gmatches = [Match]()
    var dimers = [Dimer]()
    var fragments = [Fragment]()
    var output = NSMutableAttributedString()
    var targInt = [Int]()
    var circularTarget  : Bool = false
    var wwidth : CGFloat = 0.0
    let runWeights = NSUserDefaults.standardUserDefaults().arrayForKey(globals.runWeights)! as [Int]
    let pairScores = NSUserDefaults.standardUserDefaults().arrayForKey(globals.pairScores)! as [[Int]]
    let maxLength = NSUserDefaults.standardUserDefaults().integerForKey(globals.effectivePrimer)
    var opn = 100

    let theMapView = MapView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))

    
    override init() {
        super.init()
//        self.circularTarget = false
        // Add your subclass-specific initialization here.
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        let substrateDelegate = apdel.substrateDelegate
        if menuItem == substrateDelegate.printItem {
            menuItem.title = "Print PCR Map …"
        }
        if menuItem == substrateDelegate.printOutputMenuItem {
            menuItem.hidden = false
        }
        if menuItem == substrateDelegate.saveAsItem  {
            menuItem.title = "Save PCR Results As …"
        }
        if menuItem == substrateDelegate.saveItem {
            menuItem.title = "Save PCR Results"
        }
        return true
    }
    
    @IBAction func printOutputText(sender : AnyObject) {
        self.printInfo.horizontalPagination = NSPrintingPaginationMode.FitPagination
        printInfo.verticallyCentered = false
        let printOp = NSPrintOperation(view: outputTextView)
        printOp.runOperation()
    }
    
    override func printDocument(sender: AnyObject?) {
        let printInfo = self.printInfo
//        self.printInfo.verticalPagination = NSPrintingPaginationMode.FitPagination
        self.printInfo.horizontalPagination = NSPrintingPaginationMode.FitPagination
        printInfo.verticallyCentered = false

        let printOp = NSPrintOperation(view: theMapView)
        printOp.runOperation()
    }
    
    @IBAction func unDrawIt(sender: AnyObject) {
        let last = theMapView.plotters.last! as PlotterThing
        theMapView.setNeedsDisplayInRect(last.bounds)
        theMapView.plotters.removeLast()
        theMapView.display()
        
    }
    @IBAction func drawSomething(sender: AnyObject) {
        self.makePlot()
        theMapView.needsDisplay = true
        theMapView.display()
        return
    }
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "boundsDidChange:", name:  NSViewFrameDidChangeNotification, object: mapClipView)
        
        let substrateDelegate = apdel.substrateDelegate
        
        for primer in substrateDelegate.primers {
            if !primer.hasBadBases() && primer.check > 0 {
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
        
        // Find Matches and Dimers using parallel cores
        let opQ = NSOperationQueue()
        opQ.addOperation(DMatchOperation(maker: self))
        opQ.addOperation(GMatchOperation(maker: self))
        opQ.addOperation(FindPrimers(maker: self))
        opQ.waitUntilAllOperationsAreFinished()
        
        matches = dmatches + gmatches
        self.findFrags()
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
        
    // Show the map
        let clip = mapClipView.bounds
        let mapFrame = NSRect(origin: clip.origin, size: NSMakeSize(clip.size.width, 2000))
        theMapView.frame = mapFrame
        theMapView.theDoc = self
//        theMapView.theDoc = self
        mapScrollView.documentView = theMapView
        mapBottomConstraint.constant = -3000  // This constraint needs to be reset for some reason for initial drawing
        self.makePlot()
        theMapView.needsDisplay = true
        theMapView.display()

 }
    func findFrags () {
        for dmatch in dmatches {
            for gmatch in gmatches {
                if circularTarget {
                    fragments.append(Fragment(dmatch: dmatch, gmatch: gmatch))
                } else {
                    if gmatch.threePrime >= dmatch.threePrime {
                        fragments.append(Fragment(dmatch: dmatch, gmatch: gmatch))
                    }
                }
            }
        }
        fragments = sorted(fragments, {(f1 : Fragment, f2 : Fragment) -> Bool in
            return f1.quality < f2.quality
        })
    }
    
    func makePlot() {

        var plotters = [PlotterThing]()
        var trackingAreas = [NSTrackingArea]()

        // constants for the plot
        let targetLength = CGFloat(apdel.substrateDelegate.targetView.textStorage!.length - apdel.targDelegate.firstbase)
        let startBase = 1
        let endBase = Int(targetLength + 0.1)
        wwidth  = theMapView.frame.size.width
        let h1 : CGFloat = 15.0  // Horizional margin outside base numbers
        let v1 : CGFloat = 5.0  // vertical margin above base numbers
        let v2 : CGFloat = 30.0  // vertical space above top of base number tick
        let v3 : CGFloat = 70.0  // vertical space from top of big tick to target baseline
        let v4 : CGFloat = 17 // distance above or below target baseline for point of match arrow
        let v5 : CGFloat = 37 // distance above or below target baseline for match primer name
        let h3 : CGFloat = 16 // distance to the left or right of arrow point for match primer name
        let v6 : CGFloat = 50 // height of box containing G primer name
        let vfrag : CGFloat = 30 // vertical space for bar and size label
        let tickup : CGFloat = 5.0  // length of tick upward
        let tickdown : CGFloat = 5.0  // length of tick downward
        let tickwidth : CGFloat = 1.0  // linewidth for ticks
        let targwidth : CGFloat = 2.5  // linewidth for target baseline
        let bigtickFactor : CGFloat = 1.5  // relative size of ticks every 1000 pb
        let twidth = wwidth - 2.0 * h1 // graphic distance between first and last base
        let arrowLength : CGFloat = 5 // for circular fragments
        let arrowRise : CGFloat = 5  // for circular fragments

        let pointsPerBase : CGFloat = twidth/targetLength
        
        let clip = mapClipView.bounds
        let mapFrame = NSRect(origin: clip.origin, size: NSMakeSize(clip.size.width, v2 + v3 + v5 + v6 + vfrag * CGFloat(fragments.count)))
        theMapView.frame = mapFrame
        
        func basex(base : Int) -> CGFloat {
            // the X position of a base site
            return CGFloat(base) * twidth/targetLength + h1
        }
        // Write first and last base numbers
        plotters.append(StringThing(string: String(startBase), point: NSMakePoint(h1, v1), attr: fmat.bigger))
        let endString = String(endBase) as NSString
        let endStringRect = endString.boundingRectWithSize(NSSize(width: 1000, height: 1000), options: nil, attributes: fmat.bigger)
        let endStringWidth = endStringRect.size.width
        plotters.append(StringThing(string: endString, point: NSPoint(x: wwidth  - endStringWidth, y: v1), attr: fmat.bigger))
        
        // Make baseline for target
        var targLine = NSBezierPath()
        targLine.moveToPoint(NSPoint(x: h1, y: v2 + v3))
        targLine.lineToPoint(NSPoint(x: wwidth - h1, y: v2 + v3))
        targLine.lineWidth = targwidth
        plotters.append(BezThing(bez: targLine, point: NSPoint(x: 0, y: 0), fillColor: nil, strokeColor: NSColor.blackColor(), scale: 1))
        
        // Put in tick marks
        var tickPath = NSBezierPath()
        tickPath.moveToPoint(NSPoint(x: h1, y: v2))
        tickPath.lineToPoint(NSPoint(x: h1, y: v2+v3))
        tickPath.moveToPoint(NSPoint(x: wwidth - h1, y: v2+v3))
        tickPath.lineToPoint(NSPoint(x: wwidth - h1, y: v2))
        tickPath.lineWidth = tickwidth
        for var tickbase : Int = 100; tickbase < endBase; tickbase += 100 {
            let x = basex(tickbase)
            if tickbase % 1000 == 0 {
                tickPath.moveToPoint(NSPoint(x: x, y: v2 + v3 + tickdown * bigtickFactor))
                tickPath.lineToPoint(NSPoint(x: x, y: v2 + v3 - tickup * bigtickFactor))
            } else {
                tickPath.moveToPoint(NSPoint(x: x, y: v2 + v3 + tickdown))
                tickPath.lineToPoint(NSPoint(x: x, y: v2 + v3 - tickup))
            }
        }
        plotters.append(BezThing(bez: tickPath, point: NSPoint(x: 0, y: 0), fillColor: nil, strokeColor: NSColor.blackColor(), scale: 1))
        
        // Add match arrows and primer names
        for match in matches {
            var ypos = v2 + v3
            if match.isD {
                ypos -= v4
                plotters.append(VStringThing(string: match.primer.name, point: NSPoint(x: basex(match.threePrime) - h3, y: (v2 + v3 - v5)), attr: fmat.baseD))
            } else {
                ypos += v4
                let namebox = NSRect(x: basex(match.threePrime), y: v2 + v3 + v5, width: h3, height: v6)
                plotters.append(VStringRectThing(string: match.primer.name, rect: namebox, attr: fmat.baseG))
//                plotters.append(BezThing(bez: NSBezierPath(rect: namebox), point: NSPoint(x: 0, y: 0), fillColor: nil, strokeColor: NSColor.blackColor(), scale: 1))
            }
            let plotPoint = NSPoint(x: basex(match.threePrime), y: ypos)
            let bez = BezThing(bez: match.bez, point: plotPoint, fillColor: match.bezFillColor, strokeColor: match.bezStrokeColor, scale: 1)
            match.highlightPoint = plotPoint
            match.setLitBez(match.bez.copy() as NSBezierPath)
            plotters.append(bez)
            let trackArea = NSTrackingArea(rect: NSInsetRect(bez.bounds, -3, -3),
                options: (NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseMoved),
                owner: theMapView, userInfo: [0 : match])
            trackingAreas.append(trackArea)
        }
        
        // Add fragments
        var vpoint : CGFloat  = v2 + v3 + v5 + v6
        for frag in fragments {
            var barRect = frag.barRect  // NSRect is a value, so this doesn't change frag.barRect

            if frag.isCircular {
                let rec = (String(frag.totSize) as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: fmat.normal)
                let stringx : CGFloat = basex(Int(targetLength/2))  -  rec.size.width/2  // to center the size string
                plotters.append(StringThing(string: String(frag.totSize), point: NSPoint(x: stringx, y: vpoint + barRect.size.height), attr: fmat.normal))
                var bez = frag.bez.copy() as NSBezierPath // Get a copy of the two rectangles
                let stretch : NSAffineTransform = NSAffineTransform()
                stretch.scaleXBy(pointsPerBase, yBy: 1)
                bez.transformUsingAffineTransform(stretch)
                let plotPoint = NSPoint(x: basex(0), y: vpoint)
                plotters.append(BezThing(bez: bez, point: plotPoint, fillColor: NSColor.blackColor(), strokeColor: nil, scale: 1))

                // add left and right arrowheads
                let barWidth : CGFloat = barRect.size.height
                var rightArrow = NSBezierPath()
                rightArrow.moveToPoint(NSPoint(x: 0, y: 0))
                rightArrow.relativeLineToPoint(NSPoint(x: 0, y: barWidth/2 + arrowRise))
                rightArrow.relativeLineToPoint(NSPoint(x: arrowLength, y: -barWidth/2 - arrowRise))
                rightArrow.relativeLineToPoint(NSPoint(x: -arrowLength, y: -barWidth/2 - arrowRise))
                rightArrow.closePath()
                plotters.append(BezThing(bez: rightArrow, point: NSPoint(x: wwidth - h1, y: vpoint + barWidth/2), fillColor: NSColor.blackColor(), strokeColor: nil, scale: 1))
                var leftArrow = NSBezierPath()
                leftArrow.moveToPoint(NSPoint(x: 0, y: 0))
                leftArrow.relativeLineToPoint(NSPoint(x: 0, y: barWidth/2 + arrowRise))
                leftArrow.relativeLineToPoint(NSPoint(x: -arrowLength, y: -barWidth/2 - arrowRise))
                leftArrow.relativeLineToPoint(NSPoint(x: arrowLength, y: -barWidth/2 - arrowRise))
                leftArrow.closePath()
                plotters.append(BezThing(bez: leftArrow, point: NSPoint(x: h1, y: vpoint + barWidth/2), fillColor: NSColor.blackColor(), strokeColor: nil, scale: 1))
                
              } else {
                barRect.size.width *= pointsPerBase  // rescale length of bar
                let bez = NSBezierPath(rect: barRect)
                let plotPoint = NSPoint(x: basex(frag.dmatch.threePrime), y: vpoint)
                frag.highlightPoint = plotPoint
                frag.setLitRec(barRect)
                plotters.append(BezThing(bez: bez, point: plotPoint, fillColor: NSColor.blackColor(), strokeColor: nil, scale: 1))
                let rec = (String(frag.totSize) as NSString).boundingRectWithSize(NSMakeSize(1000, 1000), options: nil, attributes: fmat.normal)
                let stringx : CGFloat = basex(frag.dmatch.threePrime) + barRect.size.width/2  - rec.size.width/2  // to center the size string
                plotters.append(StringThing(string: String(frag.totSize), point: NSPoint(x: stringx, y: vpoint + barRect.size.height), attr: fmat.normal))

                let trackArea = NSTrackingArea(rect: NSInsetRect(NSRect(origin: plotPoint, size: bez.bounds.size), -2, -12),
                    options: (NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseMoved),
                    owner: theMapView, userInfo: [0 : frag])
                trackingAreas.append(trackArea)
            }

            vpoint += vfrag
        }
        
        theMapView.clearAllTrackingAreas()
        for tracker in trackingAreas {
            theMapView.addTrackingArea(tracker)
        }
        theMapView.plotters = plotters
    }
    
    func boundsDidChange (notification: NSNotification) {
        if mapClipView.bounds.size.width == wwidth {return}
            self.drawSomething(self)
    }
    
    func printOutput() {
        outputTextView.textStorage!.appendAttributedString(output)
        output = NSMutableAttributedString()
        outputTextView.scrollToEndOfDocument(self)
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
    
    func showAllFragments() {
        for frag in fragments {
            output.appendAttributedString(frag.report())
        }
        self.printOutput()
    }
    
    
    // THESE THREE FUNCTIONS HAVE NOW BEEN MOVED TO NSOPERATIONS
//    func findDmatches() {
//
//        for primer in usedPrimers {
//            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maxLength)).uppercaseString
//            let requiredPrimability = primer.Req.last
//            let requiredStability100 = primer.maxStab * settings.integerForKey(globals.stabilityCutoff)
//            var seqInt = [Int](count: countElements(seq), repeatedValue: 0)
//            let IUBString = globals.IUBString as NSString
//            var k = 0
//            for c in seq {
//                var n = IUBString.rangeOfString(String(c)).location
//                if n == NSNotFound {n = 14}
//                seqInt[k++] = n
//            }
//            // Now check for a match at each 3' (tp) site on the target
//            var primability = 0
//            var stability = 0
//            for tp in 0..<targInt.count {
//                var basePos = 0
//                var targPos = tp
//                primability = primer.zD[basePos++][targInt[targPos--]]
//                while (targPos >= 0) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) {
//                    primability += primer.zD[basePos++][targInt[targPos--]]
//                } // while ...
//                if primability >= requiredPrimability {
//                    // primability looks good. Now check for stability
//                    stability = 0
//                    var thisRun = 0
//                    var runCount = 0
//                    var targPos = tp
//                    for var basePos = seqInt.count - 1; basePos >= 0 && targPos >= 0;  --basePos  {
//                        // examine each base of the match
//                        let pairScore = pairScores[seqInt[basePos]][targInt[targPos]]
//                        if pairScore > 0 {
//                            // extend a run
//                            thisRun += pairScore
//                            runCount++
//                        } else {
//                            // finish a run
//                            stability += thisRun * runWeights[max(0, runCount - 1)]
//                            runCount = 0
//                            thisRun = 0
//                        }
//                        targPos--
//                    }
//                    stability += thisRun * runWeights[max(0, runCount - 1)] // In case it ended on a run
//                    if stability * 100 >= requiredStability100 {
//                        // Found a match!
//                        primability =  primability * 100 / primer.maxPrimability
//                        stability = stability * 100 / primer.maxStab
//                        let match = Match(primer: primer, isD: true, threePrime: tp, primability: primability, stability: stability)
//                        dmatches.append(match)
//                    }
//                }
//            } // for tp
//        } // for each primer used
//    }
//    
//    func findGmatches() {
//        
//        for primer in usedPrimers {
//            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maxLength)).uppercaseString
//            let requiredPrimability = primer.Req.last
//            let requiredStability100 = primer.maxStab * settings.integerForKey(globals.stabilityCutoff)
//            var seqInt = [Int](count: countElements(seq), repeatedValue: 0)
//            let compIUBString = globals.compIUBString as NSString
//            var k = 0
//            for c in seq {
//                var n = compIUBString.rangeOfString(String(c)).location
//                if n == NSNotFound {n = 14}
//                seqInt[k++] = n
//            }
//            // Now check for a match at each 3' (tp) site on the target
//            var primability = 0
//            var stability = 0
//            for tp in 0..<targInt.count {
//                var basePos = 0
//                var targPos = tp
//                primability = primer.zG[basePos++][targInt[targPos++]] // Different from D
//                while (targPos < targInt.count) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) { // Different from D
//                    primability += primer.zG[basePos++][targInt[targPos++]] // Different from D
//                } // while ...
//                if primability >= requiredPrimability {
//                    // primability looks good. Now check for stability
//                    stability = 0
//                    var thisRun = 0
//                    var runCount = 0
//                    targPos = tp
//                    for basePos = (seqInt.count - 1); basePos >= 0 && targPos < targInt.count;  --basePos  { // Different from D
//                        // examine each base of the match
//                        let pairScore = pairScores[seqInt[basePos]][targInt[targPos]] // Different from D
//                        if pairScore > 0 {
//                            // extend a run
//                            thisRun += pairScore
//                            runCount++
//                        } else {
//                            // finish a run
//                            stability += thisRun * runWeights[max(0, runCount - 1)]
//                            runCount = 0
//                            thisRun = 0
//                        }
//                        targPos++ // Different from D
//                    }
//                    stability += thisRun * runWeights[max(0, runCount - 1)] // In case it ended on a run
//                    if stability * 100 >= requiredStability100 {
//                        // Found a match!
//                        primability =  primability * 100 / primer.maxPrimability
//                        stability = stability * 100 / primer.maxStab
//                        let match = Match(primer: primer, isD: false, threePrime: tp, primability: primability, stability: stability) // Different from D
//                        gmatches.append(match)
//                    }
//                }
//            } // for tp
//        } // for each primer used
//    }
//    
//    func findDimers() {
//        let nprimers = usedPrimers.count
//        if nprimers < 1 {return}
//        for k1 in 0..<nprimers {
//            for k2 in 0...k1 {
//                let dimer = Dimer(primer: usedPrimers[k1], and: usedPrimers[k2])
//                if dimer.serious {
//                    dimers.append(dimer)
//                }
//            }
//        }
//    }

    @IBAction func writeSomething(sender: AnyObject) {
         self.showSeriousDimers()
    }
    
    @IBAction func roundButton(sender: AnyObject) {
        let pdfd = theMapView.dataWithPDFInsideRect(theMapView.bounds)
        var savePanel = NSSavePanel()
        savePanel.message = "Save target sequence as ..."
        savePanel.allowedFileTypes = ["pdf", "PDF"]
        if savePanel.runModal() == NSCancelButton {return}
        var mapURL = savePanel.URL! as NSURL
        pdfd.writeToURL(mapURL, atomically: true)
        
    }
    
    @IBOutlet var saveChoices: NSMatrix!
    override func saveDocumentAs(sender: AnyObject?) {
        let pdfd = theMapView.dataWithPDFInsideRect(theMapView.bounds)
        var savePanel = NSSavePanel()
        savePanel.extensionHidden = true
        savePanel.message = "Save PCR map or text output ..."
        savePanel.allowedFileTypes = ["pdf"]
        let k = saveChoices.selectedRow
        savePanel.accessoryView = saveChoices
        if savePanel.runModal() == NSCancelButton {return}
        if let saveURL : NSURL = savePanel.URL {
            switch saveChoices.selectedRow {
            case 0: // save map as pdf
                pdfd.writeToURL(saveURL, atomically: true)
            case 1: // save text output as rtf
                let rtfURL : NSURL = saveURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("rtf")
                let didit = outputTextView.RTFFromRange(NSMakeRange(0, (outputTextView.textStorage?.length)!))!.writeToURL(rtfURL, atomically: true)
            default: // save text output as txt
                let txtURL = saveURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("txt")
                let didit = (outputTextView.string! as NSString).writeToURL(txtURL, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
            }

        }
    }
    
    override func saveDocument(sender: AnyObject?) {
        self.saveDocumentAs(self)
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

