//
//  StringExtension.swift
//  easyTravel
//
//  Created by Marcel Breitenfellner on 20.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

// Source: https://stackoverflow.com/a/26775912
// String subscript feature is part of Swift 3.1 -> remove extension
extension String {
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
}
