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

extension UILabel {
    
    func setTextWithFade(text:String) {
        let duration:Double = 1
        UIView.animateWithDuration(duration/2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.text = text
            UIView.animateWithDuration(duration/2) {
                self.alpha = 1.0
            }
        }
    }
    
    func setAttributedTextWithFade(text:NSAttributedString) {
        let duration:Double = 1
        UIView.animateWithDuration(duration/2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.attributedText = text
            UIView.animateWithDuration(duration/2) {
                self.alpha = 1.0
            }
        }
    }
    
}

extension UIImageView {
    
    func setImageWithFade(image:UIImage) {
        let duration:Double = 1
        UIView.animateWithDuration(duration/2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.image = image
            UIView.animateWithDuration(duration/2) {
                self.alpha = 1.0
            }
        }
    }
    
}


extension UIColor {
    
    // Creates a UIColor from a Hex string.
    convenience init(hexString: String) {
        var cString: String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            self.init(white: 0.5, alpha: 1.0)
        } else {
            let rString: String = (cString as NSString).substringToIndex(2)
            let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
            let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
            
            var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
            NSScanner(string: rString).scanHexInt(&r)
            NSScanner(string: gString).scanHexInt(&g)
            NSScanner(string: bString).scanHexInt(&b)
            
            self.init(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: CGFloat(1))
        }
        
        
    }
}