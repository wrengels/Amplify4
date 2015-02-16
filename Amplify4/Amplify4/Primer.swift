//
//  Primer.swift
//  Amplify4
//
//  Created by Bill Engels on 1/19/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class Primer : NSObject {
    var seq = ""
    var name = ""
    var note = ""
    var check = 0
    
    var maxStab : Int = 0
    var maxPrimability : Int = 0
    var isDegenerate = false
    var Req = [Int]()
    var line : String {
        get {
            return "\(seq)\t\(name)\t\(note)"
        }
    }
    var zD = [[Int]]()
    var zG = [[Int]]()
    var ideal  = [Int]()
    
    override init() {
        super.init()
    }
    
    init(theLine: String) {
        var  parts = (theLine as String).componentsSeparatedByString("\t")
        while parts.count < 3 {parts.append("")} // make sure there are at least 3
        seq = parts[0]
        name = parts[1]
        note = parts[2]
    }
    
    func hasBadBases()->Bool {
        let okayChars = NSCharacterSet(charactersInString: globals.IUBString)
        let badChars = okayChars.invertedSet
        let firstBad = (seq.uppercaseString as NSString).rangeOfCharacterFromSet(badChars).location
        return (firstBad != NSNotFound)
    }
    
    func calcTm() -> Double {
        var entr = 108.0
        var enth = 0.0
        let seqChar = [Character](seq.uppercaseString)
        let settings = NSUserDefaults.standardUserDefaults()
        let entropy = settings.arrayForKey(globals.entropy) as [[Double]]
        let enthalpy = settings.arrayForKey(globals.enthalpy) as [[Double]]
        let saltConc : Double = settings.doubleForKey(globals.saltConc)
        let DNAConc : Double = settings.doubleForKey(globals.DNAConc)
        let n = min(settings.integerForKey(globals.effectivePrimer), seqChar.count)
        var seqn = [Int]()
        for c in seqChar {
            switch c {
            case "G" : seqn.append(0)
            case "A" : seqn.append(1)
            case "T" : seqn.append(2)
            case "C" : seqn.append(3)
            default : seqn.append(4)
            }
        }
        for primerLocation in 0..<(n - 1) {
            let x = seqn[primerLocation]
            let y = seqn[primerLocation + 1]
            entr += entropy[y][x]
            enth += enthalpy[y][x]
        }
        entr = -entr * 0.1
        enth = -enth * 0.1
        let logdna = 1.987 * log(DNAConc/4e9)
        let logsalt = 16.6 * log(saltConc/1000) / log(10.0)
        return (enth * 1000) / (entr + logdna) - 273.15 + logsalt
    }
    
    func calcZ() -> Bool {
        if self.hasBadBases() {return false}
        let dbases = [Character](globals.IUBString)
        let cbases = [Character](globals.compIUBString)
        let settings = NSUserDefaults.standardUserDefaults()
        let matchWeights = settings.arrayForKey(globals.matchWeights)! as [Int]
        let pairScores = settings.arrayForKey(globals.pairScores)! as [[Int]]
        let seqChar = [Character](seq.uppercaseString)
        var seqd = [Int]()
        var seqc = [Int]()
        let n = min(settings.integerForKey(globals.effectivePrimer), seqChar.count)
            // n is the number of bases in the primer (or the max effectdive)
        for c in seq.uppercaseString {
            var v = 0
            while c != dbases[v] {v += 1}
            seqd.append(v)
            v = 0
            while c != cbases[v] {v += 1}
            seqc.append(v)
        }
        // Now seqd and seqc contain the numerical codes of this primer's bases and complements, respectively
        maxStab = 0
        for primerLocation in 0..<n {
            var zrow = [Int]()
            for targetBase in 0...4 {
                zrow.append(matchWeights[primerLocation] * pairScores[seqd[n - 1 - primerLocation]][targetBase])
            } // for targetBase
            zD.append(zrow)
            zG.append([zrow[3], zrow[2], zrow[1], zrow[0], zrow[4]])
            ideal.append(max(zrow[0], zrow[1], zrow[2], zrow[3], zrow[4]))
            maxPrimability += ideal[primerLocation]
            let possibleScores = pairScores[seqd[primerLocation]]
            maxStab += possibleScores.reduce(Int.min, combine: max) // 'reduce' used to find the maximum integer in an array
        } // for primerLocation
        maxStab *= (settings.arrayForKey(globals.runWeights)! as [Int])[n-1]
//        let minPrimability : Int = maxPrimability * settings.integerForKey(globals.primabilityCutoff)/100
        Req.append(ideal[0] - maxPrimability * (100 - settings.integerForKey(globals.primabilityCutoff))/100)
        for i in 1..<n {
        Req.append(ideal[i] + Req[i - 1])
        }
        let Tm = calcTm()
        return true
    }
}
