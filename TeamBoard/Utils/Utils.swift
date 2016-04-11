//
//  Utils.swift
//  TeamBoard
//
//  Created by Henrique Valcanaia on 4/8/16.
//  Copyright © 2016 MC. All rights reserved.
//

import Foundation

extension String {
    
    func asRange() -> NSRange {
        let range = NSRange(location: 0, length: characters.count)
        return range
    }
    
}

// FIXME: Regex are not indicated due to performance issues
func matchesForRegexInText(regex: String, text: String) throws -> [String] {
    var resultsFound = [String]()
    let regex = try NSRegularExpression(pattern: regex, options: .CaseInsensitive)
    let results = regex.matchesInString(text, options: [], range: text.asRange())
    for result in results {
        for rangeIndex in 0..<result.numberOfRanges {
            let range = result.rangeAtIndex(rangeIndex)
            let nsText = NSString(format: text)
            let text = nsText.substringWithRange(range)
            resultsFound += [text]
        }
    }
    
    return resultsFound
}


enum IndexType: Int {
    case Even = 0
    case Odd = 1
}

extension Array {
    
    func forEachOddIndex(@noescape body: (Generator.Element) throws -> Void) rethrows {
        try forEachWithIndexType(.Odd, body: body)
    }
    
    func forEachEvenIndex(@noescape body: (Generator.Element) throws -> Void) rethrows {
        try forEachWithIndexType(.Even, body: body)
    }
    
    private func forEachWithIndexType(type: IndexType, @noescape body: (Generator.Element) throws -> Void) rethrows {
        for index in type.rawValue.stride(to: count, by: 2) {
            try body(self[index])
        }
    }
    
}