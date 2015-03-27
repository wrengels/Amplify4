//
//  Match.swift
//  Amplify4
//
//  Created by Bill Engels on 3/2/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class Match: MapItem {
    let isD : Bool  // Does match point rightward?
    let threePrime : Int  // 3' end in target coordinates
    let primability, stability : Int
    let primer : Primer
    let bezFillColor, bezStrokeColor : NSColor
    let bez : NSBezierPath
    
    init(primer: Primer, isD : Bool, threePrime : Int, primability : Int, stability : Int) {
        self.primer = primer
        self.isD = isD
        self.threePrime = threePrime
        self.primability = primability
        self.stability = stability
        let hsize : CGFloat = 10
        let vsize : CGFloat = 14
        let linewidth : CGFloat = 1
        let minScale : CGFloat = 0.5
        let arrowAlpha : CGFloat = 0.7
        let colorLightness : CGFloat = 0.7
        bez = NSBezierPath()

        bez.moveToPoint(NSPoint(x:0,y:0))
        if isD {
            bezFillColor = NSColor(red: 0, green: 0, blue: colorLightness, alpha:arrowAlpha)
            bezStrokeColor = NSColor.blackColor()
        } else {
            bezFillColor = NSColor(red: colorLightness, green: 0, blue: 0, alpha: arrowAlpha)
            bezStrokeColor = NSColor.blackColor()
        }
        super.init()

        var qualityScale = NSAffineTransform()
        let scaleFactor = minScale + self.quality() * minScale
        qualityScale.scaleBy(CGFloat(scaleFactor))

        if isD {
            bez.lineToPoint(NSPoint(x: -hsize, y: -vsize))
            bez.lineToPoint(NSPoint(x: -hsize, y: vsize))
        } else {
            bez.lineToPoint(NSPoint(x: hsize, y: -vsize))
            bez.lineToPoint(NSPoint(x: hsize, y: vsize))
        }
        bez.closePath()
        bez.lineWidth = linewidth
        bez.lineJoinStyle = NSLineJoinStyle.RoundLineJoinStyle
        bez.transformUsingAffineTransform(qualityScale)
    }

    func quality() ->CGFloat {
        let settings = NSUserDefaults.standardUserDefaults()
        let cutoffSum = settings.integerForKey(globals.primabilityCutoff) + settings.integerForKey(globals.stabilityCutoff)
       return CGFloat(primability + stability - cutoffSum) / CGFloat(200 - cutoffSum)
    }
    
    func direction() -> String {
        if isD {return "⫸"} else {return "⫷"}
    }
    
    override func info() -> NSAttributedString {
        var info = NSMutableAttributedString()
        extendString(starter: info, suffix: "Match for primer:    ", attr: fmat.normal)
        var thefmat = fmat.bigboldred
        if isD {thefmat = fmat.bigboldblue}
        extendString(starter: info, suffix: "\(primer.name)   \(self.direction())", attr: thefmat)
        extendString(starter: info, suffix: "    3′ position = base \(threePrime + 1),    Primability = \(primability)%,    Stability = \(stability)%,    Quality = \(self.quality())", attr: fmat.normal)
        return info
    }
    
    override func report() -> NSAttributedString {
        let side = 20 // Show this number of target bases left and right of primer
        var report = NSMutableAttributedString()
        let settings = NSUserDefaults.standardUserDefaults()
        
        func addReport(s : String, attr: NSDictionary) {
            report.appendAttributedString(NSAttributedString(string: s, attributes: attr))
        }
        func spaces(k : Int) -> String {
            return String(count: k, repeatedValue: Character(" "))
        }
        func hbonds(targetString : String, primerString: String) -> String {
            // Produce a string of | or : or blank to indicate base-pairing
            let pairScores = NSUserDefaults.standardUserDefaults().arrayForKey(globals.pairScores) as [[Int]]
            let topScore = pairScores[0][0]
            let tchars = "GATCN" as NSString
            var pchars = globals.compIUBString as NSString
            if isD {
                pchars = globals.IUBString as NSString
            }
            var bonds = ""
            
            let n = countElements(targetString)
            if countElements(primerString) == n {
                // If strings are different sizes, then something is wrong
                let tbases = [Character](targetString.uppercaseString)
                let pbases = [Character](primerString.uppercaseString)
                var targIndex, primerIndex : Int
                for base in 0..<n {
                    targIndex = tchars.rangeOfString(String(tbases[base])).location
                    if targIndex == NSNotFound {targIndex = 4}
                    primerIndex = pchars.rangeOfString(String(pbases[base])).location
                    if primerIndex == NSNotFound {primerIndex = 14}
                    let pairScore = pairScores[primerIndex][targIndex]
                    if pairScore == 0{
                        bonds += " "
                    } else if pairScore >= topScore {
                        bonds += "|"
                    } else {
                        bonds += ":"
                    }
                }
            }
            return bonds
        }
        
        let effectivePrimer = settings.integerForKey(globals.effectivePrimer)
        var seq = primer.seq.uppercaseString as NSString
        if seq.length > effectivePrimer {
            seq = seq.substringFromIndex(seq.length - effectivePrimer)
            seq = "…" + seq
        }
        let seqLen = seq.length
        var contextRight = threePrime + side + 1
        var contextLeft = threePrime - seqLen - side + 1
        if !isD {
            contextRight = threePrime + seqLen + side
            contextLeft = threePrime - side
        }
        let apdel = NSApplication.sharedApplication().delegate! as AppDelegate
        let targFileString = apdel.substrateDelegate.targetView.textStorage!.string as NSString
        let firstbase = apdel.targDelegate.firstbase as Int
        let targString = targFileString.substringFromIndex(firstbase).uppercaseString as NSString
        var context = NSMutableString(string: "")
        if contextLeft < 0 {
            var newContext = context.stringByPaddingToLength(-contextLeft, withString: " ", startingAtIndex: 0)
            context = NSMutableString(string: newContext)
            contextLeft = 0
        }
        if contextRight > targString.length {
            contextRight = targString.length
        }
        let padding = spaces(side - 3)
        context = NSMutableString(string: context + targString.substringWithRange(NSMakeRange(contextLeft, contextRight - contextLeft)))
        let matchingTarget = context.substringWithRange(NSMakeRange(side, min(seqLen, context.length - side)))
        var bonds = hbonds(matchingTarget, seq)
        var paddedPrimer = NSMutableAttributedString()
        addReport("\r", fmat.hline1)
        addReport("Match for primer: \(primer.name)  \(self.direction())\r", fmat.h3)
        addReport("\rPrimability = \(primability)%    Stability = \(stability)%,    Quality = \(self.quality()) \r\r", fmat.normal)

        
        if isD {
            let startNumString = String(threePrime - seqLen + 2)
            let startDigits = countElements(startNumString)
            let endNumString = String(threePrime + 1)
            let endDigits = countElements(endNumString)
            var numline = "\t\(spaces(side - startDigits/2))\(startNumString)"
            numline += spaces(seqLen - startDigits/2 - endDigits/2 - 1) + endNumString
            addReport(numline, fmat.blueseq)
            extendString(starter: report, suffix1: "\r\t\(spaces(side))", attr1: fmat.seq, suffix2: "↓", attr2: fmat.symb)
            extendString(starter: report, suffix1: spaces(seqLen - 2), attr1: fmat.seq, suffix2:  "↓", attr2: fmat.symb)
            paddedPrimer = NSMutableAttributedString(string: "\r\(primer.name)", attributes : fmat.blue)
            extendString(starter: paddedPrimer, suffix: "\t" + padding + "5′ " , attr: fmat.blueseq )
            extendString(starter: paddedPrimer, suffix1: seq, attr1: fmat.seq, suffix2: " 3′ \r", attr2: fmat.blueseq)
            report.appendAttributedString(paddedPrimer)
            extendString(starter: report, suffix: "\t\(spaces(side))\(bonds)\r", attr: fmat.greyseq)
            addReport("Context\t", fmat.blue)
            addReport(context + "\r\r" , fmat.seq)
            apdel.targDelegate.selectBasesFrom(threePrime - seqLen + 2, lastSelected: threePrime + 1)

        } else {
            let reverseSeq = (String(reverse(String(seq))) as NSString)
            paddedPrimer = NSMutableAttributedString(string: padding + "3′ " , attributes: fmat.blueseq)
            extendString(starter: paddedPrimer, suffix1: reverseSeq, attr1: fmat.seq, suffix2: " 5′ ", attr2: fmat.blueseq)
            bonds = hbonds(matchingTarget, reverseSeq)
            addReport("Context\t", fmat.blue)
            addReport(context + "\r" , fmat.seq)
            extendString(starter: report, suffix: "\t\(spaces(side))\(bonds)\r", attr: fmat.greyseq)
            addReport(primer.name + "\t", fmat.blue)
            report.appendAttributedString(paddedPrimer)
            extendString(starter: report, suffix1: "\r\t\(spaces(side))", attr1: fmat.seq, suffix2: "↑", attr2: fmat.symb)
            extendString(starter: report, suffix1: spaces(seqLen - 2), attr1: fmat.seq, suffix2:  "↑", attr2: fmat.symb)
            addReport("\r", fmat.seq)
            let startNumString = String(threePrime + 1)
            let startDigits = countElements(startNumString)
            let endNumString = String(threePrime + seqLen)
            let endDigits = countElements(endNumString)
            var numline = "\t\(spaces(side - startDigits/2))\(startNumString)"
            numline += spaces(seqLen - startDigits/2 - endDigits/2 - 1) + endNumString
            addReport(numline + "\r\r", fmat.blueseq)
            apdel.targDelegate.selectBasesFrom(threePrime + 1, lastSelected: threePrime + seqLen)
        }
        return report
    }
    

}
