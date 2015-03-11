//
//  Primer.swift
//  Amplify4
//
//  Created by Bill Engels on 1/19/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Cocoa

class Primer : NSObject {
    var seq : String = ""
    var name : String = ""
    var note : String = ""
    var redundancyFold = 1
    var redundantBases = 0
    var check = 0
    var nBases = 0
    var nAT = 0
    var nGC = 0
    let maxNameLength = 10
    
    var maxStab : Int = 0
    var maxPrimability : Int = 0
    var isDegenerate = false
    var line : String {
        get {
            return "\(seq)\t\(name)\t\(note)"
        }
    }
    var csvline : String {
        get {
            return "\(seq),\(name),\(note)"
        }
    }
    
    var nameFirstLine: String {
        get {
            return "\(name),\(seq),\(note)"
        }
    }

    var zD = [[Int]]()
    var zG = [[Int]]()
    var ideal  = [Int]()
    var Req = [Int]()

    override init() {
        super.init()
    }
    
    init(theLine: String) {
        var  parts = (theLine as String).componentsSeparatedByString("\t")
        while parts.count < 3 {parts.append("")} // make sure there are at least 3
        seq = parts[0]
        name = parts[1]
        note = parts[2]
        // truncate the name if it's too long
        if countElements(name) > maxNameLength {
            name = String((name as NSString).substringWithRange(NSMakeRange(0, maxNameLength)))
        }
    }
    
    init(theCSVLine : String) {
        var  parts = (theCSVLine as String).componentsSeparatedByString(",")
        while parts.count < 3 {parts.append("")} // make sure there are at least 3
        seq = parts[0]
        name = parts[1]
        note = parts[2]
        if countElements(name) > maxNameLength {
            name = String((name as NSString).substringWithRange(NSMakeRange(0, maxNameLength)))
        }
    }
    
    func hasBadBases()->Bool {
        if countElements(seq) < 1 {return true}
        let okayChars = NSCharacterSet(charactersInString: globals.IUBString)
        let badChars = okayChars.invertedSet
        let firstBad = (seq.uppercaseString as NSString).rangeOfCharacterFromSet(badChars).location
        return (firstBad != NSNotFound)
    }
    
    
    func calcRedundancy() {
        func redundantBase(c : String) -> Int {
            switch c {
            case "A": return 1
            case "C": return 1
            case "T":  return 1
            case "G": return 1
            case "Y": return 2
            case "R": return 2
            case "W": return 2
            case "S": return 2
            case "K": return 2
            case "M": return 2
            case "D": return 3
            case "V": return 3
            case "H": return 3
            case "B": return 3
            case "N": return 4
            default : return 0
            }
        }
        let upseq = seq.uppercaseString
        var rb = 0
        redundancyFold = 1
        redundantBases = 0
        for c in upseq {
            rb = redundantBase(String(c))
            redundancyFold *= rb
            if rb > 1 {redundantBases++}
        }
    }
    
    func countBases() {
        let upseq = seq.uppercaseString
        nBases = countElements(seq)
        nAT = 0; nGC = 0
        for c in upseq {
            switch String(c) {
            case "A","T","W" :
                nAT++
            case "G","C","S" :
                nGC++
            default: false
            }
        }
    }

    
    func calcTm() -> Double {
        if self.hasBadBases() {return 0.0}
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
        self.zD = [[Int]]()
        self.zG = [[Int]]()
        self.Req = [Int]()
        self.ideal = [Int]()

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
            // n is the number of bases in the primer (or the max effective primer)
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
        maxPrimability = 0
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
        return true
    }
    
    func info() -> NSAttributedString {
        let dimer = Dimer(primer: self, and: self)
        self.countBases()
        let baseContent = String(format: "%.1f", 100.0 * (Double(nAT) + Double(nBases - nAT - nGC)/2.0)/Double(nBases))
        self.calcRedundancy()
        var report = NSMutableAttributedString(string: "Primer: \(name)\r", attributes: fmat.h3)
        extendString(starter: report, suffix: "\(nBases) bp:      ", attr: fmat.normal)
        extendString(starter: report, suffix1: "\(seq)", attr1: fmat.seq, suffix2: "\r\rTm = \(forFloat(val: self.calcTm(), decimals: 2))°C", attr2: fmat.normal)
        extendString(starter: report, suffix: "\r\(nAT) AT Pairs,  \(nGC) GC Pairs,    \(baseContent)% AT", attr: fmat.normal)
        if redundantBases == 0 {
            extendString(starter: report, suffix: "\rNo redundant bases.", attr: fmat.normal)
        } else {
            extendString(starter: report, suffix: "\rRedundant bases = \(redundantBases),  Fold redundancy = \(redundancyFold)", attr: fmat.normal)
        }
        if self.hasBadBases() {
            extendString(starter: report, suffix: "\rThis primer sequence cannot be used for PCR\r", attr: fmat.red)
        }
        if dimer.serious {
            extendString(starter: report, suffix: "\rPotential Primer Dimer with quality = \(dimer.quality) and overlap = \(dimer.olap)\r", attr: fmat.red)
        }
        return report
    }
}
