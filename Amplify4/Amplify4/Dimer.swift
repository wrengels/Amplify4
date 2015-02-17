//
//  Dimer.swift
//  Amplify4
//
//  Created by Bill Engels on 2/16/15.
//  Copyright (c) 2015 Bill Engels. All rights reserved.
//

import Foundation

struct Dimer {
    let p1, p2 : Primer
    let olap, n1, n2 : Int
    let p1pos : Int
    let quality : Double
    
    var p1n = [Int]()
    var p2n = [Int]()

    init (primer primer1 : Primer, and primer2 : Primer) {
        n1 = countElements(primer1.seq)
        n2 = countElements(primer2.seq)
        p1pos = -1
        // Make sure primer 2 is the larger one
        if countElements(primer1.seq) < countElements(primer2.seq) {
            self.p1 = primer1
            self.p2 = primer2
        } else {
            self.p1 = primer2
            self.p2 = primer1
            n1 = n2
            n2 = countElements(p2.seq)
        }
        if p1.hasBadBases() || p2.hasBadBases() {
            self.quality = -1
            self.olap = 0
            return
        }

        let settings = NSUserDefaults.standardUserDefaults()
        let dimerScores = settings.arrayForKey(globals.dimScores) as [[Int]]
        let dimerStringency = settings.integerForKey(globals.dimerStringency)
        let dimerMinOverlap = settings.integerForKey(globals.dimerOverlap)
        let dbases = [Character](globals.IUBString)
        var v = 0
        for c in p1.seq.uppercaseString {
            v = 0
            while c != dbases[v] {v++}
            p1n.append(v)
        }
        for c in p2.seq.uppercaseString {
            v = 0
            while c != dbases[v] {v++}
            p2n.append(v)
        }
        var bestQuality = Int.min
        var tempp1pos = -1
        var q = 0
        for leftEnd in 0..<n2 {
            q = 0
            for rightEnd in leftEnd..<min(leftEnd + n1 , n2) {
                let index1 = p1n[n1 - (rightEnd - leftEnd) - 1]
                let index2 = p2n[rightEnd ]
                q += dimerScores[index1][index2]
            }
            if q >= bestQuality {
                bestQuality = q
                tempp1pos = leftEnd
            }
        }
        self.p1pos = tempp1pos
        self.olap = min(n1, n2 - tempp1pos)
        self.quality = Double(bestQuality)
    }
    
    func report() -> String {
        // re-do this function with attributed strings?
         let dimerScores = NSUserDefaults.standardUserDefaults().arrayForKey(globals.dimScores) as [[Int]]
        let space = Character(" ")
        var s = "\r5' " + p2.seq + " 3'\r" + String(count: p1pos + 3, repeatedValue: space)
        for position2 in p1pos..<(p1pos + olap) {
            let index1 = p1n[n1 - 1 - (position2 - p1pos)]
            let index2 = p2n[position2]
            let score = dimerScores[index1][index2]
            if score < 0 {
                s += " "
            } else if score < 10 {
                s += ":"
            } else {
                s += "|"
            }
        }
        s +=  "\r"
        s += String(count: p1pos, repeatedValue: space) + "3' " + reverse(p1.seq) + " 5'\r"
        
        return s
    }
    
}