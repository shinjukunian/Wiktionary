//
//  File.swift
//  
//
//  Created by Morten Bertz on 2020/10/01.
//

import Foundation


struct UnicodeReplacingRegex:RegexReplacing {
    
    let regex=try! NSRegularExpression(pattern: #"&#x([0-9A-Z]+);"#, options: [])
    
    func stringByReplacingMatches(in string:String)->String{
        guard let match=regex.firstMatch(in: string, options: [], range: NSRange(string.startIndex..<string.endIndex, in: string)),
              match.numberOfRanges > 1
        else{
            return string
        }
        let unicode=match.substring(at: 1, string: string)
        if let codepoint=Int(unicode, radix: 16),
           let scalar=Unicode.Scalar(codepoint){
            return  String(scalar)
        } else{
            return ""
        }
        
    }
}
