//
//  MatchOperation.swift
//  Amplify4
//
//  Created by Bill Engels on 3/10/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class DMatchOperation: NSOperation {
    let maker : Document
    let settings = NSUserDefaults.standardUserDefaults()
    
    init(maker : AnyObject) {
        self.maker = maker as Document
    }
    
    override func main() {
        var dmatches = [Match]()
        for primer in maker.usedPrimers {
            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maker.maxLength)).uppercaseString
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
            for tp in 0..<maker.targInt.count {
                var basePos = 0
                var targPos = tp
                primability = primer.zD[basePos++][maker.targInt[targPos--]]
                while (targPos >= 0) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) {
                    primability += primer.zD[basePos++][maker.targInt[targPos--]]
                } // while ...
                if primability >= requiredPrimability {
                    // primability looks good. Now check for stability
                    stability = 0
                    var thisRun = 0
                    var runCount = 0
                    var targPos = tp
                    for var basePos = seqInt.count - 1; basePos >= 0 && targPos >= 0;  --basePos  {
                        // examine each base of the match
                        let pairScore = maker.pairScores[seqInt[basePos]][maker.targInt[targPos]]
                        if pairScore > 0 {
                            // extend a run
                            thisRun += pairScore
                            runCount++
                        } else {
                            // finish a run
                            stability += thisRun * maker.runWeights[max(0, runCount - 1)]
                            runCount = 0
                            thisRun = 0
                        }
                        targPos--
                    }
                    stability += thisRun * maker.runWeights[max(0, runCount - 1)] // In case it ended on a run
                    if stability * 100 >= requiredStability100 {
                        // Found a match!
                        primability =  primability * 100 / primer.maxPrimability
                        stability = stability * 100 / primer.maxStab
                        let match = Match(primer: primer, isD: true, threePrime: tp, primability: primability, stability: stability)
                        dmatches.append(match)
                    }
                }
            } // for tp
        } // for each primer used
        maker.dmatches = dmatches
    }
}

class FindPrimers : NSOperation {
    let maker : Document
    init(maker : AnyObject) {
        self.maker = maker as Document
    }
    
    override func main() {
        let nprimers = maker.usedPrimers.count
        var dimers = [Dimer]()
        if nprimers < 1 {return}
        for k1 in 0..<nprimers {
            for k2 in 0...k1 {
                let dimer = Dimer(primer: maker.usedPrimers[k1], and: maker.usedPrimers[k2])
                if dimer.serious {
                    dimers.append(dimer)
                }
            } // for k2
        } // for k1
        maker.dimers = dimers
    } // main
}

class GMatchOperation: NSOperation {
    let maker : Document
    let settings = NSUserDefaults.standardUserDefaults()
    
    init(maker : AnyObject) {
        self.maker = maker as Document
    }
    
    override func main() {
        var gmatches = [Match]()
        for primer in maker.usedPrimers {
            let seq = (primer.seq as NSString).substringFromIndex(max(0, countElements(primer.seq) - maker.maxLength)).uppercaseString
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
            for tp in 0..<maker.targInt.count {
                var basePos = 0
                var targPos = tp
                primability = primer.zG[basePos++][maker.targInt[targPos++]] // Different from D
                while (targPos < maker.targInt.count) && (basePos < seqInt.count) && (primability >= primer.Req[basePos - 1]) { // Different from D
                    primability += primer.zG[basePos++][maker.targInt[targPos++]] // Different from D
                } // while ...
                if primability >= requiredPrimability {
                    // primability looks good. Now check for stability
                    stability = 0
                    var thisRun = 0
                    var runCount = 0
                    targPos = tp
                    for basePos = (seqInt.count - 1); basePos >= 0 && targPos < maker.targInt.count;  --basePos  { // Different from D
                        // examine each base of the match
                        let pairScore = maker.pairScores[seqInt[basePos]][maker.targInt[targPos]] // Different from D
                        if pairScore > 0 {
                            // extend a run
                            thisRun += pairScore
                            runCount++
                        } else {
                            // finish a run
                            stability += thisRun * maker.runWeights[max(0, runCount - 1)]
                            runCount = 0
                            thisRun = 0
                        }
                        targPos++ // Different from D
                    }
                    stability += thisRun * maker.runWeights[max(0, runCount - 1)] // In case it ended on a run
                    if stability * 100 >= requiredStability100 {
                        // Found a match!
                        primability =  primability * 100 / primer.maxPrimability
                        stability = stability * 100 / primer.maxStab
                        let match = Match(primer: primer, isD: false, threePrime: tp, primability: primability, stability: stability) // Different from D
                        gmatches.append(match)
                    }
                }
            } // for tp
        } // for each primer used
        maker.gmatches = gmatches
    }
}


